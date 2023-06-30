//
//  TodoListReduce.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 21.06.2023.
//

import Foundation

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
            newState.selectedItem = nil
            newState.fileCache.append(item)
        case .removeItem(let item):
            newState.selectedItem = nil
            newState.fileCache.remove(id: item.id)
        case .selectedItem(let item):
            newState.selectedItem = item
        case .loadItems:
            if !newState.fileCache.loadJSON(filename: "json.json") {
                newState.fileCache.createFile(filename: "json.json")
                newState.fileCache.append(.init(text: "task1", importance: .important, isMake: true))
                newState.fileCache.append(.init(text: "task2", importance: .unimportant, isMake: false))
                newState.fileCache.append(.init(text: "task3", importance: .unimportant, isMake: false))
                newState.fileCache.append(.init(text: "task4", importance: .important, isMake: false))
                newState.fileCache.append(.init(text: "task5", importance: .unimportant, isMake: true))
                newState.fileCache.saveJSON(filename: "json.json")
                newState.fileCache.loadJSON(filename: "json.json")
            }
            
        case .saveItems:
            newState.fileCache.saveJSON(filename: "json.json")
        case .showMaking(let flag):
            newState.isShowingMakeItem = flag
        }
        return newState 
    }
}
