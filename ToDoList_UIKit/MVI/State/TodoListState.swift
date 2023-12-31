//
//  TodoListState.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 21.06.2023.
//

import Foundation

 
struct TodoListState: MVIState {
    var fileCache = FileCache(CoreDatabase())
    var selectedItem: TodoItem?
    var isShowingMakeItem = false
    var isDirty = false
    let networkService = DefaultNetworkingService()
}
