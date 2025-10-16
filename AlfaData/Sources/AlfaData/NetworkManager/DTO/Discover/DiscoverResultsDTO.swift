//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public struct DiscoverResultsDTO: Decodable {
    
    let page: Int
    let results: [DiscoverResultDTO]
}
