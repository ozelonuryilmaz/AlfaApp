//
//  MockError.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation

struct MockError: Error, Equatable {
    let id = UUID()
    let description: String
}
