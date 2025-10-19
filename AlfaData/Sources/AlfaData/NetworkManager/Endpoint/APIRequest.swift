//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public enum APIRequest {
    case genres
    case discover
    
    var path: String {
        switch self {
        case .genres:
            return "/genre/movie/list"
        case .discover:
            return "/discover/movie"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .genres, .discover:
            return .get
            
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .genres:
            return []
        case .discover:
            return [URLQueryItem(name: "sort_by", value: "popularity.desc"),
                    URLQueryItem(name: "include_adult", value: "false"),
                    URLQueryItem(name: "include_video", value: "false")]
        }
    }
}

extension APIRequest {
    
    func buildRequest(apiKey: String, extraQueryItems: [URLQueryItem] = []) throws -> URLRequest {
        var finalQueryItems: [URLQueryItem] = self.queryItems
        finalQueryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        finalQueryItems.append(contentsOf: extraQueryItems)
        
        return try RequestBuilder.buildRequest(
            baseURL: APIEndpoints.baseURL,
            path: self.path,
            method: self.method,
            queryItems: finalQueryItems
        )
    }
}
