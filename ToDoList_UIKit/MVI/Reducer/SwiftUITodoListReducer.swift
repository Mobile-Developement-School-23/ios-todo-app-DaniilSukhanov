//
//  SwiftUITodoListReducer.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 17.07.2023.
//

import Foundation

class SwiftUITodoListReducer: Reducer {
    enum TodoListAction {
        case addItem(TodoItem)
        case removeItem(String)
        case loadItems, saveItems
    }
    typealias ActionType = TodoListAction
    typealias StateType = SwiftUITodoListState
    
    fileprivate func networkLoad(state: StateType, newState: inout StateType) async {
        if state.isDirty {
            do {
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
            newState.fileCache.append(item)
            newState.fileCache.save()
            // await networkLoad(state: state, newState: &newState)
            // newState.fileCache.save()
        case .removeItem(let id):
            newState.fileCache.remove(id: id)
            newState.fileCache.save()
            // await networkLoad(state: state, newState: &newState)
            // newState.fileCache.save()
        case .loadItems:
            newState.fileCache.load()
            /*
             do {
             try await state.networkService.getTodoItems().forEach {
             newState.fileCache.append($0)
             }
             newState.fileCache.save()
             } catch {
             newState.isDirty = true
             }
             */
        case .saveItems:
            newState.fileCache.save()
            // await networkLoad(state: state, newState: &newState)
        }
        return newState
        
    }
}
