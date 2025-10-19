//
//  ScrollPositionCacheService.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 19.10.2025.
//

import Foundation
import CoreGraphics

protocol IScrollPositionService: AnyObject {
    func savePosition(_ offset: CGPoint, for genreId: Int)
    func getPosition(for genreId: Int) -> CGPoint?
    func clearCache()
}

final class ScrollPositionService: IScrollPositionService {
    private var positions: [Int: CGPoint] = [:]
    private let queue = DispatchQueue(label: "com.ozelonuryilmaz.alfaapp.scrollposition.queue", attributes: .concurrent)
    
    func savePosition(_ offset: CGPoint, for genreId: Int) {
        queue.async(flags: .barrier) { [weak self] in
            self?.positions[genreId] = offset
        }
    }
    
    func getPosition(for genreId: Int) -> CGPoint? {
        var position: CGPoint?
        queue.sync {
            position = self.positions[genreId]
        }
        return position
    }
    
    func clearCache() {
        queue.async(flags: .barrier) { [weak self] in
            self?.positions.removeAll(keepingCapacity: false)
        }
    }
}

