//
//  TodoListReduce.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 21.06.2023.
//

import Foundation
import CocoaLumberjackSwift

class TodoListReducer: Reducer {
    enum TodoListAction {
        case addItem(TodoItem)
        case removeItem(TodoItem)
        case selectedItem(TodoItem?)
        case showMaking(Bool)
        case loadItems, saveItems
    }
    typealias ActionType = TodoListAction
    typealias StateType = TodoListState

    func callAsFunction(state: StateType, action: ActionType) -> StateType {
        var newState = state
        switch action {
        case .addItem(let item):
            DDLogInfo("\(String.logFormat()) выполнение addItem")
            newState.selectedItem = nil
            newState.fileCache.append(item)
        case .removeItem(let item):
            DDLogInfo("\(String.logFormat()) выполнение removeItem")
            newState.selectedItem = nil
            newState.fileCache.remove(id: item.id)
        case .selectedItem(let item):
            DDLogInfo("\(String.logFormat()) выполнение selectedItem")
            newState.selectedItem = item
        case .loadItems:
            DDLogInfo("\(String.logFormat()) выполнение loadItems")
            if !newState.fileCache.loadJSON(filename: "json.json") {
                newState.fileCache.createFile(filename: "json.json")
                newState.fileCache.append(.init(text: "task1", importance: .usual, isMake: true))
                newState.fileCache.append(.init(text: "task2", importance: .unimportant, isMake: false))
                newState.fileCache.append(.init(text: "task3", importance: .unimportant, isMake: false))
                newState.fileCache.append(.init(text: "task4", importance: .usual, isMake: false))
                newState.fileCache.append(.init(text: "task5", importance: .unimportant, isMake: true))
                newState.fileCache.saveJSON(filename: "json.json")
                newState.fileCache.loadJSON(filename: "json.json")
            }

        case .saveItems:
            DDLogInfo("\(String.logFormat()) выполнение saveItems")
            newState.fileCache.saveJSON(filename: "json.json")
        case .showMaking(let flag):
            DDLogInfo("\(String.logFormat()) выполнение showMaking")
            newState.isShowingMakeItem = flag
        }
        return newState
    }
}
