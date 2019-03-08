//
//  SecurelyStoring.swift
//  SecureKeyStorage
//
//  Created by Johannes Steib on 16.03.17.
//
//

/// A type that represents a secure data store.
public protocol SecurelyStoring {

    /// Saves a string for a given key to the secure data store.
    ///
    /// - Parameters:
    ///   - string: A String that is to be saved.
    ///   - key: A key that is used to save the string.
    /// - Throws: An error if the string could not be saved.
    func save(_ string: String, for key: String) throws

    /// Saves data for a given key to the secure data store
    ///
    /// - Parameters:
    ///   - data: Data that is to be saved.
    ///   - key: A key that is used to save the data.
    /// - Throws: An error if the data could not be saved.
    func save(_ data: Data, for key: String) throws

    /// Fetches a string for a given key from the secure data store.
    ///
    /// - Parameter key: A key for which the string is to be retrieved.
    /// - Returns: The string retrieved from the store for the given key.
    /// - Throws: An error if the string could not be retrieved.
    func getString(for key: String) throws -> String

    /// Fetches data for a given key from the secure data store.
    ///
    /// - Parameter key: A key for which the data is to be retrieved.
    /// - Returns: The data retrieved from the store for the given key.
    /// - Throws: An error if the data could not be retrieved.
    func getData(for key: String) throws -> Data

    /// Removes an object for a given key from the secure data store.
    ///
    /// - Parameter key: A key for which the object should be deleted.
    /// - Throws: An error if the object could not be deleted.
    func remove(_ key: String) throws

    /// Removes all objects from the secure data store
    ///
    /// - Throws: An error if the operation could not be performed.
    func clear() throws
}

extension SecurelyStoring {
    public func save(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw SecureKeyStorageError.stringConversionError
        }
        try save(data, for: key)
    }

    public func getString(for key: String) throws -> String {
        guard let data = try? getData(for: key) else {
            throw SecureKeyStorageError.itemNotFoundError
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw SecureKeyStorageError.stringConversionError
        }
        return string
    }
}
