//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

public protocol IGenresRemoteDataSource {
    func fetchGenres(language: String) async throws -> GenresDTO
}

final public class GenresRemoteDataSource: IGenresRemoteDataSource {
    private let networkManager: INetworkManager
    private let securityManager: ISecurityManager

    public init(networkManager: INetworkManager,
                securityManager: ISecurityManager) {
        self.networkManager = networkManager
        self.securityManager = securityManager
    }

    public func fetchGenres(language: String) async throws -> GenresDTO {
        
        let apiKey: String = try await securityManager.fetchSecureApiKey()
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "language", value: language)]
        
        guard let request: URLRequest = try? APIRequest.genres.buildRequest(apiKey: apiKey, extraQueryItems: queryItems) else {
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
