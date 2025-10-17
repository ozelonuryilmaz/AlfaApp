//
//  MovieCacheService.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

protocol IMovieCacheService: AnyObject {
    func cache(entry: GenreCacheEntry, for genreId: Int)
    func getEntry(for genreId: Int) -> GenreCacheEntry?
    func updateContentOffset(_ offset: CGPoint, for genreId: Int)
}

final class MovieCacheService: IMovieCacheService {

    private let queue: DispatchQueue
    private var cache: [Int: GenreCacheEntry] = [:]
    
    init() {
        self.queue = DispatchQueue(label: "com.ozelonuryilmaz.alfaapp.moviecache.queue", attributes: .concurrent)
    }

    func getEntry(for genreId: Int) -> GenreCacheEntry? {
        var entry: GenreCacheEntry?
        queue.sync { entry = self.cache[genreId] }
        return entry
    }

    func cache(entry: GenreCacheEntry, for genreId: Int) {
        queue.async(flags: .barrier) { self.cache[genreId] = entry }
    }

    func updateContentOffset(_ offset: CGPoint, for genreId: Int) {
        queue.async(flags: .barrier) {
            if self.cache[genreId] != nil {
                self.cache[genreId]?.lastContentOffset = offset
            }
        }
    }
}
