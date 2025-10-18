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
// import ConfidentialKit


// TODO: SecurityManager düzenlenmeler yapılmalı
// TODO: Jailbreak, ReverseEngineer,... tespitinde kısıtlama getir.
// TODO: ConfidentialKit kullanarak Code Obfuscation uygula

// TODO: Memory'de de hassas bilgiler tutulmadığı kontrol edilmelidir

public protocol ISecurityManager {
    func fetchSecureApiKey() async throws -> String
    func fetchSecureVideoUrl() async throws -> URL
}

final public class SecurityManager: ISecurityManager {
    
    private let functions: Functions
    
    public init () {
        self.functions = Functions.functions(region: "europe-west1")
    }
    
    private static func logSecurityBreach(type: String) {
        Analytics.logEvent("security_breach", parameters: ["breach_type": type])
    }
}


// MARK: ISecurityManager
public extension SecurityManager {

    @MainActor
    func fetchSecureApiKey() async throws -> String {
        try performEnvironmentChecks()
        return try await SecurityManager.fetchApiKeyFromCloud(functions: self.functions)
    }
    
    @MainActor
    func fetchSecureVideoUrl() async throws -> URL {
        try performEnvironmentChecks()
        return try await SecurityManager.fetchUrlFromCloud(functions: self.functions)
    }
}


// MARK: Security Checks
private extension SecurityManager {
    
    @MainActor
    func performEnvironmentChecks() throws {
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
}


// MARK: Fetch Key From Cloud
private extension SecurityManager {
    
    static func fetchApiKeyFromCloud(functions: Functions) async throws -> String {
        return try await fetchFromCloud(
            functions: functions,
            functionName: "getApiKey",
            resultKey: "apiKey",
            transform: { $0 as? String }
        )
    }
    
    static func fetchUrlFromCloud(functions: Functions) async throws -> URL {
        return try await fetchFromCloud(
            functions: functions,
            functionName: "getSecureVideoUrl",
            resultKey: "secureUrl",
            transform: { str in
                if let str = str as? String { return URL(string: str) }
                return nil
            }
        )
    }
    
    static func fetchFromCloud<T>(
        functions: Functions,
        functionName: String,
        resultKey: String,
        transform: (Any) -> T?
    ) async throws -> T {
        do {
            let result = try await functions.httpsCallable(functionName).call()
            guard let data = result.data as? [String: Any],
                  let value = transform(data[resultKey] ?? NSNull()) else {
                throw SecurityError.invalidResponse
            }
            return value
        } catch {
            SecurityManager.logSecurityBreach(type: "\(functionName)_function_call_error")
            throw SecurityError.requestFailed(error.localizedDescription)
        }
    }
}


// MARK: SecurityError
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
