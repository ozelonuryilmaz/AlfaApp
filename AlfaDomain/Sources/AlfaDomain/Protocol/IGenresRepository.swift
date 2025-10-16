//
//  File.swift
//  AlfaDomain
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Foundation

public protocol IGenresRepository {
    func fetchGenres() async throws -> GenresEntity
}
