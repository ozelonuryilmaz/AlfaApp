//
//  MovieExplorerViewModel.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMovieExplorerViewModel: AnyObject {
    
    var viewState: ScreenStateSubject<MovieExplorerViewState> { get }
    var errorState: ErrorStateSubject { get }
    
    init(repository: IMovieExplorerRepository,
         coordinator: IMovieExplorerCoordinator,
         vmLogic: IMovieExplorerVMLogic)
}

final class MovieExplorerViewModel: BaseViewModel, IMovieExplorerViewModel {
    
    // MARK: Definitions
    private let repository: IMovieExplorerRepository
    private let coordinator: IMovieExplorerCoordinator
    private var vmLogic: IMovieExplorerVMLogic
    
    // MARK: Props
    var viewState = ScreenStateSubject<MovieExplorerViewState>(nil)
    var errorState = ErrorStateSubject(nil)
    
    // MARK: Initiliazer
    required init(repository: IMovieExplorerRepository,
                  coordinator: IMovieExplorerCoordinator,
                  vmLogic: IMovieExplorerVMLogic) {
        self.repository = repository
        self.coordinator = coordinator
        self.vmLogic = vmLogic
        super.init()
        
        loadGenres()
    }
    
}


// MARK: Service
internal extension MovieExplorerViewModel {
    
    func loadGenres() {
        Task { @MainActor in
            do {
                let genres = try await repository.fetchGenres() // await sonrası default background thread'e geçecek
                print("Log *** genres: \(genres) *** ")
            } catch {
                errorState.value = error.localizedDescription
            }
        }
    }

}

// MARK: States
internal extension MovieExplorerViewModel {
    
    // MARK: View State
    func viewStateShowLoadingProgress(isProgress: Bool) {
        viewState.value = .showLoadingProgress(isProgress: isProgress)
    }
    
}

// MARK: Coordinate
internal extension MovieExplorerViewModel {
    
}

enum MovieExplorerViewState {
    case showLoadingProgress(isProgress: Bool)
}
