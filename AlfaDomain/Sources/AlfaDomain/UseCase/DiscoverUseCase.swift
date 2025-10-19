//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public protocol IDiscoverUseCase {
    func execute(language: String, genreId: Int, page: Int) async throws -> DiscoverResultsEntity
}

public struct DiscoverUseCase: IDiscoverUseCase {
    private let discoverRepository: IDiscoverRepository

    public init(discoverRepository: IDiscoverRepository) {
        self.discoverRepository = discoverRepository
    }

    public func execute(language: String, genreId: Int, page: Int) async throws -> DiscoverResultsEntity {
        do {
            let discover: DiscoverResultsEntity = try await discoverRepository.fetchDiscover(language: language, genreId: genreId, page: page)
            return discover
        } catch {
            throw error
        }
    }
}
