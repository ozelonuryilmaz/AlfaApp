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
    private let cacheDataSource: IDiscoverCacheDataSource
    private let discoverMapper: DiscoverMapper
    
    public init(remoteDataSource: IDiscoverRemoteDataSource,
                cacheDataSource: IDiscoverCacheDataSource,
                discoverMapper: DiscoverMapper) {
        self.remoteDataSource = remoteDataSource
        self.cacheDataSource = cacheDataSource
        self.discoverMapper = discoverMapper
    }
    
    // TODO: forceRefresh parametresi kaldırılabilir
    public func fetchDiscover(language: String, genreId: Int, page: Int, forceRefresh: Bool = false) async throws -> DiscoverResultsEntity {
        if forceRefresh && page == 1 {
            cacheDataSource.clearCache(for: genreId)
        }
        
        if !forceRefresh, let cachedEntity = cacheDataSource.getDiscoverResults(for: genreId) {
            if page <= cachedEntity.page {
                return cachedEntity
            }
        }
        
        let dto = try await remoteDataSource.fetchDiscover(language: language, genreId: genreId, page: page)
        let newEntity = discoverMapper.map(dto: dto)
        
        var existingEntity = cacheDataSource.getDiscoverResults(for: genreId)
        
        // Tam liste doğrudan döndürülmesi sağlandı
        // FIXME: *** Uygulama arkaplana atıldığında NSCache'i sistem temizleyebiliyor. Bu yüzden pagination sonrası ilk verilere ulaşılmayabilir. ***
        
        if existingEntity != nil {
            let existingIDs = Set(existingEntity!.results.map { $0.id })
            let uniqueNewResults = newEntity.results.filter { !existingIDs.contains($0.id) }
            
            existingEntity!.results.append(contentsOf: uniqueNewResults)
            existingEntity!.page = newEntity.page
        } else {
            existingEntity = newEntity
        }

        cacheDataSource.saveDiscoverResults(existingEntity!, for: genreId)
        
        return existingEntity!
    }
    
    public func clearCache() {
        cacheDataSource.clearCache()
    }
}

