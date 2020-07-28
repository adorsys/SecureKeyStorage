//
//  EncryptedStore.swift
//  SecureKeyStorage
//
//  Created by Johannes Steib on 16.03.17.
//
//

import Foundation

/// Saves and retrieves data that is encrypted with a password.
public class EncryptedStore: SecurelyStoring {
    /// The service that does the actual encryption and decryption operations.
    let secureStore: EncryptedStorageService

    /// Creates a new encrypted store with a service name that is related to a
    /// user and uses a given password for encryption/decryption.
    ///
    /// - Parameters:
    ///   - service: The service name that is used to save and retrieve data.
    ///   - user: A username that the data is related to.
    ///   - password: A password string that is used to encrypt/decrypt the data.
    ///   Make sure to use a safe password here.
    public init(service: String, user: String, password: String) {
        secureStore = EncryptedStorageService(service: service,
                                              password: password,
                                              user: user)
    }

    public func save(_ data: Data, for key: String) throws {
        try secureStore.save(data, for: key)
    }

    public func getData(for key: String) throws -> Data {
        try secureStore.get(key)
    }

    public func remove(_ key: String) throws {
        try secureStore.remove(key)
    }

    public func clear() throws {
        try secureStore.clear()
    }
}
