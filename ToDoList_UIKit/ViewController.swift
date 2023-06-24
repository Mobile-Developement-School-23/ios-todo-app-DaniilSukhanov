//
//  ViewController.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 17.06.2023.
//

import UIKit

class ViewController: UIViewController {
    var todoListView: UITodoListView
    var store: TodoListStore
    var buttonAdd: UIButton
    var scrollView: UIScrollView
    var buttonShowMake: ButtonTodoList
    
    init(store: TodoListStore) {
        self.store = store
        todoListView = .init(store: store)
        scrollView = .init()
        buttonAdd = .init()
        buttonShowMake = .init(store: store)
        store.process(.loadItems)
        super.init(nibName: nil, bundle: nil)
        store.subscribe { state in
            self.update(state: state)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(state: TodoListState) {
        if state.selectedItem != nil {
            let controller = EditorTodoItemController(store: store)
            if let sheetController = controller.sheetPresentationController {
                sheetController.presentedViewController.isModalInPresentation = true
                sheetController.detents = [.large(), .large()]
            }
            present(controller, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var constraint: NSLayoutConstraint
        buttonShowMake.backgroundColor = .blue
        buttonShowMake.addTarget(self, action: #selector(showMake), for: .touchDown)
        view.addSubview(buttonShowMake)
        buttonShowMake.translatesAutoresizingMaskIntoConstraints = false
        constraint = buttonShowMake.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        constraint.isActive = true
        constraint = buttonShowMake.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor)
        constraint.isActive = true
        constraint = buttonShowMake.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        constraint.isActive = true
        constraint = buttonShowMake.heightAnchor.constraint(equalToConstant: 40)
        constraint.isActive = true
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        constraint = scrollView.widthAnchor.constraint(equalToConstant: 343)
        constraint.priority = .init(998)
        constraint.isActive = true
        constraint = scrollView.topAnchor.constraint(equalTo: buttonShowMake.bottomAnchor)
        constraint.isActive = true
        constraint = scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        constraint.isActive = true
        constraint = scrollView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 16)
        constraint.priority = .init(999)
        constraint.isActive = true
        constraint = scrollView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -16)
        constraint.priority = .init(999)
        constraint.isActive = true
        scrollView.addSubview(todoListView)
        scrollView.contentSize.height = CGFloat(store.state.fileCache.items.count * 66)
        todoListView.frame = .init(x: 0, y: 0, width: 0, height: 0)
        todoListView.translatesAutoresizingMaskIntoConstraints = false
        todoListView.backgroundColor = .black
        constraint = todoListView.widthAnchor.constraint(equalToConstant: .init(Int.max))
        constraint.priority = .defaultLow
        constraint.isActive = true
        constraint = todoListView.heightAnchor.constraint(
            equalToConstant: CGFloat(store.state.fileCache.items.count * 66)
        )
        constraint.isActive = true
        
        
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        buttonAdd.titleLabel?.text = "test"
        buttonAdd.widthAnchor.constraint(equalToConstant: 44).isActive = true
        buttonAdd.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonAdd.backgroundColor = .green
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        buttonAdd.layer.cornerRadius = 22
        buttonAdd.layer.masksToBounds = true
        buttonAdd.addTarget(self, action: #selector(actionButtonAdd), for: .touchDown)
        view.addSubview(buttonAdd)
        
        constraint = buttonAdd.bottomAnchor.constraint(
            equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -54
        )
        constraint.priority = .init(999)
        constraint.isActive = true
        constraint = buttonAdd.leftAnchor.constraint(
            equalTo: view.layoutMarginsGuide.leftAnchor, constant: 166
        )
        constraint.priority = .init(999)
        constraint.isActive = true
        constraint = buttonAdd.rightAnchor.constraint(
            equalTo: view.layoutMarginsGuide.rightAnchor, constant: -166
        )
        constraint.priority = .init(999)
        constraint.isActive = true
    }
    
    @objc func actionButtonAdd() {
        store.process(.selectedItem(.init(text: "", importance: .usual, isMake: false)))
    }
    
    @objc func showMake() {
        store.process(.showMaking(!store.state.isShowingMakeItem))
    }
}

class ButtonTodoList: UIButton {
    var store: TodoListStore
    
    init(store: TodoListStore) {
        self.store = store
        super.init(frame: .zero)
        store.subscribe { state in
            self.update(state: state)
        }
    }
    
    func update(state: TodoListState) {
        setTitle(state.isShowingMakeItem ? "Скрыть" : "Показать", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
