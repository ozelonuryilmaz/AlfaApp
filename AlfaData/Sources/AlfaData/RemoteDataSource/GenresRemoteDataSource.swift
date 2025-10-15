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

    public init(networkManager: INetworkManager) {
        self.networkManager = networkManager
    }

    public func fetchGenres() async throws -> GenresDTO {
        
        guard let request = APIEndpoint.getProducts() else {
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
