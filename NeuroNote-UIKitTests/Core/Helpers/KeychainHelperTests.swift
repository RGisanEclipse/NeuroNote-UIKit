//
//  KeychainHelperTests.swift
//  NeuroNoteTests
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class KeychainHelperTests: XCTestCase {

    let testKey = "com.neuronote.test.token"
    let testValue = "mock_token_123456"

    override func setUpWithError() throws {
        KeychainHelper.standard.delete(forKey: testKey)
    }

    override func tearDownWithError() throws {
        KeychainHelper.standard.delete(forKey: testKey)
    }

    func testSaveAndReadValue() {
        KeychainHelper.standard.save(testValue, forKey: testKey)

        let readValue = KeychainHelper.standard.read(forKey: testKey)

        XCTAssertEqual(readValue, testValue, "Expected to read the same value that was saved")
    }

    func testReadReturnsNilIfKeyNotFound() {
        let result = KeychainHelper.standard.read(forKey: "non.existent.key")

        XCTAssertNil(result, "Reading a non-existent key should return nil")
    }

    func testDeleteRemovesValue() {
        KeychainHelper.standard.save(testValue, forKey: testKey)

        KeychainHelper.standard.delete(forKey: testKey)

        let result = KeychainHelper.standard.read(forKey: testKey)

        XCTAssertNil(result, "Expected value to be nil after deletion")
    }

    func testOverwritingValue() {
        let firstValue = "first_token"
        let secondValue = "second_token"

        KeychainHelper.standard.save(firstValue, forKey: testKey)
        KeychainHelper.standard.save(secondValue, forKey: testKey)

        let finalValue = KeychainHelper.standard.read(forKey: testKey)

        XCTAssertEqual(finalValue, secondValue, "Keychain should hold the latest value after overwrite")
    }
}
