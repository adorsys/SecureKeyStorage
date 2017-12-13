//
//  EncryptedStorageService.swift
//  SecureDeviceStorage
//
//  Created by Johannes Steib on 10.03.17.
//
//

import Foundation
import RNCryptor

/// Encryptes and saves data or retrieves and decrypts it.
internal class EncryptedStorageService {
    /// A string that describes the user to whom the data is related to.
    let user: String
    /// A string that contains the password that is used for encrypting and
    /// decripting the data.
    let password: String
    /// The service that is used to save to and retrieve data from the keychain.
    let keychain: KeychainService

    /// Creates a new encrypted storage service.
    ///
    /// - Parameters:
    ///   - service: The service name that is used to save and retrieve data.
    ///   - accessGroup: An optional string for the keychain access group.
    ///   - password: A string that is used to encrypt and decrypt the data.
    ///   - user: A string that is used to identify the user who saved the data.
    internal init(service: String, accessGroup: String? = nil, password: String, user: String) {
        self.password = password
        self.user = user
        keychain = KeychainService(service: service, accessGroup: accessGroup)
    }

    /// Encrypts and saves data for a given key.
    ///
    /// - Parameters:
    ///   - data: The data to be encrypted and saved.
    ///   - key: A key that is used to save the data.
    /// - Throws: An error when the encryption or saving operation could no be
    /// performed.
    internal func save(_ data: Data, for key: String) throws {
        do {
            let (encryptionKey, hmacKey) = try getOrCreateKeys()
            let encryptedData = encrypt(data, with: encryptionKey, hmac: hmacKey)
            try keychain.save(encryptedData, for: key, withUserPresence: false)
        } catch {
            throw SDSError.couldNotSaveItemError
        }
    }

    /// Retrieves data for a given key and decrypts it.
    ///
    /// - Parameter key: A key for which the data is to be retrieved.
    /// - Returns: The decrypted data that was requested for the given key.
    /// - Throws: An error if the data could not be retrieved or decrypted.
    internal func get(_ key: String) throws -> Data {
        let encryptedData = try keychain.get(key)
        let (encryptionKey, hmacKey) = try getKeysFromKeychain(for: user, with: password)
        return try decrypt(encryptedData, with: encryptionKey, hmac: hmacKey)
    }

    /// Removes data that is saved for a given key.
    ///
    /// - Parameter key: A key for which the data should be removed.
    /// - Throws: An error if the data could not be removed.
    internal func remove(_ key: String) throws {
        try keychain.remove(key: key)
    }

    /// Removes all objects that where saved in the `keychain`.
    ///
    /// - Throws: An error if the operation could not be performed.
    internal func clear() throws {
        try keychain.clear()
    }

    /// Retrieves the encryption and hmac keypair that was previously created and
    /// saved to the keychain. If it doesn't exist a new keypair is created.
    ///
    /// - Returns: A keypair that contains an encryption and a hmac key.
    /// - Throws: An error if the keys could not be retrieved and created.
    private func getOrCreateKeys() throws -> (encryption: Data, hmac: Data) {
        if let keys = try? getKeysFromKeychain(for: user, with: password) {
            return keys
        }
        return try createKeys(for: user, with: password)
    }

    /// Retrieves the encryption and hmac keypair from the keychain.
    ///
    /// - Parameters:
    ///   - user: A user that the keypair was created for.
    ///   - password: A password that will be used to decrypt the keypair.
    /// - Returns: A keypair that contains an encryption and a hmac key.
    /// - Throws: An error if the keypair could not be retrieved for the
    /// user/password combination.
    private func getKeysFromKeychain(for user: String, with password: String) throws -> (encryption: Data, hmac: Data) {
        let encryptedEncryptionKey = try keychain.get(encryptionKeychainKey(for: user))
        let encryptedHmacKey = try keychain.get(hmacKeychainKey(for: user))
        let encryptionKey = try decrypt(encryptedEncryptionKey, with: password)
        let hmacKey = try decrypt(encryptedHmacKey, with: password)
        return (encryptionKey, hmacKey)
    }

    /// Creates an encryption key and hmac key that are encrypted with a password
    /// and saved in the keychain related to a user.
    ///
    /// - Parameters:
    ///   - user: A user that the keypair is created for.
    ///   - password: A password that will be used to encrypt the keypair.
    /// - Returns: A keypair that contains the encryption and hmac key.
    /// - Throws: An error if the keypair could not be saved to the keychain.
    private func createKeys(for user: String, with password: String) throws -> (encryption: Data, hmac: Data) {
        let encryptionKey = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.keySize)
        let hmacKey = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.keySize)
        let encryptedEncryptionKey = encrypt(data: encryptionKey, with: password)
        let encryptedHmacKey = encrypt(data: hmacKey, with: password)

        try keychain.save(encryptedEncryptionKey, for: encryptionKeychainKey(for: user), withUserPresence: false)
        try keychain.save(encryptedHmacKey, for: hmacKeychainKey(for: user), withUserPresence: false)

        return (encryptionKey, hmacKey)
    }

    /// Enrypts data with an encryption and hmac key.
    ///
    /// - Parameters:
    ///   - data: The data that should be encrypted.
    ///   - encryptionKey: A key used for the encryption.
    ///   - hmacKey: A key used for the verification of the encrypted data.
    /// - Returns: The encrypted data.
    private func encrypt(_ data: Data, with encryptionKey: Data, hmac hmacKey: Data) -> Data {
        let encryptor = RNCryptor.EncryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
        return encryptor.encrypt(data: data)
    }


    /// Encrypts data with a password.
    ///
    /// - Parameters:
    ///   - data: The data that should be encrypted.
    ///   - password: A password that is used to encrypt the data.
    /// - Returns: The encrypted data.
    private func encrypt(data: Data, with password: String) -> Data {
        let (encryptionSalt, encryptionKey) = randomSaltAndKey(for: password)
        let (hmacSalt, hmacKey) = randomSaltAndKey(for: password)
        let encryptor = RNCryptor.EncryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)

        var ciphertext =  Data(encryptionSalt)
        ciphertext.append(hmacSalt)
        ciphertext.append(encryptor.encrypt(data: data))
        return ciphertext
    }

    /// Decrypts data with an encryption and hmac key.
    ///
    /// - Parameters:
    ///   - data: The data that should be decrypted.
    ///   - encryptionKey: A key used to decrypt the data.
    ///   - hmacKey: A key used for the verification of the decrypted data.
    /// - Returns: The decrypted data.
    /// - Throws: An error if the decryption failed.
    private func decrypt(_ data: Data, with encryptionKey: Data, hmac hmacKey: Data) throws -> Data {
        let decryptor = RNCryptor.DecryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
        return try decryptor.decrypt(data: data)
    }

    /// Decrypts data with a password.
    ///
    /// - Parameters:
    ///   - data: The data that should be decrypted.
    ///   - password: A password that is used to decrypt the data.
    /// - Returns: The decrypted data.
    /// - Throws: An error if the decryption failed.
    private func decrypt(_ data: Data, with password: String) throws -> Data {
        let encryptionSaltRange = Range(0 ..< RNCryptor.FormatV3.saltSize)
        let hmacSaltRangeUpperBound = encryptionSaltRange.upperBound + RNCryptor.FormatV3.saltSize
        let hmacSaltRange = Range(encryptionSaltRange.upperBound ..< hmacSaltRangeUpperBound)
        let bodyRange = Range(hmacSaltRange.upperBound ..< data.count)

        let encryptionSalt = data.subdata(in: encryptionSaltRange)
        let hmacSalt = data.subdata(in: hmacSaltRange)
        let body = data.subdata(in: bodyRange)

        let encryptionKey = RNCryptor.FormatV3.makeKey(forPassword: password, withSalt: encryptionSalt)
        let hmacKey = RNCryptor.FormatV3.makeKey(forPassword: password, withSalt: hmacSalt)

        let decryptor = RNCryptor.DecryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
        return try decryptor.decrypt(data: body)
    }

    /// Creates a random salt and key for a given password.
    ///
    /// - Parameter password: A string that is used to create the key.
    /// - Returns: A random salt and key that is derived from the password.
    private func randomSaltAndKey(for password: String) -> (salt: Data, key: Data) {
        let salt = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.saltSize)
        let key = RNCryptor.FormatV3.makeKey(forPassword: password, withSalt: salt)
        return (salt, key)
    }

    /// Creates the key that is used to store the encryption key of a user to
    /// the keychain.
    ///
    /// - Parameter user: A user for whom the key is created.
    /// - Returns: A string that contains the key to save the encryption key to the keychain.
    private func encryptionKeychainKey(for user: String) -> String {
        return "SDS.encryptionKey-" + user
    }

    /// Creates the key that is used to store the hmac key of a user to the keychain.
    ///
    /// - Parameter user: A user for whom the key is created.
    /// - Returns: A string that contains the key to save the hmac key to the keychain.
    private func hmacKeychainKey(for user: String) -> String {
        return "SDS.hamcKey-" + user
    }
}
