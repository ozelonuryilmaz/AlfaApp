//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public protocol IDiscoverUseCase {
    func execute(language: String, genreId: Int, page: Int, forceRefresh: Bool) async throws -> DiscoverResultsEntity
    func clearCache()
}

public struct DiscoverUseCase: IDiscoverUseCase {
    private let discoverRepository: IDiscoverRepository

    public init(discoverRepository: IDiscoverRepository) {
        self.discoverRepository = discoverRepository
    }

    public func execute(language: String, genreId: Int, page: Int, forceRefresh: Bool) async throws -> DiscoverResultsEntity {
        do {
            let discover: DiscoverResultsEntity = try await discoverRepository.fetchDiscover(language: language, genreId: genreId, page: page, forceRefresh: forceRefresh)
            return discover
        } catch {
            throw error
        }
    }
    
    public func clearCache() {
        discoverRepository.clearCache()
    }
}
