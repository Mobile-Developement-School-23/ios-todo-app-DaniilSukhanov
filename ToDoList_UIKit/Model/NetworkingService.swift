//
//  NetworkingService.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 06.07.2023.
//

import Foundation
import UIKit

fileprivate extension Dictionary where Key == String, Value == Any {
    static let convertKeys = [
        "id": "id",
        "text": "text",
        "importance": "importance",
        "deadline": "deadline",
        "done": "isMake",
        "created_at": "createdDate",
        "changed_at": "changedDate"
    ]
    
    // MARK: - Неправильно работает convert
    func toCovertFormatTodoItem(_ isNetworkTodoItem: Bool = false) -> [String: Any] {
        var result = [String: Any]()
        var dict: [String: String]
        if isNetworkTodoItem {
            dict = .init()
            for (key, value) in Dictionary.convertKeys {
                dict[value] = key
            }
        } else {
            dict = Dictionary.convertKeys
        }
        for oldKey in dict.keys {
            guard let newKey = dict[oldKey] else {
                continue
            }
            
            if oldKey != "importance" {
                if newKey == "deadline" && self.keys.contains("deadline") {
                    if isNetworkTodoItem {
                        result[newKey] = Int(self[oldKey] as! Double)
                    } else {
                        result[newKey] = Double(self[oldKey] as! Int)
                    }
                } else if ["created_at", "changed_at"].contains(oldKey) {
                    if !self.keys.contains(oldKey) {
                        continue
                    }
                    result[newKey] = Double((self[oldKey] as? Int) ?? Int.max)
                } else if ["createdDate", "changedDate"].contains(oldKey) {
                    if !self.keys.contains(oldKey) {
                        continue
                    }
                    result[newKey] = Int(self[oldKey] as! Double)
                } else {
                    result[newKey] = self[oldKey]
                }
            } else {
                if isNetworkTodoItem {
                    let data = (self[oldKey] as? Int) ?? 1
                    switch data {
                    case 0: result[newKey] = "low"
                    case 1: result[newKey] = "basic"
                    case 2: result[newKey] = "important"
                    default: break
                    }
                } else {
                    let data = (self[oldKey] as? String) ?? "basic"
                    switch data {
                    case "low": result[newKey] = 0
                    case "basic": result[newKey] = 1
                    case "important": result[newKey] = 2
                    default: break
                    }
                }
            }
        }
        return result.extensionLastUpdatedBy()
    }
    
    func extensionLastUpdatedBy() -> Self {
        var result = self
        result["last_updated_by"] = "dih4fd"
        return result
    }
}

enum NetworkingServiceError: Int, Error {
    case incorrectlyFormedRequest = 400
    case invalidAuthorization = 401
    case elementNotFound = 404
    case serviceError = 500
}

fileprivate extension String {
    static let post = "POST"
    static let get = "GET"
    static let put = "PUT"
    static let delete = "DELETE"
    static let patch = "PATCH"
    static let authorization = "Authorization"
    
    func toBearerFormat() -> Self {
        return "Bearer " + self
    }
}

fileprivate extension URLResponse {
    func toHTTPURLResponse() -> HTTPURLResponse {
        return self as! HTTPURLResponse
    }
}

protocol NetworkingService {
    func getTodoItems() async throws -> [TodoItem]
    func updateTodoItems(_ items: [TodoItem]) async throws -> [TodoItem]
    func getTodoItem(id: String) async throws -> TodoItem
    func addTodoItem(_ item: TodoItem) async throws
    func changeTodoItem(_ item: TodoItem) async throws
    func deleteTodoItem(id: String) async throws
}

final class DefaultNetworkingService: NetworkingService {
    fileprivate let baseURL: URL = .init(
        string: "https://beta.mrdekk.ru/todobackend/list"
    )!
    fileprivate let token: String = "pickthank".toBearerFormat()
    
    fileprivate func getRevision() async throws -> String {
        var request = URLRequest(url: baseURL)
        request.httpMethod = .get
        request.setValue(token, forHTTPHeaderField: .authorization)
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        let infoResponse = response.toHTTPURLResponse()
        if let error = NetworkingServiceError(rawValue: infoResponse.statusCode) {
            throw error
        }
        guard let data = try? await serialization(data: data) as? [String: Any] else {
            throw NetworkingServiceError.incorrectlyFormedRequest
        }
        
        return String(data["revision"] as! Int)
    }

    fileprivate func serialization(data: Data) async throws -> Any {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                let data = try! JSONSerialization.jsonObject(with: data)
                continuation.resume(returning: data)
            }
        }
    }

    fileprivate func serialization(json: Any) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                let data = try! JSONSerialization.data(withJSONObject: json)
                continuation.resume(returning: data)
            }
        }
    }

    func getTodoItems() async throws -> [TodoItem] {
        var request = URLRequest(url: baseURL)
        request.httpMethod = .get
        request.setValue(token, forHTTPHeaderField: .authorization)
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        let infoResponse = response.toHTTPURLResponse()
        if let error = NetworkingServiceError(rawValue: infoResponse.statusCode) {
            throw error
        }
        guard let data = try? await serialization(data: data) as? [String: Any] else {
            throw NetworkingServiceError.incorrectlyFormedRequest
        }
        let items = (data["list"]! as! [[String: Any]]).compactMap {
            let json = $0.toCovertFormatTodoItem()
            let item = TodoItem.parse(json: json)
            return item
        }
        return items
    }

    func updateTodoItems(_ items: [TodoItem]) async throws -> [TodoItem] {
        var request = URLRequest(url: baseURL)
        request.httpMethod = .patch
        request.addValue(try! await getRevision(), forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = try! await serialization(
            json: [
                "list": items.map {
                    ($0.json as! [String: Any]).toCovertFormatTodoItem(true)
                }
            ]
            
        )
        request.addValue(token, forHTTPHeaderField: .authorization)
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        let infoResponse = response.toHTTPURLResponse()
        if let error = NetworkingServiceError(rawValue: infoResponse.statusCode) {
            throw error
        }
        guard let data = try? await serialization(data: data) as? [String: Any] else {
            throw NetworkingServiceError.incorrectlyFormedRequest
        }
        let items = (data["list"]! as! [[String: Any]]).compactMap {
            TodoItem.parse(json: $0.toCovertFormatTodoItem())
        }
        return items
    }

    func getTodoItem(id: String) async throws -> TodoItem {
        var request = URLRequest(url: baseURL.appending(path: id))
        request.httpMethod = .get
        request.setValue(token, forHTTPHeaderField: .authorization)
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        let infoResponse = response.toHTTPURLResponse()
        if let error = NetworkingServiceError(rawValue: infoResponse.statusCode) {
            throw error
        }
        guard let data = try? await serialization(data: data) as? [String: Any] else {
            throw NetworkingServiceError.incorrectlyFormedRequest
        }
        let item = TodoItem.parse(json: (data["element"]! as! [String: Any]).toCovertFormatTodoItem())!
        return item
    }
    
    func addTodoItem(_ item: TodoItem) async throws {
        var request = URLRequest(url: baseURL)
        request.httpMethod = .post
        request.httpBody = try! await serialization(
            json: ["element": (item.json as! [String: Any]).toCovertFormatTodoItem(true)]
        )
        request.setValue(token, forHTTPHeaderField: .authorization)
        let (_, response) = try await URLSession.shared.dataTask(for: request)
        let infoResponse = response.toHTTPURLResponse()
        if let error = NetworkingServiceError(rawValue: infoResponse.statusCode) {
            throw error
        }
    }
    
    func changeTodoItem(_ item: TodoItem) async throws {
        var request = URLRequest(url: baseURL.appending(path: item.id))
        request.httpMethod = .post
        request.httpBody = try! await serialization(
            json: ["element": (item.json as! [String: Any]).toCovertFormatTodoItem(true)]
        )
        request.setValue(token, forHTTPHeaderField: .authorization)
        let (_, response) = try await URLSession.shared.dataTask(for: request)
        let infoResponse = response.toHTTPURLResponse()
        if let error = NetworkingServiceError(rawValue: infoResponse.statusCode) {
            throw error
        }
    }
    
    func deleteTodoItem(id: String) async throws {
        var request = URLRequest(url: baseURL.appending(path: id))
        request.httpMethod = .delete
        request.setValue(token, forHTTPHeaderField: .authorization)
        let (_, response) = try await URLSession.shared.dataTask(for: request)
        let infoResponse = response.toHTTPURLResponse()
        if let error = NetworkingServiceError(rawValue: infoResponse.statusCode) {
            throw error
        }
    }
    
}
