//
//  EncryptedStore.swift
//  Pods
//
//  Created by Johannes Steib on 16.03.17.
//
//

public class EncryptedStore: SecureStore {
    let secureStore: EncryptedStorageService
    
    public init(service: String, user: String, password: String) {
        secureStore = EncryptedStorageService(service: service,
                                              password: password,
                                              user: user)
    }
    
    public func save(_ data: Data, for key: String) throws {
        try secureStore.save(data, for: key)
    }
    
    public func getData(for key: String) throws -> Data {
        return try secureStore.get(key)
    }
    
    public func remove(_ key: String) throws {
        try secureStore.remove(key)
    }
    
    public func clear() throws {
        try secureStore.clear()
    }
}
