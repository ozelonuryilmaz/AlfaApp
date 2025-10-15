//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

struct APIEndpoint {

    static let baseURL = "https://api.themoviedb.org/3"
    
    static func getProducts() -> URLRequest? {
        try? RequestBuilder.buildRequest(
            baseURL: baseURL,
            path: "/genre/movie/list?",
            method: .get,
            queryItems: [
                URLQueryItem(name: "api_key", value: "3bb3e67969473d0cb4a48a0dd61af747"),
                URLQueryItem(name: "language", value: "en-US")
            ]
        )
    }
}
