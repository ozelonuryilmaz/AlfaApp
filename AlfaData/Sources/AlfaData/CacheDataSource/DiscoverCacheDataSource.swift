//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 19.10.2025.
//

import Foundation
import AlfaDomain

public protocol IDiscoverCacheDataSource: AnyObject {
    func getDiscoverResults(for genreId: Int) -> DiscoverResultsEntity?
    func saveDiscoverResults(_ results: DiscoverResultsEntity, for genreId: Int)
    func clearCache()
    func clearCache(for genreId: Int)
}

final public class DiscoverCacheDataSource: IDiscoverCacheDataSource {
    
    // TODO: in-memory yerine FileManager(Persistent Cache) tercih edilebilir. Cache 15 dakika da bir otomatik temizlenebilir
    // Repository'ye tam ve güncel liste doğrudan döndürülmesi sağlandı -> Cache temelleri atıldı
    
    // FIXME: *** Uygulama arkaplana atıldığında NSCache'i sistem temizleyebiliyor. Bu yüzden pagination sonrası ilk verilere(cache) ulaşılmayabilir. ***
    
    private let cache = NSCache<NSNumber, DiscoverCacheEntry>()
    
    public init() { }

    public func getDiscoverResults(for genreId: Int) -> DiscoverResultsEntity? {
        let key = NSNumber(value: genreId)
        guard let entry = cache.object(forKey: key) else {
            return nil
        }

        return entry.entity
    }

    public func saveDiscoverResults(_ results: DiscoverResultsEntity, for genreId: Int) {
        let key = NSNumber(value: genreId)
        let entry = DiscoverCacheEntry(entity: results)
        cache.setObject(entry, forKey: key)
    }

    public func clearCache() {
        cache.removeAllObjects()
    }
    
    public func clearCache(for genreId: Int) {
        let key = NSNumber(value: genreId)
        cache.removeObject(forKey: key)
    }
}


// MARK: DiscoverCacheEntry
final public class DiscoverCacheEntry {
    let entity: DiscoverResultsEntity
    let timestamp: Date
    
    public init(entity: DiscoverResultsEntity) {
        self.entity = entity
        self.timestamp = Date()
    }
}
