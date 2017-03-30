//
//  KeychainStore.swift
//  SecureDeviceStorage
//
//  Created by Johannes Steib on 16.03.17.
//
//

public class KeychainStore: SecurelyStoring {
    let keychain: KeychainService
    var authenticationPrompt: String
    
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
        return try keychain.get(key, with: authenticationPrompt)
    }
    
    public func remove(_ key: String) throws {
        try keychain.remove(key: key)
    }
    
    public func clear() throws {
        try keychain.clear()
    }
}
