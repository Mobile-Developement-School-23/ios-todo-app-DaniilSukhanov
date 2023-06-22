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
        case selectedItem(TodoItem)
    }
    typealias ActionType = TodoListAction
    typealias StateType = TodoListState
    
    func callAsFunction(state: StateType, action: ActionType) -> StateType {
        var newState = state
        switch action {
        case .addItem(let item):
            newState.fileCache.append(item)
        case .removeItem(let item):
            newState.fileCache.remove(id: item.id)
        case .selectedItem(let item):
            newState.selectedItem = item
        }
        return newState
    }
}
