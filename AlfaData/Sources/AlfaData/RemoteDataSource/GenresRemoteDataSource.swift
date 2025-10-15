//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

public protocol IGenresRemoteDataSource {
    func fetchGenres() async throws -> GenresDTO
}

final public class GenresRemoteDataSource: IGenresRemoteDataSource {
    private let networkManager: INetworkManager
    private let securityManager: ISecurityManager

    public init(networkManager: INetworkManager,
                securityManager: ISecurityManager) {
        self.networkManager = networkManager
        self.securityManager = securityManager
    }

    public func fetchGenres() async throws -> GenresDTO {
        
        let apiKey: String = try await securityManager.fetchSecureApiKey()
        
        guard let request = try? APIRequest.genres.buildRequest(apiKey: apiKey) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let dtos: GenresDTO = try await networkManager.request(endpoint: request)
            return dtos
        } catch {
            throw error
        }
    }
}
