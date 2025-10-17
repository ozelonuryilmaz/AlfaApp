//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import Foundation

public protocol IMovieUrlUseCase {
    func execute() async throws -> URL
}

public struct MovieUrlUseCase: IMovieUrlUseCase {
    private let movieUrlRepository: IMovieUrlRepository

    public init(movieUrlRepository: IMovieUrlRepository) {
        self.movieUrlRepository = movieUrlRepository
    }

    public func execute() async throws -> URL {
        do {
            let movieUrl: URL = try await movieUrlRepository.fetchMovieUrl()
            return movieUrl
        } catch {
            throw error
        }
    }
}
