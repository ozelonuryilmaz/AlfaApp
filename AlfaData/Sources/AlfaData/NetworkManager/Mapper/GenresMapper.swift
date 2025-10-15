//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import AlfaDomain
import Foundation

public struct GenresMapper {
    
    public init() {}
    
    public func map(dto: GenresDTO) -> GenresEntity {
        let mappedGenres = dto.genres.map { map(genreDto: $0) }
        return GenresEntity(genres: mappedGenres)
    }
    
    private func map(genreDto: GenreDTO) -> GenreEntity {
        return GenreEntity(id: genreDto.id, name: genreDto.name)
    }
}
