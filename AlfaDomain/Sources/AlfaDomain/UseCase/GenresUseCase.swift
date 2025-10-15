//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

public protocol IGenresUseCase {
    func execute() async throws -> GenresEntity
}

public struct GenresUseCase: IGenresUseCase {
    private let genresRepository: IGenresRepository

    public init(genresRepository: IGenresRepository) {
        self.genresRepository = genresRepository
    }

    public func execute() async throws -> GenresEntity {
        do {
            let genres: GenresEntity = try await genresRepository.fetchGenres()
            return genres
        } catch {
            throw error
        }
    }
}
