//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import Foundation
import AlfaDomain

final public class MovieUrlRepositoryImpl: IMovieUrlRepository {
    
    private let remoteDataSource: IMovieUrlRemoteDataSource
    
    public init(remoteDataSource: IMovieUrlRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func fetchMovieUrl() async throws -> URL {
        do {
            let movieUrl: URL = try await remoteDataSource.fetchMovieUrl()
            return movieUrl
        } catch {
            throw error
        }
    }
}
