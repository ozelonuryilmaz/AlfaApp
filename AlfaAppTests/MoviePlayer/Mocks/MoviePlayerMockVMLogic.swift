//
//  MoviePlayerMockVMLogic.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
@testable import AlfaApp

final class MockMoviePlayerVMLogic: IMoviePlayerVMLogic {
    
    var stubbedVideoTitle: String = "Default Mock Title"
    
    var formatTimeHandler: ((Double) -> String)?

    // MARK: IMoviePlayerVMLogic
    
    var videoTitle: String {
        return stubbedVideoTitle
    }
    
    init(params: MoviePlayerParams) {
        // Mock olduğu için 'params'ı kullanmıyoruz, ancak protokol gereği init mevcut.
    }
    
    func formatTime(from seconds: Double) -> String {
        // Eğer özel bir işleyici (handler) tanımlandıysa onu kullan,
        // yoksa varsayılan bir değer döndür.
        if let handler = formatTimeHandler {
            return handler(seconds)
        }
        
        return "00:00"
    }
}
