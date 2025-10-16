//
//  MovieExplorerVMLogic.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

enum SwipeDirection {
    case next
    case previous
}

protocol IMovieExplorerVMLogic {
    func calculateIndex(for direction: SwipeDirection, currentIndex: Int, totalCount: Int) -> Int?
}

struct MovieExplorerVMLogic: IMovieExplorerVMLogic {

    func calculateIndex(for direction: SwipeDirection, currentIndex: Int, totalCount: Int) -> Int? {
        guard totalCount > 0 else { return nil }
        
        var newIndex: Int
        switch direction {
        case .next:
            newIndex = currentIndex + 1
            // Listenin sonuna ulaştıysa daha ileri gitme
            if newIndex >= totalCount {
                return nil
            }
        case .previous:
            newIndex = currentIndex - 1
            // Listenin başına ulaştıysa daha geri gitme
            if newIndex < 0 {
                return nil
            }
        }
        return newIndex
    }
}
