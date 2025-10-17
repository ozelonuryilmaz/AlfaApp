//
//  MoviePlayerRepository.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation
import AlfaDomain

protocol IMoviePlayerRepository: AnyObject {
    func fetchMovieURL() async throws -> URL
}

final class MoviePlayerRepository: BaseRepository, IMoviePlayerRepository {
    private let movieUrlUsecase: IMovieUrlUseCase
    
    init(movieUrlUsecase: IMovieUrlUseCase) {
        self.movieUrlUsecase = movieUrlUsecase
    }
    
    func fetchMovieURL() async throws -> URL {
        do {
            let movieUrl: URL = try await movieUrlUsecase.execute()
            return movieUrl
        }
        catch {
            throw error
        }
    }
}
