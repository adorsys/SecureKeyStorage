//
//  KeychainStore.swift
//  SecureKeyStorage
//
//  Created by Johannes Steib on 16.03.17.
//
//

import Foundation

/// Saves data to and retrieves it from the keychain.
public class KeychainStore: SecurelyStoring {
    /// The service that does the actual operations on the keychain.
    private let keychain: KeychainService
    /// A string that is displayed to the user when
    /// retrieving data that is secured with touch id.
    var authenticationPrompt: String

    /// Creates a new keychain store with a service name and an optional
    /// authentication prompt
    ///
    /// - Parameters:
    ///   - service: The service name that is used to save and retrieve data.
    ///   - authenticationPrompt: A string that is displayed to the user when
    ///   retrieving data that is secured with touch id.
    public init(service: String, authenticationPrompt: String? = nil) {
        keychain = KeychainService(service: service)
        if let prompt = authenticationPrompt {
            self.authenticationPrompt = prompt
        } else {
            self.authenticationPrompt = ""
        }
    }

    public func save(_ data: Data, for key: String) throws {
        try keychain.save(data, for: key, withUserPresence: true)
    }

    public func getData(for key: String) throws -> Data {
        try keychain.get(key, with: authenticationPrompt)
    }

    public func remove(_ key: String) throws {
        try keychain.remove(key: key)
    }

    public func clear() throws {
        try keychain.clear()
    }
}
