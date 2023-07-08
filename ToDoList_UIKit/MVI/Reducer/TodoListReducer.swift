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
    
    fileprivate func networkLoad(state: StateType, newState: inout StateType) async {
        if state.isDirty {
            do {
                print(0)
                try await state.networkService.getTodoItems().forEach {
                    newState.fileCache.append($0)
                }
                newState.isDirty = true
            } catch {
                newState.isDirty = false
            }
        }
    }

    func callAsFunction(state: StateType, action: ActionType) async -> StateType {
        var newState = state
        switch action {
        case .addItem(let item):
            newState.selectedItem = nil
            newState.fileCache.append(item)
            await networkLoad(state: state, newState: &newState)
        case .removeItem(let item):
            newState.selectedItem = nil
            newState.fileCache.remove(id: item.id)
            await networkLoad(state: state, newState: &newState)
        case .selectedItem(let item):
            newState.selectedItem = item
        case .loadItems:
            newState.fileCache.loadJSON(filename: "json.json")
            do {
                try await state.networkService.getTodoItems().forEach {
                    newState.fileCache.append($0)
                }
            } catch {
                newState.isDirty = true
            }
        case .saveItems:
            newState.fileCache.saveJSON(filename: "json.json")
            await networkLoad(state: state, newState: &newState)
        case .showMaking(let flag):
            newState.isShowingMakeItem = flag
            await networkLoad(state: state, newState: &newState)
        }
        return newState 
    }
}
