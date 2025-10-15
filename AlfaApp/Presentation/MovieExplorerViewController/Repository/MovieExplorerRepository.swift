//
//  MovieExplorerRepository.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation
import AlfaDomain

protocol IMovieExplorerRepository: AnyObject {
    
    func fetchGenres() async throws -> GenresUIModel
}

final class MovieExplorerRepository: BaseRepository, IMovieExplorerRepository {
    
    private let genreUsecase: IGenresUseCase
    
    init(genreUsecase: IGenresUseCase) {
        self.genreUsecase = genreUsecase
    }
    
    func fetchGenres() async throws -> GenresUIModel {
        do {
            let entity: GenresEntity = try await genreUsecase.execute()
            let mappedGenres = entity.genres.map { genreEntity in
                return GenreUIModel(id: genreEntity.id, name: genreEntity.name)
            }
            return GenresUIModel(genres: mappedGenres)
        }
        catch {
            throw error
        }
    }
}
