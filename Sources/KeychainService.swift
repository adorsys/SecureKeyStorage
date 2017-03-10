//
//  KeychainService.swift
//  SecureDeviceStorage
//
//  Created by Johannes Steib on 09.03.17.
//
//

internal class KeychainService {
    let service: String
    let accessGroup: String?
    
    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
    
    internal func save(_ data: Data, for key: String, withUserPresence protection: Bool = true) throws {
        
        try remove(key: key)
        
        var query = keychainQuery(forKey: key)
        
        query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIFail
        
        if protection {
            var error: Unmanaged<CFError>?
            guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as CFTypeRef,
                                                                      .userPresence, &error)
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
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
        
        query[kSecValueData as String] = data
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            debugPrint("save: \(status)")
            throw SDSError.unhandledError(status: status)
        }
    }
    
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
    
    private func keychainQuery(forKey key: String? = nil) -> [String : Any] {
        var query = [String : Any]()
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
