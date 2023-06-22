//
//  TodoListStore.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 21.06.2023.
//

import Foundation

class TodoListStore: Store {
    typealias ReducerType = TodoListReducer
    typealias StateType = TodoListState
    
    private(set) var state: StateType
    private(set) var reducer: ReducerType
    private(set) var subscribers = [(TodoListState) -> Void]()
    
    init() {
        self.reducer = .init()
        self.state = .init()
    }
    
    func process(_ action: ReducerType.TodoListAction) {
        state = reducer(state: state, action: action)
        notifySubscribers()
    }
    
    func subscribe(_ closure: @escaping (TodoListState) -> Void) {
        subscribers.append(closure)
    }
    
    private func notifySubscribers() {
        for subscriber in subscribers {
            subscriber(state)
        }
    }
}
