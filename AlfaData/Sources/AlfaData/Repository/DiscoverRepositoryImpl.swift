//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation
import AlfaDomain

final public class DiscoverRepositoryImpl: IDiscoverRepository {
    
    private let remoteDataSource: IDiscoverRemoteDataSource
    private let discoverMapper: DiscoverMapper
    
    public init(remoteDataSource: IDiscoverRemoteDataSource, discoverMapper: DiscoverMapper) {
        self.remoteDataSource = remoteDataSource
        self.discoverMapper = discoverMapper
    }
    
    public func fetchDiscover(language: String, genreId: Int, page: Int) async throws -> DiscoverResultsEntity {
        do {
            let dto: DiscoverResultsDTO = try await remoteDataSource.fetchDiscover(language: language, genreId: genreId, page: page)
            return discoverMapper.map(dto: dto)
        } catch {
            throw error
        }
    }
}
