//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public struct DiscoverResultsEntity {
    
    public let page: Int
    public let results: [DiscoverResultEntity]
    
    public init(page: Int, results: [DiscoverResultEntity]) {
        self.page = page
        self.results = results
    }
}
