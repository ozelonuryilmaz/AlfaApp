//
//  MockScrollPositionService.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
import CoreGraphics
@testable import AlfaApp

final class MockScrollPositionService: IScrollPositionService {
    
    var stubbedPosition: CGPoint?
    
    private(set) var invokedSavePosition: Bool = false
    private(set) var invokedSavePositionParams: (offset: CGPoint, genreId: Int)?
    private(set) var invokedGetPosition: Bool = false
    private(set) var invokedClearCache: Bool = false
    
    func savePosition(_ offset: CGPoint, for genreId: Int) {
        invokedSavePosition = true
        invokedSavePositionParams = (offset, genreId)
    }
    
    func getPosition(for genreId: Int) -> CGPoint? {
        invokedGetPosition = true
        return stubbedPosition
    }
    
    func clearCache() {
        invokedClearCache = true
    }
}
