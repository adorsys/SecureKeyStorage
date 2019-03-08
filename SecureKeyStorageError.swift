//
//  SecureKeyError.swift
//  SecureKeyStorage
//
//  Created by Felizia Bernutz on 08.03.19.
//

public enum SecureKeyStorageError: Error {
    case stringConversionError
    case unhandledError(status: OSStatus)
    case unexpectedError
    case itemNotFoundError
    case couldNotSaveItemError
}
