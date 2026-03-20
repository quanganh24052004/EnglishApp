//
//  APIResponse.swift
//  EnglishApp
//
//  Created by Antigravity on 18/3/26.
//

import Foundation

/// A generic wrapper for backend API responses.
/// Matches the structure: { "code": Int, "msg": String, "data": T? }
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let msg: String
    let data: T?
}
