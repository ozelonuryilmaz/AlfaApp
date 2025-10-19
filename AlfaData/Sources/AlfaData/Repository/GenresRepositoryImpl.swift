//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation
import AlfaDomain

final public class GenresRepositoryImpl: IGenresRepository {
    
    private let remoteDataSource: IGenresRemoteDataSource
    private let genresMapper: GenresMapper
    
    public init(remoteDataSource: IGenresRemoteDataSource, genresMapper: GenresMapper) {
        self.remoteDataSource = remoteDataSource
        self.genresMapper = genresMapper
    }
    
    public func fetchGenres(language: String) async throws -> GenresEntity {
        do {
            let dto: GenresDTO = try await remoteDataSource.fetchGenres(language: language)
            return genresMapper.map(dto: dto)
        } catch {
            throw error
        }
    }
}
