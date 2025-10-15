//
//  File.swift
//  AlfaData
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import Foundation
import FirebaseFunctions
import FirebaseAnalytics
import SecurityKit

public protocol ISecurityManager {
    func fetchSecureApiKey() async throws -> String
}

final public class SecurityManager: ISecurityManager {
    
    private let functions: Functions
    
    public init () {
        self.functions = Functions.functions(region: "europe-west1")
    }

    @MainActor
    public func fetchSecureApiKey() async throws -> String {
        try performEnvironmentChecks()
        return try await SecurityManager.fetchApiKeyFromCloud(functions: self.functions)
    }
    
    @MainActor
    private func performEnvironmentChecks() throws {
        if SecurityKit.isJailBroken() {
            SecurityManager.logSecurityBreach(type: "jailbreak_detected")
            throw SecurityError.deviceIsJailbroken
        }
        #if !DEBUG
        if SecurityKit.isDebugged() {
            SecurityManager.logSecurityBreach(type: "debugger_attached")
            throw SecurityError.debuggerIsAttached
        }
        #endif
    }
    
    private static func fetchApiKeyFromCloud(functions: Functions) async throws -> String {
        do {
            let result = try await functions.httpsCallable("getApiKey").call()
            guard let apiKey = (result.data as? [String: Any])?["apiKey"] as? String else {
                throw SecurityError.invalidResponse
            }
            return apiKey
        } catch let error {
            SecurityManager.logSecurityBreach(type: "api_key_function_call_error")
            throw SecurityError.requestFailed(error.localizedDescription)
        }
    }
    
    private static func logSecurityBreach(type: String) {
        Analytics.logEvent("security_breach", parameters: ["breach_type": type])
    }
}

enum SecurityError: LocalizedError {
    case deviceIsJailbroken
    case debuggerIsAttached
    case invalidResponse
    case requestFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .deviceIsJailbroken:
            "Uygulama, güvenliği ihlal edilmiş bir cihazda çalıştırılamaz."
        case .debuggerIsAttached:
            "Güvenlik nedeniyle, bir hata ayıklayıcı bağlıyken bu işlem gerçekleştirilemez."
        case .invalidResponse:
            "Sunucudan geçersiz veya beklenmedik bir yanıt alındı."
        case .requestFailed(let reason):
            "Güvenli anahtar alınamadı: \(reason)"
        }
    }
}
