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
    var items = [TodoItem]()
    let items_ = (0...100).map(String.init)
    
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
        contentSize.height = CGFloat(items_.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items_.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalToConstant: cell.intrinsicContentSize.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: cell.intrinsicContentSize.height).isActive = true
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.widthAnchor.constraint(equalToConstant: 24).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        circle.layer.cornerRadius = 12
        circle.layer.masksToBounds = true
        circle.backgroundColor = .green
        stackView.addArrangedSubview(circle)
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.widthAnchor.constraint(equalToConstant: 252).isActive = true
        title.heightAnchor.constraint(equalToConstant: 24).isActive = true
        title.text = items_[indexPath.row]
        stackView.addArrangedSubview(title)
        cell.contentView.addSubview(stackView)
        return cell
    }
    
    private func setupView() {
        isScrollEnabled = false
        delegate = self
        dataSource = self
        register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    }
}
