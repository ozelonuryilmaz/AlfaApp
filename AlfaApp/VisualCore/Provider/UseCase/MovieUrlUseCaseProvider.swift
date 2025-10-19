//
//  MovieUrlUseCaseProvider.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import AlfaData
import AlfaDomain

enum MovieUrlUseCaseProvider {
    
    static func makeMovieUrlUseCase() -> IMovieUrlUseCase {
        let securityManager: ISecurityManager = SecurityManager()
        let remoteDataSource: IMovieUrlRemoteDataSource = MovieUrlRemoteDataSource(securityManager: securityManager)
        
        let movieUrlRepositoryImpl: IMovieUrlRepository = MovieUrlRepositoryImpl(remoteDataSource: remoteDataSource)
        
        let movieUrlUsecase: IMovieUrlUseCase = MovieUrlUseCase(movieUrlRepository: movieUrlRepositoryImpl)
        
        return movieUrlUsecase
    }
}
