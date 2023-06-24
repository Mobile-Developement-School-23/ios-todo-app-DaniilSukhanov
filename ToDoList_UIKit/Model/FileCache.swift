//
//  FileCache.swift
//  ToDoList
//
//  Created by Даниил Суханов on 10.06.2023.
//

import Foundation
import OSLog

class FileCache {
    private(set) var items = [TodoItem]()
    private let urlDirSave = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let logger = Logger(category: String(describing: FileCache.self))
    
    func createFile(filename: String) -> Bool {
        FileManager.default.createFile(atPath: urlDirSave.appending(component: filename).path(), contents: nil)
    }
    
    // Добавление TodoItem с перезаписью
    func append(_ item: TodoItem) {
        if items.contains(item) {
            logger.info("\(String.logFormat()) перезапись предмета \(item.id)")
            items[items.firstIndex(of: item)!] = item
        } else {
            logger.info("\(String.logFormat()) добавление предмета \(item.id)")
            items.append(item)
        }
        
        
    }
    
    // Удаление TodoItem по id
    func remove(id: String) {
        guard let item = items.first(where: { $0.id == id }) else {
            logger.info("\(String.logFormat()) неудалось удалить предмет по id = \(id)")
            return
        }
        logger.info("\(String.logFormat()) удаление предмета \(item.id)")
        items.remove(at: items.firstIndex(of: item)!)
    }
    
    // MARK: -JSON
    
    // Сохранение всех TodoItems в json файл
    func saveJSON(filename: String) -> Bool {
        let data = items.map { item in
            item.json as! [String: Any]
        }
        guard let json = try? JSONSerialization.data(withJSONObject: data) else {
            logger.error("\(String.logFormat()) неудалось конвертировать данные в json")
            return false
        }
        guard (try? json.write(to: urlDirSave.appending(path: "\(filename).json"))) != nil else {
            logger.error("\(String.logFormat()) неудалось записать в json \(filename)")
            return false
        }
        return true
    }
    
    // Загрузка всех TodoItems в json файл
    func loadJSON(filename: String) -> Bool {
        guard let data = try? Data(contentsOf: urlDirSave.appending(path: "\(filename).json")) else {
            logger.error("\(String.logFormat()) неудалось получить данные json файла \(filename)")
            return false
        }
        guard let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            logger.error("\(String.logFormat()) неудалось конвертировать данные в словарь")
            return false
        }
        for item in items {
            guard let todoItem = TodoItem.parse(json: item) else {
                logger.error("\(String.logFormat()) неудалось спарсить в json \(item)")
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
            logger.error("\(String.logFormat()) неудалось записать в csv \(filename)")
            return false
        }
        return true
    }
    
    // Загрузка всех TodoItems в csv файл
    func loadCSV(filename: String) -> Bool {
        guard let string = try? String(contentsOf: urlDirSave.appending(path: "\(filename).csv")) else {
            logger.error("\(String.logFormat()) неудалось получить данные csv файла \(filename)")
            return false
        }
        let titles = TodoItem.titles.joined(separator: ";")
        for row in string.components(separatedBy: ";") where row != titles {
            guard let item = TodoItem.parse(csv: row) else {
                logger.error("\(String.logFormat()) неудалось спарсить в csv \(row)")
                continue
            }
            append(item)
        }
        return true
    }
}
