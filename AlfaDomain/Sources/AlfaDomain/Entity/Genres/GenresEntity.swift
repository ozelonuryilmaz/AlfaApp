//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

public struct GenresEntity {
    
    public let genres: [GenreEntity]
    
    public init(genres: [GenreEntity]) {
        self.genres = genres
    }
}
