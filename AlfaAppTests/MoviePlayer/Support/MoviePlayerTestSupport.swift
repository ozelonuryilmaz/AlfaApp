//
//  MoviePlayerTestSupport.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
@testable import AlfaApp

// MARK: Equatable for ViewState

// XCTAssertEqual ile view state'lerini karşılaştırabilmek için gereklidir.
extension MoviePlayerViewState: Equatable {
    public static func == (lhs: MoviePlayerViewState, rhs: MoviePlayerViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading(let l), .loading(let r)):
            return l == r
        case (.videoLoaded(let lUrl, let lTitle), .videoLoaded(let rUrl, let rTitle)):
            return lUrl == rUrl && lTitle == rTitle
        case (.play, .play):
            return true
        case (.pause, .pause):
            return true
        case (.seek(let lSec), .seek(let rSec)):
            // Double karşılaştırmalarında küçük farkları tolere et
            return abs(lSec - rSec) < 0.001
        case (.updateProgress(let lProg, let lTime), .updateProgress(let rProg, let rTime)):
            return lProg == rProg && lTime == rTime
        case (.updateDurationText(let l), .updateDurationText(let r)):
            return l == r
        default:
            return false
        }
    }
}
