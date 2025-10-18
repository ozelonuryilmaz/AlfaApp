//
//  MovieExplorerMockCacheService.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
import CoreGraphics
@testable import AlfaApp

final class MockMovieCacheService: IMovieCacheService {
    
    var stubbedEntry: GenreCacheEntry?
    
    private(set) var invokedGetEntry: Bool = false
    private(set) var invokedCache: Bool = false
    private(set) var invokedUpdateContentOffset: Bool = false
    private(set) var invokedUpdateContentOffsetParams: (offset: CGPoint, genreId: Int)?

    private var cache: [Int: GenreCacheEntry] = [:]

    func getEntry(for genreId: Int) -> GenreCacheEntry? {
        invokedGetEntry = true
        return stubbedEntry ?? cache[genreId]
    }

    func cache(entry: GenreCacheEntry, for genreId: Int) {
        invokedCache = true
        cache[genreId] = entry
    }

    func updateContentOffset(_ offset: CGPoint, for genreId: Int) {
        invokedUpdateContentOffset = true
        invokedUpdateContentOffsetParams = (offset, genreId)
        cache[genreId]?.lastContentOffset = offset
    }
}
