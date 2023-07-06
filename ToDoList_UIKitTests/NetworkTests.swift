//
//  NetworkTest.swift
//  ToDoList_UIKitTests
//
//  Created by Даниил Суханов on 03.07.2023.
//

import Foundation

import XCTest
@testable import ToDoList_UIKit

final class NetworkTests: XCTestCase {
    var baseURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
        baseURL = .init(string: "https://beta.mrdekk.ru/todobackend?clientId=0d0970774e284fa8ba9ff70b6b06479a")!
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testTest() async throws {
        let url = baseURL
        let session = URLSession.shared
        do {
            let (data, response) = try await session.dataTask(for: .init(url: url!))
            let string = String(data: data, encoding: .utf8)
            XCTAssertNotNil(string, "string == nil")
            print(string ?? "nil")
            print(response)
        } catch {
            XCTFail("Ошибака \(error)")
        }

    }
}
