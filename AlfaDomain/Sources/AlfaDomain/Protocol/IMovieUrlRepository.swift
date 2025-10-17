//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import Foundation

public protocol IMovieUrlRepository {
    func fetchMovieUrl() async throws -> URL
}
