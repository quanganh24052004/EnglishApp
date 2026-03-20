//
//  SyncDecodingTests.swift
//  EnglishApp
//
//  Created by Antigravity on 18/3/26.
//

import Foundation

// Mock Models for Testing
struct MockToken: Codable, Equatable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct MockCourse: Codable, Equatable {
    let id: String
    let name: String
}

// Minimal APIResponse for script context
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let msg: String
    let data: T?
}

func runTests() {
    let decoder = JSONDecoder()
    
    // Test 1: Successful Token Decoding
    let tokenJson = """
    {
        "code": 200,
        "msg": "Request successful",
        "data": {
            "access_token": "eyJhbGciOiJIUzI1Ni...",
            "token_type": "bearer"
        }
    }
    """
    
    do {
        let response = try decoder.decode(APIResponse<MockToken>.self, from: Data(tokenJson.utf8))
        assert(response.code == 200)
        assert(response.data?.accessToken == "eyJhbGciOiJIUzI1Ni...")
        print("✅ Test 1 Passed: Successful Token Decoding")
    } catch {
        print("❌ Test 1 Failed: \(error)")
    }
    
    // Test 2: Successful Courses Decoding
    let coursesJson = """
    {
        "code": 200,
        "msg": "Success",
        "data": [
            {"id": "A1", "name": "Basic English"},
            {"id": "A2", "name": "Intermediate English"}
        ]
    }
    """
    
    do {
        let response = try decoder.decode(APIResponse<[MockCourse]>.self, from: Data(coursesJson.utf8))
        assert(response.code == 200)
        assert(response.data?.count == 2)
        assert(response.data?[0].id == "A1")
        print("✅ Test 2 Passed: Successful Courses Decoding")
    } catch {
        print("❌ Test 2 Failed: \(error)")
    }
    
    // Test 3: Error Response with Missing Data
    let errorJson = """
    {
        "code": 401,
        "msg": "Not authenticated",
        "data": null
    }
    """
    
    do {
        let response = try decoder.decode(APIResponse<[MockCourse]>.self, from: Data(errorJson.utf8))
        assert(response.code == 401)
        assert(response.data == nil)
        print("✅ Test 3 Passed: Error Response Handling (Data Null)")
    } catch {
        print("❌ Test 3 Failed: \(error)")
    }

    // Test 4: Error Response with Omitted Data
        let omittedDataJson = """
    {
        "code": 404,
        "msg": "Not Found"
    }
    """
    
    do {
        let response = try decoder.decode(APIResponse<[MockCourse]>.self, from: Data(omittedDataJson.utf8))
        assert(response.code == 404)
        assert(response.data == nil)
        print("✅ Test 4 Passed: Error Response Handling (Data Omitted)")
    } catch {
        print("❌ Test 4 Failed: \(error)")
    }
}

runTests()
