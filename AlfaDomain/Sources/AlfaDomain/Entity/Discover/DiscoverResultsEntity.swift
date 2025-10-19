//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public struct DiscoverResultsEntity {
    
    public var page: Int
    public var results: [DiscoverResultEntity]
    public let total_pages: Int
    public let total_results: Int
    
    public init(page: Int, results: [DiscoverResultEntity], total_pages: Int, total_results: Int) {
        self.page = page
        self.results = results
        self.total_pages = total_pages
        self.total_results = total_results
    }
}
