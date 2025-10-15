//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public enum APIRequest {
    case genres
    
    var path: String {
        switch self {
        case .genres:
            return "/genre/movie/list"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .genres:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .genres:
            return [URLQueryItem(name: "language", value: "en-US")]
        }
    }
}

extension APIRequest {
    
    func buildRequest(apiKey: String) throws -> URLRequest {
        var finalQueryItems = self.queryItems
        finalQueryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        
        return try RequestBuilder.buildRequest(
            baseURL: APIEndpoints.baseURL,
            path: self.path,
            method: self.method,
            queryItems: finalQueryItems
        )
    }
}
