//
//  GenreUseCaseProvider.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import AlfaData
import AlfaDomain

enum GenreUseCaseProvider {
    
    static func makeGenreUseCase() -> IGenresUseCase {
        let networkManager: INetworkManager = NetworkManager()
        let securityManager: ISecurityManager = SecurityManager()
        let remoteDataSource: IGenresRemoteDataSource = GenresRemoteDataSource(networkManager: networkManager, securityManager: securityManager)
        
        let genresMapper: GenresMapper = GenresMapper()
        let genresRepositoryImpl: IGenresRepository = GenresRepositoryImpl(remoteDataSource: remoteDataSource, genresMapper: genresMapper)
        
        let genreUsecase: IGenresUseCase = GenresUseCase(genresRepository: genresRepositoryImpl)
        
        return genreUsecase
    }
}
