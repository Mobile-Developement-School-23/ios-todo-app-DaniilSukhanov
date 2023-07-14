//
//  DataCoreTest.swift
//  ToDoList_UIKitTests
//
//  Created by Даниил Суханов on 13.07.2023.
//

import Foundation
import XCTest
@testable import ToDoList_UIKit

// TODO: Внимание. Если запустить приложение и что-то сделать (добавить задачу, например),
// TODO: то тесты, скорее всего, не пройдут. Требуется повторный запуск тестов.
final class DataCoreTest: XCTestCase {
    var database: CoreDatabase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
        database = .init()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        for item in try! database.container.viewContext.fetch(DCTodoItem.fetchRequest()) {
            database.container.viewContext.delete(item)
        }
        try! database.container.viewContext.save()
        database = nil
    }
    
    func testFunc() {
        let item1 = TodoItem(text: "item1", importance: .unimportant, isMake: false)
        let item2 = TodoItem(text: "item2", importance: .unimportant, isMake: false)
        let item3 = TodoItem(text: "item3", importance: .unimportant, isMake: false)
        try! database.insert(item1)
        try! database.insert(item2)
        try! database.insert(item3)
        XCTAssert(database.getItems().count == 3)
        database.delete(item1)
        database.delete(item2.id)
        XCTAssert(database.getItems().count == 1)
        database.update(item3.modifier(text: "item3_update"))
        let list = database.getItems()
        XCTAssert(list.count == 1)
        XCTAssert(list[0].id == item3.id)
        XCTAssert(list[0].text != item3.text)
        database.delete(list[0])
    }
    
    func testDouble() {
        let item = TodoItem(text: "test", importance: .important, isMake: true)
        try! database.insert(item)
        XCTAssert((try? database.insert(item)) == nil)
        database.update(item.modifier(text: "test2"))
        let list = database.getItems()
        XCTAssert(list.count == 1)
        XCTAssert(list[0].text == "test2")
        XCTAssert(list[0].id == item.id)
        database.delete(item)
    }
}
