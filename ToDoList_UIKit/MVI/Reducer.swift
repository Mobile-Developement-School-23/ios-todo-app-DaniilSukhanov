//
//  Reducer.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 21.06.2023.
//

import Foundation

protocol Reducer {
    associatedtype ActionType
    associatedtype StateType: MVIState
    func callAsFunction(state: StateType, action: ActionType) async -> StateType
}
 
