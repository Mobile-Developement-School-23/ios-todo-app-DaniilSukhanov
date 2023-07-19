//
//  SwiftUITodoListState.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 17.07.2023.
//

import Foundation

struct SwiftUITodoListState: MVIState {
    var fileCache = FileCache(CoreDatabase())
    var isDirty = false
    let networkService = DefaultNetworkingService()
}
