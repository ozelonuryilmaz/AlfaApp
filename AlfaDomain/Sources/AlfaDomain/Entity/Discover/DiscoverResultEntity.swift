//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public struct DiscoverResultEntity {
    
    public let id: Int
    public let title: String
    public let poster_path: String
    
    public init(id: Int, title: String, poster_path: String) {
        self.id = id
        self.title = title
        self.poster_path = poster_path
    }
}
