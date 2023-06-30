//
//  TodoListState.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 21.06.2023.
//

import Foundation

struct TodoListState: State {
    var fileCache = FileCache()
    var selectedItem: TodoItem?
    var isShowingMakeItem = false
}
