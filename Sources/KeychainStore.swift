//
//  KeychainStore.swift
//  Pods
//
//  Created by Johannes Steib on 16.03.17.
//
//

public class KeychainStore: SecureStore {
    let keychain: KeychainService
    
    public init(service: String) {
        keychain = KeychainService(service: service)
    }
    
    public func save(_ data: Data, for key: String) throws {
        try keychain.save(data, for: key, withUserPresence: true)
    }
    
    public func getData(for key: String) throws -> Data {
        return try keychain.get(key, with: "prompt")
        
    }
    
    public func remove(_ key: String) throws {
        try keychain.remove(key: key)
    }
    
    public func clear() throws {
        try keychain.clear()
    }
}
