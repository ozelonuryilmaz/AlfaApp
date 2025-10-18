//
//  MoviePlayerVMLogic.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMoviePlayerVMLogic {
    var videoTitle: String { get }
    
    init(params: MoviePlayerParams)
    
    func formatTime(from seconds: Double) -> String
}

struct MoviePlayerVMLogic: IMoviePlayerVMLogic {
    
    private let movie: DiscoverResultUIModel
    
    init(params: MoviePlayerParams) {
        self.movie = params.movie
    }
    
    // Computed Properties
    
    var videoTitle: String {
        return movie.title
    }
    
    // Methods
    
    func formatTime(from seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else {  return "00:00" }
        let value = Int(seconds.rounded())
        let minutes = value / 60
        let secondsValue = value % 60
        return String(format: "%02d:%02d", minutes, secondsValue)
    }
}
