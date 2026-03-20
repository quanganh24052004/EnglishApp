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
    private let baseURL = APIConfig.authBaseURL
    
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
    
    /// Logic Đăng Nhập gọi Backend `POST /api/v1/auth/login`
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "\(baseURL)/login") else { throw AuthError.invalidURL }
        
        let safeEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let safePassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = "username=\(safeEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&password=\(safePassword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = bodyParameters.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.invalidResponse }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            do {
                // Phải bọc qua APIResponse vì JSON thực tế có "data" bọc ngoài
                let responseWrapper = try decoder.decode(APIResponse<AuthTokenResponse>.self, from: data)
                
                guard let tokenResponse = responseWrapper.data else {
                    throw AuthError.invalidResponse
                }
                
                // Lưu JWT Token vào Keychain
                KeychainHelper.shared.saveToken(token: tokenResponse.accessToken)
                
                await MainActor.run {
                    self.isAuthenticated = true
                }
            } catch {
                print("Decoding AuthTokenResponse failed: \(error)")
                throw AuthError.decodingError(error)
            }
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            if let errorString = String(data: data, encoding: .utf8) {
                print("Server 401/403 Error Detail: \(errorString)")
            }
            throw AuthError.unauthorized
        } else {
            throw AuthError.invalidResponse
        }
    }

    /// Logic Đăng Xuất
    func logout() {
        KeychainHelper.shared.deleteToken()
        UserDefaults.standard.removeObject(forKey: "lastSyncTime_Courses")
        isAuthenticated = false
    }
    
    /// Logic Đăng Ký gọi Backend `POST /api/v1/auth/register` (Backend nhận dạng JSON UserCreate)
    func register(email: String, password: String) async throws {
        guard let url = URL(string: "\(baseURL)/register") else { throw AuthError.invalidURL }
        
        let safeEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let safePassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": safeEmail,
            "password": safePassword
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.invalidResponse }
        
        // Mặc dù FastAPI trả về 200, Swift Data có thể decode hoặc lờ đi User trả về tuỳ nhu cầu
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            return // Đăng ký thành công
        } else {
            // Trường hợp 400 Bad Request (vd: Email đã tồn tại)
            if let errorString = String(data: data, encoding: .utf8) {
                print("Register Server Error: \(errorString)")
            }
            throw AuthError.invalidResponse
        }
    }
}
