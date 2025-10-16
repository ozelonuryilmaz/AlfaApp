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
    func fetchDiscover(genreId: Int, page: Int) async throws -> DiscoverResultsUIModel
}

final class MovieExplorerRepository: BaseRepository, IMovieExplorerRepository {
    
    private let genreUsecase: IGenresUseCase
    private let discoverUsecase: IDiscoverUseCase
    
    init(genreUsecase: IGenresUseCase,
         discoverUsecase: IDiscoverUseCase) {
        self.genreUsecase = genreUsecase
        self.discoverUsecase = discoverUsecase
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
    
    func fetchDiscover(genreId: Int, page: Int) async throws -> DiscoverResultsUIModel {
        do {
            let entity: DiscoverResultsEntity = try await discoverUsecase.execute(genreId: genreId, page: page)
            let mappedDiscover = entity.results.map { discoverEntity in
                return DiscoverResultUIModel(id: discoverEntity.id, title: discoverEntity.title, poster_path: discoverEntity.poster_path)
            }
            return DiscoverResultsUIModel(page: entity.page, results: mappedDiscover, total_pages: entity.total_pages, total_results: entity.total_results)
        }
        catch {
            throw error
        }
    }
}
