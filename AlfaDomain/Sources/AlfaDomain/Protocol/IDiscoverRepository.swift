//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public protocol IDiscoverRepository {
    func fetchDiscover(genreId: Int, page: Int) async throws -> DiscoverResultsEntity
}
