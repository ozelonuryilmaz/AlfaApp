//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import Foundation

public protocol IMovieUrlRemoteDataSource {
    func fetchMovieUrl() async throws -> URL
}

final public class MovieUrlRemoteDataSource: IMovieUrlRemoteDataSource {
    private let securityManager: ISecurityManager

    public init(securityManager: ISecurityManager) {
        self.securityManager = securityManager
    }

    public func fetchMovieUrl() async throws -> URL {
        
        do {
            let movieUrl: URL = try await securityManager.fetchSecureVideoUrl()
            return movieUrl
        } catch {
            throw error
        }
    }
}

