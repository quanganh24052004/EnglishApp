//
//  KeychainHelper.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh on 12/3/26.
//


import Foundation
import Combine
import Security

// MARK: - KEYCHAIN UTILITY
/// Tiện ích lưu trữ JWT Token bảo mật vào Keychain của thiết bị (an toàn hơn UserDefaults)
class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary

        SecItemAdd(query, nil) // Có thể bỏ qua lỗi trùng lặp nếu có, nhưng tốt nhất là xoá trước khi thêm
    }
    
    func saveToken(token: String) {
        let data = Data(token.utf8)
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.englishapp.tokenService",
            kSecAttrAccount: "jwtToken"
        ] as CFDictionary
        
        SecItemDelete(query) // Xoá token cũ nếu có
        
        let addQuery = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.englishapp.tokenService",
            kSecAttrAccount: "jwtToken"
        ] as CFDictionary
        
        SecItemAdd(addQuery, nil)
    }

    func readToken() -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.englishapp.tokenService",
            kSecAttrAccount: "jwtToken",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func deleteToken() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.englishapp.tokenService",
            kSecAttrAccount: "jwtToken"
        ] as CFDictionary

        SecItemDelete(query)
    }
}

// MARK: - MODELS

struct AuthTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}


// MARK: - AUTH SERVICE
enum AuthError: Error {
    case invalidURL
    case networkError(Error)
    case unauthorized
    case invalidResponse
    case decodingError(Error)
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    private let baseURL = "http://192.168.1.58:8000/api/v1/auth"
    
    @Published var isAuthenticated: Bool = false
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let token = KeychainHelper.shared.readToken(), !token.isEmpty {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
    
    /// Logic Đăng Nhập gọi Backend `POST /api/v1/auth/login` (Backend dùng dạng FormData x-www-form-urlencoded theo chuẩn OAuth2)
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "\(baseURL)/login") else { throw AuthError.invalidURL }
        
        // FastAPI `OAuth2PasswordRequestForm` yêu cầu Body dạng Form-Data
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = "username=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = bodyParameters.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.invalidResponse }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            do {
                let tokenResponse = try decoder.decode(AuthTokenResponse.self, from: data)
                // Lưu JWT Token vào Keychain
                KeychainHelper.shared.saveToken(token: tokenResponse.accessToken)
                isAuthenticated = true
            } catch {
                throw AuthError.decodingError(error)
            }
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            throw AuthError.unauthorized
        } else {
            throw AuthError.invalidResponse
        }
    }
    
    /// Logic Đăng Xuất
    func logout() {
        KeychainHelper.shared.deleteToken()
        isAuthenticated = false
    }
    
    // ... Hàm Register ...
}

