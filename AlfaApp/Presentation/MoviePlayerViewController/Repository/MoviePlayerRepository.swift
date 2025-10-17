//
//  MoviePlayerRepository.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMoviePlayerRepository: AnyObject {
    func fetchMovieURL() async throws -> URL
}

final class MoviePlayerRepository: BaseRepository, IMoviePlayerRepository {
    
    func fetchMovieURL() async throws -> URL {
        
        // TODO: Data katmanından secureVideoURL ile getirilecek
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8") else {
            throw URLError(.badURL)
        }
        return url
    }
}
