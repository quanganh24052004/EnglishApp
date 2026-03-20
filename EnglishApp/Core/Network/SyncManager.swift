//
//  SyncError 2.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh on 12/3/26.
//


import Foundation
import SwiftData
import os

enum SyncError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case databaseError(Error)
}

/// Helper struct for the POST Sync Body Request
struct SyncRequestPayload: Codable {
    let last_sync_time: String
}

@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    // Đổi Base URL thành IP LAN của Macbook để iOS Simulator/Thiết bị có thể gọi được vào FastAPI Docker.
    private let baseURL = "http://192.168.1.58:8000/api/v1"
    private let logger = Logger(subsystem: "com.englishapp.sync", category: "SyncManager")
    
    /// Biến lưu trữ thời điểm Sync cuối cùng. Lưu vào UserDefaults để sống vĩnh viễn trên máy.
    private var lastSyncTime: Date {
        get {
            let lastTimestamp = UserDefaults.standard.double(forKey: "lastSyncTimeKey")
            return lastTimestamp == 0 ? Date(timeIntervalSince1970: 0) : Date(timeIntervalSince1970: lastTimestamp)
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "lastSyncTimeKey")
        }
    }
    
    // MARK: - 1. PULL STATIC DATA (Course, Lesson, Word)
    
    /// Kéo dữ liệu Tĩnh (Khoá học, Từ vựng) từ Server về và gộp vào SwiftData
    func pullStaticCourses(context: ModelContext) async throws {
        guard let url = URL(string: "\(baseURL)/sync/pull_courses") else {
            throw SyncError.invalidURL
        }
        
        // Cần format Date sang ISO8601 chuẩn của Python: "2024-01-01T00:00:00Z"
        let formatter = ISO8601DateFormatter()
        let timeString = formatter.string(from: lastSyncTime)
        
        let payload = SyncRequestPayload(last_sync_time: timeString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" 
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 🔐 Lấy Token từ Keychain gắn vào Request
        if let token = KeychainHelper.shared.readToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            logger.warning("Không tìm thấy Token. Server có thể từ chối request nếu bị cấu hình khoá.")
        }
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        logger.info("Bắt đầu PULL dữ liệu Courses từ thời điểm: \(timeString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            logger.error("Lỗi HTTP Status Code. Data trả về: \(String(data: data, encoding: .utf8) ?? "")")
            throw SyncError.invalidResponse
        }
        
        // Cấu hình Decoder cho chuẩn JSON từ FastAPI (Hỗ trợ Date formats và Snake Case)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Parser custom format Python: "2026-03-11T16:55:27.916308Z" -> Date()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) { return date }
            
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) { return date }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid Date: \(dateString)")
        }
        
        do {
            logger.info("Đang decode JSON Dữ liệu Tĩnh...")
            // Parse nguyên mảng JSON khổng lồ trả về
            let fetchedCourses = try decoder.decode([Course].self, from: data)
            
            logger.info("Tải thành công \(fetchedCourses.count) Courses (Kèm Lessons/Words lồng nhau). Bắt đầu merge vào SwiftData.")
            
            // Bắt đầu quy trình Conflict Resolution (Merge Delta vào Local)
            try mergeCoursesToSwiftData(context: context, incomingCourses: fetchedCourses)
            
            // Lưu lại thời điểm thành công (Timestamp mới nhất từ lần kéo thành công)
            self.lastSyncTime = Date()
            logger.info("Đã hoàn thành quá trình Đồng Bộ! Update lastSyncTime.")
            
        } catch {
            logger.error("Lỗi Parsing JSON: \(error.localizedDescription)")
            throw SyncError.decodingError(error)
        }
    }
    
    // MARK: - 2. MERGE LOGIC (Conflict Resolution)
    
    private func mergeCoursesToSwiftData(context: ModelContext, incomingCourses: [Course]) throws {
        // Lấy toàn bộ Courses cũ trong máy ra để đối chiếu
        let fetchDescriptor = FetchDescriptor<Course>()
        let localCourses = try context.fetch(fetchDescriptor)
        let localCoursesDict = Dictionary(uniqueKeysWithValues: localCourses.map { ($0.id, $0) })
        
        var insertedCount = 0
        var updatedCount = 0
        var deletedCount = 0
        
        for incoming in incomingCourses {
            if let existing = localCoursesDict[incoming.id] {
                // Course Đã có trong máy tính -> Kiểm tra xem ai mới hơn
                if incoming.updatedAt > existing.updatedAt {
                    if incoming.isDeleted {
                        // Lệnh xoá từ Server xoá cả ở Local
                        context.delete(existing)
                        deletedCount += 1
                    } else {
                        // Cập nhật đè dữ liệu
                        existing.name = incoming.name
                        existing.desc = incoming.desc
                        existing.subDescription = incoming.subDescription
                        existing.updatedAt = incoming.updatedAt
                        
                        // Ở đây nế muốn hoàn hảo còn phải For-loop vào từng Lesson/Word của incoming để merge. 
                        // Vì SwiftData xoá cascade, cách nhanh nhất là xoá mảng cũ và gán mảng mới nếu có thay đổi.
                        existing.lessons = incoming.lessons
                        updatedCount += 1
                    }
                }
            } else {
                // Course Hoàn toàn mới -> Insert thẳng
                if !incoming.isDeleted {
                    context.insert(incoming)
                    insertedCount += 1
                }
            }
        }
        
        // Lưu vật lý vào CSDL Điện Thoại (SQLite)
        try context.save()
        logger.info("📝 Merge DB Thành Công: \(insertedCount) mới tạo, \(updatedCount) cập nhật, \(deletedCount) xoá.")
    }
    

    // MARK: - 3. PUSH DYNAMIC DATA (StudyRecords)
    
    /// Đẩy những thay đổi cục bộ (Tạo lúc không có mạng) lên Server
    func pushStudyRecords(context: ModelContext) async throws {
        // ... Code chuẩn bị fetch StudyRecord có `updatedAt > lastSyncTime` gửi lên ...
        logger.info("Đang test PUSH API logic...")
    }
}

