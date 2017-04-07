//
//  ADSecureDeviceStorageTests.swift
//  ADSecureDeviceStorageTests
//
//  Created by Johannes Steib on 10.03.17.
//  Copyright © 2017 adorsys GmbH & Co KG. All rights reserved.
//

import XCTest
@testable import ADSecureDeviceStorage

class ADSecureDeviceStorageTests: XCTestCase {
    
    private let serviceName = "EncryptedStorageServiceTests"
    var service: EncryptedStorageService!
    var anotherService: EncryptedStorageService!
    
    override func setUp() {
        super.setUp()
        
        service = EncryptedStorageService(service: serviceName, password: "password", user: "user")
        anotherService = EncryptedStorageService(service: serviceName, password: "geheim", user: "benutzer")
    }
    
    override func tearDown() {
        try? service.clear()
        try? anotherService.clear()
        
        super.tearDown()
    }
    
    func testEncryptedStorageService() {
        let secret = "A Secret Login Token"
        let secretData = secret.data(using: .utf8)
        let key = "login"
        
        do {
            try service.save(secretData!, for: key)
        } catch let error {
            XCTAssertNil(error)
        }
        
        do {
            let decrypted = try service.get(key)
            XCTAssertTrue(secretData!.elementsEqual(decrypted))
        } catch let error {
            XCTAssertNil(error)
        }
        
        do {
            try anotherService.get(key)
        } catch let error {
            XCTAssertNotNil(error)
        }
    }
    
}
