//
//  MovieItemViewModel.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation

struct MovieItemViewModel: Hashable {
    let movie: DiscoverResultUIModel
    
    // API'den aynı film ID'si gelse bile, bu UUID her zaman benzersiz olacaktır.
    private let uniqueId = UUID()
    
    static func == (lhs: MovieItemViewModel, rhs: MovieItemViewModel) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }
}
