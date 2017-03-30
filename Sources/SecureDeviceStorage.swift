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
    
    public static func deviceHasPasscode() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    public static func keychainStore(name: String = SecureDeviceStorage.serviceName, authenticationPrompt: String? = nil) -> KeychainStore? {
        guard SecureDeviceStorage.deviceHasPasscode() else {
            return nil
        }
        return KeychainStore(service: name, authenticationPrompt: authenticationPrompt)
    }
    
    public static func encryptedStore(name: String = SecureDeviceStorage.serviceName, password: String, user: String) -> EncryptedStore {
        return EncryptedStore(service: name, user: user, password: password)
    }
    
    private static var serviceName: String {
        return String(describing: Bundle.main.bundleIdentifier)
    }
}
