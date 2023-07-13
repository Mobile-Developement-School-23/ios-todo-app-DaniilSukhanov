//
//  Store.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 21.06.2023.
//

import Foundation

protocol Store {
    associatedtype ReducerType: Reducer
    associatedtype StateType: State
    
    var state: StateType { get }
    var subscribers: [(StateType) -> Void] { get }
     
    func subscribe(_ closure: @escaping (StateType) -> Void)
    func process(_ action: ReducerType.ActionType) async
}
