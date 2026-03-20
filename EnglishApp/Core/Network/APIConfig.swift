//
//  APIConfig.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh on 18/3/26.
//

import Foundation

struct APIConfig {
    /// URL của server thật (Production).
    /// Đảm bảo KHÔNG có dấu "/" ở cuối cùng.
    static let baseURL = "https://api.amidemy.uk/api/v1"
    
    /// Dành cho các API liên quan đến đăng nhập/đăng ký
    /// Kết quả: https://api.amidemy.uk/api/v1/auth
    static var authBaseURL: String {
        return "\(baseURL)/auth"
    }
    
    /// Dành cho việc đồng bộ dữ liệu (hiện đang gọi thẳng vào API courses)
    /// Kết quả: https://api.amidemy.uk/api/v1
    static var syncBaseURL: String {
        return baseURL
    }
    
    /// Helper để tạo URL từ path (ví dụ truyền vào "/courses/")
    static func url(for path: String) -> URL? {
        return URL(string: "\(baseURL)\(path)")
    }
}
