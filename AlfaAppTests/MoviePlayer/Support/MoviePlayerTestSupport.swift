//
//  MoviePlayerTestSupport.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
import Combine
@testable import AlfaApp

// MARK: Mock Error
struct MockError: Error, Equatable {
    let id = UUID()
    let description: String
}

// MARK: ValueCollector
/// Combine Publisher'larını test etmek için kullanılan yardımcı bir sınıf.
/// Bir publisher'a abone olur ve yayınlanan tüm değerleri bir dizide toplar.
final class ValueCollector<T> {
    var values: [T] = []
    private var cancellable: AnyCancellable?
    private let lock = NSLock() // Thread-safety için

    /// `Never` failure tipindeki publisher'lar için (örn: Subject.send())
    init(_ publisher: any Publisher<T, Never>) {
        cancellable = publisher
            .sink { [weak self] value in
                self?.lock.lock()
                self?.values.append(value)
                self?.lock.unlock()
            }
    }
    
    /// `Error` failure tipindeki publisher'lar için (örn: dataTaskPublisher)
    init<E: Error>(_ publisher: any Publisher<T, E>) {
        cancellable = publisher
            .sink(receiveCompletion: { _ in
                // Tamamlanma durumunu (completion) şu an için göz ardı ediyoruz.
            }, receiveValue: { [weak self] value in
                self?.lock.lock()
                self?.values.append(value)
                self?.lock.unlock()
            })
    }
}


// MARK: Equatable for ViewState
// Testlerde XCTAssertEqual kullanabilmek için ViewState'i Equatable yapmamız gerekiyor.
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
