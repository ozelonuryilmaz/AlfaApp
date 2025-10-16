//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import AlfaDomain
import Foundation

public struct DiscoverMapper {
    
    public init() {}
    
    public func map(dto: DiscoverResultsDTO) -> DiscoverResultsEntity {
        let mappedDiscover = dto.results.map { map(dto: $0) }
        return DiscoverResultsEntity(page: dto.page, results: mappedDiscover, total_pages: dto.total_pages, total_results: dto.total_results)
    }
    
    private func map(dto: DiscoverResultDTO) -> DiscoverResultEntity {
        return DiscoverResultEntity(id: dto.id, title: dto.title, poster_path: dto.poster_path)
    }
}
