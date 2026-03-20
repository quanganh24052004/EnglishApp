//
//  Item.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh on 11/3/26.
//

import Foundation
import SwiftData

// ==========================================
// MARK: - 1. CORE AUTH & USER SYSTEM
// ==========================================

@Model
final class User: Codable, Identifiable {
    @Attribute(.unique) var id: String // String(8) Server ID
    var email: String
    var name: String?
    var phone: String?
    var isPremium: Bool
    var createdAt: Date? // Đổi thành Optional
    
    // Mapping properties
    @Relationship(deleteRule: .cascade, inverse: \Account.user) var account: Account?
    @Relationship(deleteRule: .cascade, inverse: \StudyRecord.user) var studyRecords: [StudyRecord] = []
    @Relationship(deleteRule: .cascade, inverse: \LessonRecord.user) var lessonRecords: [LessonRecord] = []
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, phone
        case isPremium = "is_premium"
        case createdAt = "created_at"
    }
    
    init(id: String, email: String, name: String? = nil, phone: String? = nil, isPremium: Bool = false) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.isPremium = isPremium
        self.createdAt = Date()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

@Model
final class Account {
    var email: String
    var statusAccount: String
    var user: User? // Back reference
    
    init(email: String, statusAccount: String = "active") {
        self.email = email
        self.statusAccount = statusAccount
    }
}

// ==========================================
// MARK: - 2. STATIC CONTENT (Course -> Lesson -> Word -> Meaning)
// ==========================================

@Model
final class Course: Codable, Identifiable {
    @Attribute(.unique) var id: String
    var name: String
    var desc: String
    var subDescription: String?
    
    // --- Delta Sync Tracking ---
    var updatedAt: Date? // Đã chuẩn hoá tên biến thành updatedAt và là Optional
    var isDeleted: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Lesson.course) var lessons: [Lesson] = []
    
    enum CodingKeys: String, CodingKey {
        case id, name, lessons
        case desc = "description"
        case subDescription = "sub_description"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }
    
    init(id: String, name: String, desc: String, subDescription: String? = nil, updatedAt: Date? = nil, isDeleted: Bool = false) {
        self.id = id
        self.name = name
        self.desc = desc
        self.subDescription = subDescription
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.subDescription = try container.decodeIfPresent(String.self, forKey: .subDescription)
        
        // FIX: Dùng decodeIfPresent cho các trường tracking
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        
        self.lessons = try container.decodeIfPresent([Lesson].self, forKey: .lessons) ?? []
        for lesson in self.lessons {
            lesson.course = self
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(desc, forKey: .desc)
        try container.encodeIfPresent(subDescription, forKey: .subDescription)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}

@Model
final class Lesson: Codable, Identifiable {
    @Attribute(.unique) var id: String
    
    // FIX: Chuyển thành Optional
    var courseId: String?
    
    var name: String
    var subName: String?
    var quantityOfWord: Int
    
    var updatedAt: Date?
    var isDeleted: Bool
    
    var course: Course?
    @Relationship(deleteRule: .cascade, inverse: \Word.lesson) var words: [Word] = []
    
    enum CodingKeys: String, CodingKey {
        case id, name, words
        case courseId = "course_id"
        case subName = "sub_name"
        case quantityOfWord = "quantity_of_word"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }
    
    init(id: String, courseId: String? = nil, name: String, subName: String?, quantityOfWord: Int, updatedAt: Date? = nil, isDeleted: Bool = false) {
        self.id = id
        self.courseId = courseId
        self.name = name
        self.subName = subName
        self.quantityOfWord = quantityOfWord
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        // FIX: Dùng decodeIfPresent
        self.courseId = try container.decodeIfPresent(String.self, forKey: .courseId)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.subName = try container.decodeIfPresent(String.self, forKey: .subName)
        self.quantityOfWord = try container.decodeIfPresent(Int.self, forKey: .quantityOfWord) ?? 0
        
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        
        self.words = try container.decodeIfPresent([Word].self, forKey: .words) ?? []
        for word in self.words {
            word.lesson = self
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(courseId, forKey: .courseId)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(subName, forKey: .subName)
        try container.encode(quantityOfWord, forKey: .quantityOfWord)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}

@Model
final class Word: Codable, Identifiable {
    @Attribute(.unique) var id: String
    
    // FIX: Chuyển thành Optional
    var lessonId: String?
    
    var english: String
    var phonetic: String?
    var partOfSpeech: String?
    var audioUrl: String?
    var cefr: String?
    
    var updatedAt: Date?
    var isDeleted: Bool
    
    var lesson: Lesson?
    @Relationship(deleteRule: .cascade, inverse: \Meaning.word) var meanings: [Meaning] = []
    @Relationship(deleteRule: .cascade, inverse: \StudyRecord.word) var studyRecords: [StudyRecord] = []

    enum CodingKeys: String, CodingKey {
        case id, english, phonetic, cefr, meanings
        case lessonId = "lesson_id"
        case partOfSpeech = "part_of_speech"
        case audioUrl = "audio_url"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }

    init(id: String, lessonId: String? = nil, english: String, updatedAt: Date? = nil, isDeleted: Bool = false) {
        self.id = id
        self.lessonId = lessonId
        self.english = english
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        // FIX: Dùng decodeIfPresent
        self.lessonId = try container.decodeIfPresent(String.self, forKey: .lessonId)
        
        self.english = try container.decode(String.self, forKey: .english)
        self.phonetic = try container.decodeIfPresent(String.self, forKey: .phonetic)
        self.partOfSpeech = try container.decodeIfPresent(String.self, forKey: .partOfSpeech)
        self.audioUrl = try container.decodeIfPresent(String.self, forKey: .audioUrl)
        self.cefr = try container.decodeIfPresent(String.self, forKey: .cefr)
        
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        
        self.meanings = try container.decodeIfPresent([Meaning].self, forKey: .meanings) ?? []
        for meaning in self.meanings {
            meaning.word = self
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(lessonId, forKey: .lessonId)
        try container.encode(english, forKey: .english)
        try container.encodeIfPresent(phonetic, forKey: .phonetic)
        try container.encodeIfPresent(partOfSpeech, forKey: .partOfSpeech)
        try container.encodeIfPresent(audioUrl, forKey: .audioUrl)
        try container.encodeIfPresent(cefr, forKey: .cefr)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}

@Model
final class Meaning: Codable, Identifiable {
    @Attribute(.unique) var id: String
    
    // FIX: Chuyển thành Optional
    var wordId: String?
    
    var vietnamese: String
    var exampleEn: String?
    var exampleVi: String?
    
    var updatedAt: Date?
    var isDeleted: Bool
    
    var word: Word?

    enum CodingKeys: String, CodingKey {
        case id, vietnamese
        case wordId = "word_id"
        case exampleEn = "example_en"
        case exampleVi = "example_vi"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }

    init(id: String, wordId: String? = nil, vietnamese: String, updatedAt: Date? = nil, isDeleted: Bool = false) {
        self.id = id
        self.wordId = wordId
        self.vietnamese = vietnamese
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        // FIX: Dùng decodeIfPresent
        self.wordId = try container.decodeIfPresent(String.self, forKey: .wordId)
        
        self.vietnamese = try container.decode(String.self, forKey: .vietnamese)
        self.exampleEn = try container.decodeIfPresent(String.self, forKey: .exampleEn)
        self.exampleVi = try container.decodeIfPresent(String.self, forKey: .exampleVi)
        
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(wordId, forKey: .wordId)
        try container.encode(vietnamese, forKey: .vietnamese)
        try container.encodeIfPresent(exampleEn, forKey: .exampleEn)
        try container.encodeIfPresent(exampleVi, forKey: .exampleVi)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}

// ==========================================
// MARK: - 3. DYNAMIC CONTENT (Push Sync)
// ==========================================

@Model
final class StudyRecord: Codable, Identifiable {
    @Attribute(.unique) var id: String
    var userId: String
    var wordId: String
    
    var memoryLevel: Int
    var lastReview: Date?
    var nextReview: Date?
    
    // --- Delta Sync Tracking ---
    var updatedAt: Date? // Đổi thành Optional
    var isDeleted: Bool
    
    var user: User?
    var word: Word?
    
    enum CodingKeys: String, CodingKey {
        case id, memoryLevel = "memory_level", lastReview = "last_review", nextReview = "next_review"
        case userId = "user_id"
        case wordId = "word_id"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }
    
    init(id: String = UUID().uuidString, userId: String, wordId: String, memoryLevel: Int = 0) {
        self.id = id
        self.userId = userId
        self.wordId = wordId
        self.memoryLevel = memoryLevel
        self.lastReview = Date()
        self.nextReview = Date()
        self.updatedAt = Date()
        self.isDeleted = false
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.wordId = try container.decode(String.self, forKey: .wordId)
        self.memoryLevel = try container.decodeIfPresent(Int.self, forKey: .memoryLevel) ?? 0
        
        // FIX
        self.lastReview = try container.decodeIfPresent(Date.self, forKey: .lastReview)
        self.nextReview = try container.decodeIfPresent(Date.self, forKey: .nextReview)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(wordId, forKey: .wordId)
        try container.encode(memoryLevel, forKey: .memoryLevel)
        try container.encodeIfPresent(lastReview, forKey: .lastReview)
        try container.encodeIfPresent(nextReview, forKey: .nextReview)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}

@Model
final class LessonRecord: Codable, Identifiable {
    @Attribute(.unique) var id: String
    var userId: String
    var lessonId: String
    
    var isCompleted: Bool
    var score: Int?
    var completionDate: Date?
    
    // --- Delta Sync Tracking ---
    var updatedAt: Date? // Đổi thành Optional
    var isDeleted: Bool
    
    var user: User?
    var lesson: Lesson?
    
    enum CodingKeys: String, CodingKey {
        case id, score
        case userId = "user_id"
        case lessonId = "lesson_id"
        case isCompleted = "is_completed"
        case completionDate = "completion_date"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }
    
    init(id: String = UUID().uuidString, userId: String, lessonId: String, isCompleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.lessonId = lessonId
        self.isCompleted = isCompleted
        self.updatedAt = Date()
        self.isDeleted = false
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.lessonId = try container.decode(String.self, forKey: .lessonId)
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        self.score = try container.decodeIfPresent(Int.self, forKey: .score)
        self.completionDate = try container.decodeIfPresent(Date.self, forKey: .completionDate)
        
        // FIX
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(lessonId, forKey: .lessonId)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(score, forKey: .score)
        try container.encodeIfPresent(completionDate, forKey: .completionDate)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(isDeleted, forKey: .isDeleted)
    }
}
