//
//  EncryptedStorageService.swift
//  Pods
//
//  Created by Johannes Steib on 10.03.17.
//
//

import Foundation
import RNCryptor

internal class EncryptedStorageService {
    let user: String
    let password: String
    let keychain: KeychainService
    
    internal init(service: String, accessGroup: String? = nil, password: String, user: String) {
        self.password = password
        self.user = user
        keychain = KeychainService(service: service, accessGroup: accessGroup)
    }
    
    internal func save(_ data: Data, for key: String) throws {
        do {
            let (encryptionKey, hmacKey) = try getKeys()
            let encryptedData = encrypt(data, with: encryptionKey, hmac: hmacKey)
            try keychain.save(encryptedData, for: key, withUserPresence: false)
        } catch {
            throw SDSError.couldNotSaveItemError
        }
    }
    
    internal func get(_ key: String) throws -> Data {
        let encryptedData = try keychain.get(key)
        let (encryptionKey, hmacKey) = try getKeys()
        return try decrypt(encryptedData, with: encryptionKey, hmac: hmacKey)
    }
    
    private func getKeys() throws -> (encryption: Data, hmac: Data) {
        if let keys = try? getKeysFromKeychain(for: user, with: password) {
            return keys
        }
        return try createKeys(for: user, with: password)
    }
    
    private func getKeysFromKeychain(for user: String, with password: String) throws -> (encryption: Data, hmac: Data) {
        let encryptedEncryptionKey = try keychain.get(encryptionKeychainKey(for: user))
        let encryptedHmacKey = try keychain.get(hmacKeychainKey(for: user))
        let encryptionKey = try decrypt(encryptedEncryptionKey, with: password)
        let hmacKey = try decrypt(encryptedHmacKey, with: password)
        return (encryptionKey, hmacKey)
    }
    
    private func createKeys(for user: String, with password: String) throws -> (encryption: Data, hmac: Data) {
        let encryptionKey = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.keySize)
        let hmacKey = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.keySize)
        let encryptedEncryptionKey = encrypt(data: encryptionKey, with: password)
        let encryptedHmacKey = encrypt(data: hmacKey, with: password)
        
        try keychain.save(encryptedEncryptionKey, for: encryptionKeychainKey(for: user), withUserPresence: false)
        try keychain.save(encryptedHmacKey, for: hmacKeychainKey(for: user), withUserPresence: false)
        
        return (encryptionKey, hmacKey)
    }
    
    private func encrypt(_ data: Data, with encryptionKey: Data, hmac hmacKey: Data) -> Data {
        let encryptor = RNCryptor.EncryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
        return encryptor.encrypt(data: data)
    }
    
    private func encrypt(data: Data, with password: String) -> Data {
        let (encryptionSalt, encryptionKey) = randomSaltAndKey(for: password)
        let (hmacSalt, hmacKey) = randomSaltAndKey(for: password)
        let encryptor = RNCryptor.EncryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
        
        var ciphertext =  Data(encryptionSalt)
        ciphertext.append(hmacSalt)
        ciphertext.append(encryptor.encrypt(data: data))
        return ciphertext
    }
    
    private func decrypt(_ data: Data, with encryptionKey: Data, hmac hmacKey: Data) throws -> Data {
        let decryptor = RNCryptor.DecryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
        return try decryptor.decrypt(data: data)
    }
    
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
    
    private func randomSaltAndKey(for password: String) -> (salt: Data, key: Data) {
        let salt = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.saltSize)
        let key = RNCryptor.FormatV3.makeKey(forPassword: password, withSalt: salt)
        return (salt, key)
    }
    
    private func encryptionKeychainKey(for user: String) -> String {
        return "SDS.encryptionKey-" + user
    }
    
    private func hmacKeychainKey(for user: String) -> String {
        return "SDS.hamcKey-" + user
    }
}
