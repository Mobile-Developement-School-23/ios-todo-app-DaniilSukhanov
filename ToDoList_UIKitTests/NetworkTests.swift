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
        baseURL = .init(string: "https://beta.mrdekk.ru/todobackend/list")!
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testAPI() async throws {
        let networkService = DefaultNetworkingService()
        do {
            try await networkService.addTodoItem(.init(text: "hds", importance: .important, isMake: true))
        } catch {
            XCTFail("error: \(error.localizedDescription)")
        }
        
    }
}
