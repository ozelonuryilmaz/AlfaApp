//
//  MoviePlayerVMLogicTests.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import XCTest
import Combine
@testable import AlfaApp

final class MoviePlayerVMLogicTests: XCTestCase {

    private var mockMovieModel: DiscoverResultUIModel!
    private var mockParams: MoviePlayerParams!
    private var sut: MoviePlayerVMLogic! // System Under Test

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // [GIVEN]
        mockMovieModel = DiscoverResultUIModel(
            id: 123,
            title: "Test Filmi Başlığı",
            posterURL: URL(string: "https://example.com/poster.jpg")
        )
        
        mockParams = MoviePlayerParams(movie: mockMovieModel)
        sut = MoviePlayerVMLogic(params: mockParams)
    }

    override func tearDownWithError() throws {
        mockMovieModel = nil
        mockParams = nil
        sut = nil
        try super.tearDownWithError()
    }

    func test_videoTitle_returnsCorrectTitle() {
        // [WHEN]
        let title = sut.videoTitle
        
        // [THEN]
        XCTAssertEqual(title, "Test Filmi Başlığı")
    }
    
    func test_formatTime_withValidSeconds() {
        // [WHEN]
        let formattedTime = sut.formatTime(from: 95.0) // 1 dakika 35 saniye
        
        // [THEN]
        XCTAssertEqual(formattedTime, "01:35")
    }

    func test_formatTime_withZeroSeconds() {
        // [WHEN]
        let formattedTime = sut.formatTime(from: 0.0)
        
        // [THEN]
        XCTAssertEqual(formattedTime, "00:00")
    }
    
    func test_formatTime_withRounding() {
        // [WHEN]
        let formattedTime = sut.formatTime(from: 59.8) // 60 saniyeye yuvarlanmalı -> 01:00
        
        // [THEN]
        XCTAssertEqual(formattedTime, "01:00")
    }

    func test_formatTime_withInvalidNaN() {
        // [WHEN]
        let formattedTime = sut.formatTime(from: .nan)
        
        // [THEN]
        XCTAssertEqual(formattedTime, "00:00", "NaN değerleri '00:00' olarak dönmelidir.")
    }
    
    func test_formatTime_withNegativeSeconds() {
        // [WHEN]
        let formattedTime = sut.formatTime(from: -30.0)
        
        // [THEN]
        XCTAssertEqual(formattedTime, "00:00", "Negatif değerler '00:00' olarak dönmelidir.")
    }
}


