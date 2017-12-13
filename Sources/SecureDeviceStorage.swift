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

    public static func keychainStore(name: String = defaultServiceName,
                                     authenticationPrompt: String? = nil) -> KeychainStore? {
        guard SecureDeviceStorage.deviceHasPasscode() else {
            return nil
        }
        return KeychainStore(service: name, authenticationPrompt: authenticationPrompt)
    }

    public static func encryptedStore(name: String = defaultServiceName,
                                      password: String, user: String) -> EncryptedStore {
        return EncryptedStore(service: name, user: user, password: password)
    }

    public static var defaultServiceName: String {
        return String(describing: Bundle.main.bundleIdentifier)
    }
}
