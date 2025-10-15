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
    
    func handleResourceAsync<RESPONSE>(
        request: @escaping () async throws -> RESPONSE,
        errorState: ErrorStateSubject,
        callbackLoading: ((Bool) -> Void)? = nil,
        callbackSuccess: ((RESPONSE?) -> Void)? = nil,
        callbackComplete: (() -> Void)? = nil
    ) async {
        callbackLoading?(true)
        
        Task {
            do {
                let result = try await request()
                DispatchQueue.main.async {
                    callbackSuccess?(result)
                }
            } catch {
                errorState.value = "Bir Hata Oluştu" // TODO: Custom Error Handle yönetilmelidir.
            }
        }
        
        callbackLoading?(false)
        callbackComplete?()
    }
    
}
