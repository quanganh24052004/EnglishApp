//
//  SyncManager.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh 12/3/2026
//

import Combine
import Foundation
import SwiftData

enum SyncError: Error {
    case invalidURL
    case unauthenticated
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case networkError(URLError)
}

/// Lớp điều phối đồng bộ hoá (Full Sync) giữa SwiftData cục bộ và FastAPI Backend
@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    // Đảm bảo APIConfig.syncBaseURL là "https://api.amidemy.uk/api/v1"
    private let baseURL = APIConfig.syncBaseURL
    
    // Vẫn giữ lại key này để sau này bạn dễ dàng quay lại làm Delta Sync
    private let pullCoursesDateKey = "lastSyncTime_Courses"
    
    @Published var isSyncing: Bool = false
    
    private init() {}
    
    /// Chức năng PULL: Kéo tất cả Course, Lesson, Word từ Server về iPhone (Full Sync)
    func pullStaticCourses(context: ModelContext) async throws {
        isSyncing = true
        defer { isSyncing = false }
        
        // 1. Lấy Token
        let token = KeychainHelper.shared.readToken()
        
        // [SỬA ĐỔI 1]: Trỏ đích danh vào API lấy danh sách khoá học.
        // Lưu ý: Thêm "/courses/" (có dấu / ở cuối cho chuẩn FastAPI)
        guard let url = URL(string: "\(baseURL)/courses/") else {
            throw SyncError.invalidURL
        }
        
        // 2. Tạo Request
        var request = URLRequest(url: url)
        // [SỬA ĐỔI 2]: Chuyển phương thức từ POST sang GET
        request.httpMethod = "GET"
        
        // Đính kèm Token bảo mật nếu user đã đăng nhập
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // [SỬA ĐỔI 3]: Đã xoá bỏ httpBody chứa last_sync_time vì GET request không cần body.
        
        print("Bắt đầu Full Sync: Gọi API Server tại \(url.absoluteString)")
        
        // 3. Bắn Request
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            print("Lỗi kết nối mạng: \(error.localizedDescription)")
            // Ném lỗi mạng riêng biệt
            throw SyncError.networkError(error)
        } catch {
            print("Lỗi không xác định khi gọi API: \(error.localizedDescription)")
            throw SyncError.invalidResponse
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SyncError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            print("Lỗi xác thực: Token hết hạn hoặc không hợp lệ.")
            throw SyncError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            print("API Lỗi (\(httpResponse.statusCode)): \(String(data: data, encoding: .utf8) ?? "")")
            throw SyncError.invalidResponse
        }
        
        // 4. Decode JSON
        let decoder = JSONDecoder()
        
        // Custom Date Decoding vì Python trả về chuẩn ISO có kèm mili-giây
        decoder.dateDecodingStrategy = .custom { customDecoder -> Date in
            let container = try customDecoder.singleValueContainer()
            let str = try container.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: str) {
                return date
            }
            
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: str) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Không thể parse ngày tháng từ chuỗi: \(str)")
        }
        
        do {
            // Giải mã theo cấu trúc APIResponse bọc ngoài
            let responseWrapper = try decoder.decode(APIResponse<[Course]>.self, from: data)
            
            guard let serverCourses = responseWrapper.data else {
                print("Lỗi: Server trả về thành công nhưng data bị thiếu: \(responseWrapper.msg)")
                isSyncing = false
                return
            }
            
            print("Đã tải thành công \(serverCourses.count) Khoá học từ Server.")
            
            if serverCourses.isEmpty {
                print("Server hiện chưa có khoá học nào.")
            } else {
                // 5. Nhúng vào SwiftData
                for course in serverCourses {
                    // Cấu trúc Full Sync: Xoá hoặc Ghi đè
                    if course.isDeleted {
                        context.delete(course)
                        print("🗑 Đã xoá Course: \(course.name)")
                    } else {
                        // Nhờ @Attribute(.unique) trong Model, SwiftData sẽ tự động ghi đè bản cũ
                        context.insert(course)
                        print("✅ Upsert Course: \(course.name)")
                    }
                }
                // Lưu thẳng vào Ổ cứng
                try context.save()
            }
            
            // Cập nhật mốc thời gian hiện tại (chuẩn bị cho tương lai dùng lại Delta Sync)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: pullCoursesDateKey)
            
        } catch {
            print("Lỗi bóc tách JSON hoặc SwiftData: \(error)")
            // In ra nội dung JSON thực tế để dễ debug nếu decode lỗi
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Nội dung JSON nhận được: \(jsonString)")
            }
            throw SyncError.decodingError(error)
        }
    }
}
