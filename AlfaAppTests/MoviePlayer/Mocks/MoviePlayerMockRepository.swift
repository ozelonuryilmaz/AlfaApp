//
//  MoviePlayerMockRepository.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
@testable import AlfaApp
// @testable import AlfaDomain

final class MockMoviePlayerRepository: IMoviePlayerRepository {
    
    /// Bu 'Result' test senaryosuna göre ayarlanıyor (stub).
    /// .success(URL) veya .failure(Error) alabilir
    var fetchURLResult: Result<URL, Error>!

    func fetchMovieURL() async throws -> URL {
        // 'fetchURLResult' set edilmemişse testin çökmesini sağlanıyor
        try fetchURLResult.get()
    }
}
