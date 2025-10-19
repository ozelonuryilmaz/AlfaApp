//
//  DeviceLanguageProvider.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 19.10.2025.
//

import Foundation

protocol IDeviceLanguageProvider {
    var currentLanguageCode: String { get }
}

final class DeviceLanguageProvider: IDeviceLanguageProvider {
    
    private let defaultLocale: String = "en-US"
    
    init() { }
    
    var currentLanguageCode: String {
        let preferredLanguage = Locale.preferredLanguages.first ?? defaultLocale
        let languageCode = Locale(identifier: preferredLanguage).languageCode ?? "en"
        switch languageCode {
        case "tr": return "tr-TR"
        case "en": return "en-US"
        default: return defaultLocale
        }
    }
}
