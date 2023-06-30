//
//  UICounterLabel.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 30.06.2023.
//

import Foundation
import UIKit


class UICounterLabel: UILabel {
    var store: TodoListStore
    
    init(store: TodoListStore) {
        self.store = store
        super.init(frame: .zero)
        store.subscribe { state in
            self.update(state: state)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(state: TodoListState) {
        let amountMakeItem = store.state.fileCache.items.filter({ $0.isMake }).count
        text = "Выполнено - \(amountMakeItem)"
    }
    
    func loadView() {
        let amountMakeItem = store.state.fileCache.items.filter({ $0.isMake }).count
        text = "Выполнено - \(amountMakeItem)"
    }
}

