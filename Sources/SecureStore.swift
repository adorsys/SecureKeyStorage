//
//  SecureStore.swift
//  SecureDeviceStorage
//
//  Created by Johannes Steib on 16.03.17.
//
//

public protocol SecureStore {
    func save(_ string: String, for key: String) throws
    func save(_ data: Data, for key: String) throws
    func getString(for key: String) throws -> String
    func getData(for key: String) throws -> Data
    func remove(_ key: String) throws
    func clear() throws
}

extension SecureStore {
    public func save(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw SDSError.stringConversionError
        }
        try save(data, for: key)
    }
    
    public func getString(for key: String) throws -> String {
        guard let data = try? getData(for: key) else {
            throw SDSError.itemNotFoundError
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw SDSError.stringConversionError
        }
        return string
    }
}
