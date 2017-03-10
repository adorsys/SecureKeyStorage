//
//  SecureDeviceStorage.swift
//  SecureDeviceStorage
//
//  Created by Johannes Steib on 08.03.17.
//
//

public enum SDSError: Error {
    case stringConversionError
    case unhandledError(status: OSStatus)
    case unexpectedError
    case itemNotFoundError
    case couldNotSaveItemError
}

import LocalAuthentication

public final class SecureDeviceStorage {
    
    public static func saveToKeychain(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
            throw SDSError.stringConversionError
        }
        try saveToKeychain(data, for: key)
    }
    
    public static func saveToKeychain(_ data: Data, for key: String) throws {
        try keychain.save(data, for: key)
    }
    
    public static func getStringFromKeychain(for key: String) throws -> String? {
        guard let data = try getDataFromKeychain(for: key) else {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw SDSError.stringConversionError
        }
        return string
    }
    
    public static func getDataFromKeychain(for key: String) throws -> Data? {
        return try keychain.get(key)
    }
    
    public static func removeFromKeychain(_ key: String) throws {
        try keychain.remove(key: key)
    }
    
    private static var keychain: KeychainService {
        let service = String(describing: Bundle.main.bundleIdentifier)
        return KeychainService(service: service)
    }
    
    public static func deviceHasPasscode() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
}

