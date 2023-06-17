//
//  FileCache.swift
//  ToDoList
//
//  Created by Даниил Суханов on 10.06.2023.
//

import Foundation

class FileCache {
    private(set) var items = Set<TodoItem>()
    private let urlDirSave = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // Добавление TodoItem с перезаписью
    func append(_ item: TodoItem) {
        if items.contains(item) {
            items.remove(item)
        }
        items.insert(item)
        
    }
    
    // Удаление TodoItem по id
    func remove(id: String) {
        guard let item = items.first(where: { $0.id == id }) else {
            return
        }
        items.remove(item)
    }
    
    // MARK: -JSON
    
    // Сохранение всех TodoItems в json файл
    func saveJSON(filename: String) -> Bool {
        let data = items.map { item in
            item.json as! [String: Any]
        }
        guard let json = try? JSONSerialization.data(withJSONObject: data) else {
            return false
        }
        guard (try? json.write(to: urlDirSave.appending(path: "\(filename).json"))) != nil else {
            return false
        }
        return true
    }
    
    // Загрузка всех TodoItems в json файл
    func loadJSON(filename: String) -> Bool {
        guard let data = try? Data(contentsOf: urlDirSave.appending(path: "\(filename).json")) else {
            return false
        }
        guard let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return false
        }
        for item in items {
            guard let todoItem = TodoItem.parse(json: item) else {
                continue
            }
            append(todoItem)
        }
        return true
    }
}

// MARK: -CSV

extension FileCache {
    // Сохранение всех TodoItems в csv файл
    func saveCSV(filename: String) -> Bool {
        let data = items.map { item in
            item.csv
        }
        let string = data.reduce(into: TodoItem.titles.joined(separator: ";")) {
            $0 += "\n" + $1
        }
        guard
            (try? string.write(
                to: urlDirSave.appending(path: "\(filename).csv"),
                atomically: false,
                encoding: .utf8)
            ) != nil
        else {
            return false
        }
        return true
    }
    
    // Загрузка всех TodoItems в csv файл
    func loadCSV(filename: String) -> Bool {
        guard let string = try? String(contentsOf: urlDirSave.appending(path: "\(filename).csv")) else {
            return false
        }
        let titles = TodoItem.titles.joined(separator: ";")
        for row in string.components(separatedBy: ";") where row != titles {
            guard let item = TodoItem.parse(csv: row) else {
                continue
            }
            append(item)
        }
        return true
    }
}
