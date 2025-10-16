//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

public protocol IDiscoverRemoteDataSource {
    func fetchDiscover(genreId: Int, page: Int) async throws -> DiscoverResultsDTO
}

final public class DiscoverRemoteDataSource: IDiscoverRemoteDataSource {
    private let networkManager: INetworkManager
    private let securityManager: ISecurityManager

    public init(networkManager: INetworkManager,
                securityManager: ISecurityManager) {
        self.networkManager = networkManager
        self.securityManager = securityManager
    }

    public func fetchDiscover(genreId: Int, page: Int) async throws -> DiscoverResultsDTO {
        
        let apiKey: String = try await securityManager.fetchSecureApiKey()
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "with_genres", value: String(genreId)),
                                          URLQueryItem(name: "page", value: String(page))]
        
        guard let request: URLRequest = try? APIRequest.discover.buildRequest(apiKey: apiKey, extraQueryItems: queryItems) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let dtos: DiscoverResultsDTO = try await networkManager.request(endpoint: request)
            return dtos
        } catch {
            throw error
        }
    }
}
