//
//  BaseViewModel.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation
import Combine

typealias ErrorStateSubject = CurrentValueSubject<String?, Never>
typealias ScreenStateSubject<T> = CurrentValueSubject<T?, Never>

class BaseViewModel {

    deinit {
        print("killed: \(type(of: self))")
    }
}
