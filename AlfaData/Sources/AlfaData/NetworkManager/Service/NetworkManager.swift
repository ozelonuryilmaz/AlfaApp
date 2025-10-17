//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

public protocol INetworkManager {
    func request<T: Decodable>(endpoint: URLRequest) async throws -> T
}

public final class NetworkManager: INetworkManager{
    
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // TODO: Timeout,.. kurgulanmalı.
    
    public func request<T>(endpoint: URLRequest) async throws -> T where T : Decodable {
        let (data, response) = try await urlSession.data(for: endpoint)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        do {
            let decodeData = try JSONDecoder().decode(T.self, from: data)
            return decodeData
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
