//
//  ValueCollector.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
import Combine

/// Combine Publisher'larını test etmek için kullanılan yardımcı bir sınıf.
final class ValueCollector<T> {
    var values: [T] = []
    private var cancellable: AnyCancellable?
    private let lock = NSLock() // Thread-safety için

    /// `Never` failure tipindeki publisher'lar için
    init(_ publisher: any Publisher<T, Never>) {
        cancellable = publisher
            .sink { [weak self] value in
                self?.lock.lock()
                self?.values.append(value)
                self?.lock.unlock()
            }
    }
    
    /// `Error` failure tipindeki publisher'lar için
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
