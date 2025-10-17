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
    public let posterURL: URL?
    
    public init(id: Int, title: String, posterURL: URL?) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
    }
}
