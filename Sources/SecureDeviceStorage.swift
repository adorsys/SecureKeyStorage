//
//  SecureDeviceStorage.swift
//  SecureDeviceStorage
//
//  Created by Johannes Steib on 08.03.17.
//
//

import LocalAuthentication

public enum SDSError: Error {
    case stringConversionError
    case unhandledError(status: OSStatus)
    case unexpectedError
    case itemNotFoundError
    case couldNotSaveItemError
}

/// Main class of the pod
public enum SecureDeviceStorage {

    /// A Boolean value indicating if the device is secured with a passcode.
    /// If the device has a passcode set the keychain is encrypted and can be
    /// used to securely store data without further encryption.
    public static var deviceHasPasscode: Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    /// Creates a `KeychainStore` object that saves and retrieves data from the
    /// keychain. The device has to have a passcode set to use the keychain store.
    ///
    /// - Parameters:
    ///   - name: The service name that is used to save and retrieve data.
    ///   - authenticationPrompt: A string that is displayed to the user when
    ///   retrieving data that is secured with touch id.
    /// - Returns: A `KeychainStore` object or nil when no passcode is set for
    /// the device.
    public static func keychainStore(name: String = defaultServiceName,
                                     authenticationPrompt: String? = nil) -> KeychainStore? {
        guard deviceHasPasscode else {
            return nil
        }
        return KeychainStore(service: name, authenticationPrompt: authenticationPrompt)
    }

    /// Creates an `EncryptedStore` object that saves and retrieves data that is
    /// encrypted with a password and is related to a user.
    ///
    /// - Parameters:
    ///   - name: The service name that is used to save and retrieve data.
    ///   - password: A password string that is used to encrypt/decrypt the data.
    ///   - user: A username that the data is related to.
    /// - Returns: An `EncryptedStore` object.
    public static func encryptedStore(name: String = defaultServiceName,
                                      password: String,
                                      user: String) -> EncryptedStore {
        return EncryptedStore(service: name, user: user, password: password)
    }

    /// A string that contains the default service name to use for secure stores.
    /// It's basically the identifier of the main bundle
    public static var defaultServiceName: String {
        return String(describing: Bundle.main.bundleIdentifier)
    }
}
