//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Даниил Суханов on 10.06.2023.
//

import XCTest
@testable import ToDoList_UIKit

final class ToDoList_UIKitTests: XCTestCase {
    
    var date: Date!
    var todoItem: TodoItem!
    var fileCache: FileCache!
    var items: [TodoItem]!
    var urlJSON: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
        date = .init()
        todoItem = TodoItem(
            text: "Test", importance: .unimportant,
            isMake: true, createdDate: date
        )
        fileCache = .init()
        items = .init()
        for i in 0..<11 {
            let item = TodoItem(
                text: "FileJSON\(i)",
                importance: .getImportance(id: (0..<3).randomElement()) ?? .usual,
                isMake: Bool(),
                createdDate: Date.now
            )
            items.append(item)
            fileCache.append(item)
        }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        urlJSON = url.appending(path: "json.json")
        XCTAssert(FileManager.default.createFile(atPath: urlJSON.path(), contents: nil))
    }

    override func tearDownWithError() throws {
        date = nil
        todoItem = nil
        fileCache = nil
        items = nil
        XCTAssert((try? FileManager.default.removeItem(at: urlJSON)) != nil)
        urlJSON = nil
        try super.tearDownWithError()
    }
    
    func testUncorrectJson() throws {
        let jsons: [[String: Any]] = [
            [
                "id": 90,
                "createdData": 6,
                "deadline": 666.666,
                "importance": 2,
                "isMake": false,
                "text": "very meaningful text"
            ],
            .init(),
            [
                "id": "test",
                "createdData": 0.0,
                "deadline": 666.666,
                "importance": 3,
                "isMake": false,
                "text": "very meaningful text",
                "changedData": 324
            ],
            [
                "id": "test",
                "createdData": 0.0,
                "deadline": 666.666,
                "importance": 2,
                "isMake": false,
                "text": 3,
                "changedData": 777.777
            ],
            [
                "id": "test",
                "createdData": 0.0,
                "deadline": 666.666,
                "importance": 2,
                "isMake": "false",
                "text": "very meaningful text",
                "changedData": 777.777
            ],
        ]
        for (i, json) in jsons.enumerated() {
            XCTAssert(TodoItem.parse(json: json) == nil, "ошибка в \(i)")
        }
    }
    
    func testAttr() throws {
        let dict: [String: Any] = [
            "id": "qwer54",
            "createdData": 0.0,
            "isMake": false,
            "text": "very meaningful text"
        ]
        guard let item = TodoItem.parse(json: dict) else {
            XCTAssert(false)
            return
        }
        XCTAssert(item.isMake == false)
        XCTAssert(item.changedDate == nil)
        XCTAssert(item.createdDate == Date(timeIntervalSinceReferenceDate: 0.0))
        XCTAssert(item.text == "very meaningful text")
        XCTAssert(item.id == "qwer54")
        XCTAssert(item.importance == .usual)
        XCTAssert(item.deadline == nil)
    }

    func testJSON() throws {
        let data = todoItem.json
        let newTodoItem = TodoItem.parse(json: data)!
        try eqTest(newTodoItem)
        let json: [String: Any] = [
            "id": "test",
            "createdData": 0.0,
            "deadline": 666.666,
            "importance": 2,
            "isMake": false,
            "text": "very meaningful text",
            "changedData": 777.777
        ]
        
        guard let createdTodoItem = TodoItem.parse(json: json) else {
            XCTAssert(false, "Парсер не правильно работает")
            return
        }
        XCTAssert(createdTodoItem.text == "very meaningful text")
        XCTAssert(createdTodoItem.isMake == false)
        XCTAssert(createdTodoItem.deadline == Date(timeIntervalSinceReferenceDate: 666.666))
        XCTAssert(createdTodoItem.importance == .important)
        XCTAssert(createdTodoItem.changedDate == Date(timeIntervalSinceReferenceDate: 777.777))
        XCTAssert(createdTodoItem.id == "test")
        XCTAssert(createdTodoItem.createdDate == Date(timeIntervalSinceReferenceDate: 0.0))
    }
    
    private func eqTest(_ newTodoItem: TodoItem) throws {
        XCTAssert(newTodoItem.id == todoItem.id,
                  "\(String(describing: newTodoItem.id)) != \(String(describing: todoItem.id))")
        
        XCTAssert(newTodoItem.changedDate == todoItem.changedDate,
                  "\(String(describing: newTodoItem.changedDate)) != \(String(describing: todoItem.changedDate))")
        
        XCTAssert(newTodoItem.createdDate == todoItem.createdDate,
                  "\(String(describing: newTodoItem.createdDate)) != \(String(describing: todoItem.createdDate))")
        XCTAssert(newTodoItem.deadline == todoItem.deadline,
                  "\(String(describing: newTodoItem.deadline)) != \(String(describing: todoItem.deadline))")
        
        XCTAssert(newTodoItem.importance == todoItem.importance,
                  "\(String(describing: newTodoItem.importance)) != \(String(describing: todoItem.importance))")
        
        XCTAssert(newTodoItem.isMake == todoItem.isMake,
                  "\(String(describing: newTodoItem.isMake)) != \(String(describing: todoItem.isMake))")
        
        XCTAssert(newTodoItem.text == todoItem.text,
                  "\(String(describing: newTodoItem.text)) != \(String(describing: todoItem.text))")
    }
    
    func testCSV() throws {
        let data = todoItem.csv
        let newTodoItem = TodoItem.parse(csv: data)!
        try eqTest(newTodoItem)
        let csv = "id;text;;;true;666.666;;"
        guard let item = TodoItem.parse(csv: csv) else {
            XCTAssert(false)
            return
        }
        XCTAssert(item.text == "text")
        XCTAssert(item.isMake == true)
        XCTAssert(item.deadline == nil)
        XCTAssert(item.importance == .usual)
        XCTAssert(item.changedDate == nil)
        XCTAssert(item.id == "id")
        XCTAssert(item.createdDate == Date(timeIntervalSinceReferenceDate: 666.666))
        
    }
    
    func testFileCache() throws {
        XCTAssert(fileCache.saveJSON(url: urlJSON))
        let fileData1 = try! String(contentsOf: urlJSON)
        fileCache.append(TodoItem(text: "werty", importance: .important, isMake: true, createdDate: Date.now))
        XCTAssert(fileCache.saveJSON(url: urlJSON))
        let fileData2 = try! String(contentsOf: urlJSON)
        XCTAssert(fileData1 != fileData2, "Не правильно работает .saveJSON или .append")
        var json = try! JSONSerialization.jsonObject(with: Data(contentsOf: urlJSON)) as! [[String: Any]]
        json.append(todoItem.json as! [String: Any])
        try! JSONSerialization.data(withJSONObject: json).write(to: urlJSON)
        let items1 = fileCache.items
        XCTAssert(fileCache.loadJSON(url: urlJSON))
        let items2 = fileCache.items
        XCTAssert(items1 != items2, ".loadJSON некоректно работает")
    }
}
