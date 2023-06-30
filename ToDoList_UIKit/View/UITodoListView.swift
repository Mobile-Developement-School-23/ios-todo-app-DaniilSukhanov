//
//  File.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 22.06.2023.
//
import UIKit
import Foundation

class UITodoListView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var store: TodoListStore
    
    init(store: TodoListStore) {
        self.store = store
        super.init(frame: .zero, style: .plain)
        store.subscribe { state in
            self.update(state: state)
        }
        setupView()
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(state: TodoListState) {
        setNeedsDisplay()
        reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.state.fileCache.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = store.state.fileCache.items[indexPath.row]
        store.process(.selectedItem(item))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = store.state.fileCache.items[indexPath.row]
        if item.isMake && !store.state.isShowingMakeItem {
            return 0.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        .init(
            actions: [
                .init(style: .destructive, title: nil) { (_, _, _) in
                    let item = self.store.state.fileCache.items[indexPath.row]
                    let newItem = TodoItem(
                        text: item.text,
                        importance: item.importance,
                        isMake: true,
                        createdDate: item.createdDate,
                        deadline: item.deadline,
                        changedDate: item.changedDate,
                        id: item.id
                    )
                    self.store.process(.addItem(newItem))
                }.design {
                    $0.image = UIImage.create(type: .invisibilityСheckmarkCircle)
                    $0.backgroundColor = .green
                }
            ]
        )
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        .init(
            actions: [
                .init(style: .destructive, title: nil) { (_, _, _) in
                    self.store.process(.removeItem(self.store.state.fileCache.items[indexPath.row]))
                }.design {
                    $0.image = UIImage.create(type: .trash)
                    $0.backgroundColor = .red
                }
            ]
        )
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = store.state.fileCache.items[indexPath.row]
        let cell = self.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! UITodoListCell
        cell.configure(with: item)
        if !store.state.isShowingMakeItem {
            cell.isHidden = item.isMake
        }
        return cell
    }
    
    private func setupView() {
        delegate = self
        dataSource = self
        register(UITodoListCell.self, forCellReuseIdentifier: "MyCell")
    }
}
