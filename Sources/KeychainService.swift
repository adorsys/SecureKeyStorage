//
//  KeychainService.swift
//  SecureDeviceStorage
//
//  Created by Johannes Steib on 09.03.17.
//
//

import Foundation

/// Saves data to the keychain and retrieves it from there.
internal class KeychainService {
    /// A string that contains the service name that is used for the keychain.
    let service: String
    /// A string that describes the access group for the keychain.
    let accessGroup: String?

    /// Creates a new keychain service object.
    ///
    /// - Parameters:
    ///   - service: A string that contains the service name that is used for the keychain.
    ///   - accessGroup: A string that describes the access group for the keychain.
    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    /// Saves data for a given key to the keychain.
    ///
    /// - Parameters:
    ///   - data: The data that will be saved to the keychain.
    ///   - key: A key used to identify the data in the keychain.
    ///   - protection: A boolean that indicated whether the data should be saved
    ///   retrieved only when entering der device passcode or using touch id.
    /// - Throws: An error if the save operation failed.
    internal func save(_ data: Data, for key: String, withUserPresence protection: Bool = true) throws {

        try remove(key: key)

        var query = keychainQuery(forKey: key)

        if protection {
            var error: Unmanaged<CFError>?
            let protectionRef = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as CFTypeRef
            guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                      protectionRef,
                                                                      .userPresence,
                                                                      &error)
                else {
                    if let error = error?.takeUnretainedValue() {
                        throw error
                    } else {
                        debugPrint("save: something unexpectedly went wrong")
                        throw SDSError.unexpectedError
                    }
            }
            query[kSecAttrAccessControl as String] = accessControl
        } else {
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }

        query[kSecValueData as String] = data
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            debugPrint("save: \(status)")
            throw SDSError.unhandledError(status: status)
        }
    }

    /// Retrieves data for a given key from the keychain.
    ///
    /// - Parameters:
    ///   - key: A key for that the data should be retrieved.
    ///   - prompt: An optional string that will be shown to the user when prompting
    ///   to give the touch id.
    /// - Returns: The data that is stored in the keychain for the given key.
    /// - Throws: An error if no data could be retrieved.
    internal func get(_ key: String, with prompt: String? = nil) throws -> Data {
        var query = keychainQuery(forKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanFalse
        query[kSecReturnData as String] = kCFBooleanTrue
        if let authPrompt = prompt {
            query[kSecUseOperationPrompt as String] = authPrompt
        }

        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)

        guard status != errSecItemNotFound else {
            debugPrint("get: item not found")
            throw SDSError.itemNotFoundError
        }
        guard status == noErr else {
            debugPrint("get: unhandled error")
            throw SDSError.unhandledError(status: status)
        }
        guard let data = queryResult as? Data else {
            debugPrint("get: item not found in result")
            throw SDSError.itemNotFoundError
        }
        return data
    }

    internal func remove(key: String) throws {
        let query = keychainQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            debugPrint("delete: \(status)")
            throw SDSError.unhandledError(status: status)
        }
    }

    /// Removes all data from the keychain with the given service name.
    ///
    /// - Throws: An error if the operation failed.
    internal func clear() throws {
        var query = keychainQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SDSError.unhandledError(status: status)
        }
    }

    /// Creates the query dictionary for a given key. It ca be used to save or
    /// retrieve data from the keychain.
    ///
    /// - Parameter key: A key that is used for the keychain query.
    /// - Returns: A query dictionary.
    private func keychainQuery(forKey key: String? = nil) -> [String: Any] {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service

        if let account = key {
            query[kSecAttrAccount as String] = account
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}
