//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

struct RequestBuilder {
    
    static func buildRequest(baseURL: String,
                             path: String,
                             method:HTTPMethod,
                             headers: [String: String] = [:],
                             queryItems: [URLQueryItem]? = nil,
                             body:Data? = nil) throws -> URLRequest {
        
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
}
