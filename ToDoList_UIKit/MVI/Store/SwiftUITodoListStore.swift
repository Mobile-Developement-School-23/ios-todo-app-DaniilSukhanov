//
//  SwiftUITodoListStore.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 17.07.2023.
//

import Foundation
import SwiftUI

@MainActor class SwiftUITodoListStore: SwiftUIStore, ObservableObject {
    typealias ReducerType = SwiftUITodoListReducer
    typealias StateType = SwiftUITodoListState
    
    @Published private(set) var state: StateType
    private(set) var reducer: ReducerType
     
    init() {
        self.reducer = .init()
        self.state = .init()
    }
    func process(_ action: SwiftUITodoListReducer.TodoListAction) async {
        state = await reducer(state: state, action: action)
    }
}
