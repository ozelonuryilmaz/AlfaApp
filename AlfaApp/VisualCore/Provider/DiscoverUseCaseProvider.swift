//
//  DiscoverUseCaseProvider.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import AlfaData
import AlfaDomain

enum DiscoverUseCaseProvider {
    
    static func makeDiscoverUseCase() -> IDiscoverUseCase {
        let networkManager: INetworkManager = NetworkManager()
        let securityManager: ISecurityManager = SecurityManager()
        let remoteDataSource: IDiscoverRemoteDataSource = DiscoverRemoteDataSource(networkManager: networkManager, securityManager: securityManager)
        let discoverMapper: DiscoverMapper = DiscoverMapper()
        let discoverRepositoryImpl: IDiscoverRepository = DiscoverRepositoryImpl(remoteDataSource: remoteDataSource, discoverMapper: discoverMapper)
        let discoverUsecase: IDiscoverUseCase = DiscoverUseCase(discoverRepository: discoverRepositoryImpl)
        
        return discoverUsecase
    }
}
