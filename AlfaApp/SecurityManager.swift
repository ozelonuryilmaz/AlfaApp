//
//  SecurityManager.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 14.10.2025.
//

import Foundation
import FirebaseFunctions
import FirebaseAnalytics
import SecurityKit

enum SecurityError: LocalizedError {
    case deviceIsJailbroken
    case debuggerIsAttached
    case urlRequestFailed(String)

    var errorDescription: String? {
        switch self {
        case .deviceIsJailbroken: "Uygulama, güvenliği ihlal edilmiş bir cihazda çalıştırılamaz."
        case .debuggerIsAttached: "Güvenlik nedeniyle, bir hata ayıklayıcı bağlıyken video oynatılamaz."
        case .urlRequestFailed(let reason): "Video adresi alınamadı: \(reason)"
        }
    }
}

@MainActor
final class SecurityManager {
    static let shared = SecurityManager()
    private lazy var functions = Functions.functions(region: "europe-west1")

    private init() {}

    private func performEnvironmentChecks() throws {
        if SecurityKit.isJailBroken() {
            logSecurityBreach(type: "jailbreak_detected")
            throw SecurityError.deviceIsJailbroken
        }
        #if !DEBUG
        if SKDebugger.isDebuggerAttached() {
            logSecurityBreach(type: "debugger_attached")
            throw SecurityError.debuggerIsAttached
        }
        #endif
    }

    private func logSecurityBreach(type: String) {
        Analytics.logEvent("security_breach", parameters: ["breach_type": type])
    }

    func fetchSecureVideoUrl(completion: @escaping (Result<URL, Error>) -> Void) {
        do {
            try performEnvironmentChecks()
        } catch {
            completion(.failure(error))
            return
        }

        functions.httpsCallable("getSecureVideoUrl").call { result, error in
            if let error = error {
                completion(.failure(SecurityError.urlRequestFailed(error.localizedDescription)))
                return
            }
            if let urlString = (result?.data as? [String: Any])?["secureUrl"] as? String,
               let secureUrl = URL(string: urlString) {
                completion(.success(secureUrl))
            } else {
                completion(.failure(SecurityError.urlRequestFailed("Geçersiz sunucu yanıtı.")))
            }
        }
    }
}
