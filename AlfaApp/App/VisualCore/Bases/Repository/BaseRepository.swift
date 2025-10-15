//
//  BaseRepository.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import Combine

protocol IBaseRepository: AnyObject {
    
}

class BaseRepository: IBaseRepository {
    
    var cancelBag = Set<AnyCancellable>()
    
    deinit {
        print("killed: \(type(of: self))")
    }
    
}
