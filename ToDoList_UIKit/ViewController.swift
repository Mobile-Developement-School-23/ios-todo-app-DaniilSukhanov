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
    var buttonShowMake: ButtonTodoList
    var titleCounter: UICounterLabel
    
    init(store: TodoListStore) {
        self.store = store
        todoListView = .init(store: store)
        buttonAdd = .init()
        buttonShowMake = .init(store: store)
        titleCounter = .init(store: store)
        super.init(nibName: nil, bundle: nil)
        store.subscribe { state in
            self.update(state: state)
        }
        Task {
            await store.process(.loadItems)
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
            DispatchQueue.main.async {
                self.present(controller, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = UILabel()
        view.backgroundColor = .systemBackground
        title.text = "Мои дела"
        title.textAlignment = .left
        title.font = .systemFont(ofSize: 34)
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            title.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            title.heightAnchor.constraint(equalToConstant: 41),
            title.widthAnchor.constraint(equalToConstant: 158)
        ])
        
        buttonAdd.tintColor = .blue
        buttonShowMake.addTarget(self, action: #selector(showMake), for: .touchDown)
        buttonShowMake.setTitleColor(.systemBlue, for: .normal)
        view.addSubview(buttonShowMake)
        buttonShowMake.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonShowMake.topAnchor.constraint(equalTo: title.bottomAnchor),
            buttonShowMake.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: 32),
            buttonShowMake.heightAnchor.constraint(equalToConstant: 20),
            buttonShowMake.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        titleCounter.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleCounter)
        NSLayoutConstraint.activate([
            titleCounter.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 32),
            titleCounter.topAnchor.constraint(equalTo: title.bottomAnchor),
            titleCounter.heightAnchor.constraint(equalToConstant: 20),
            titleCounter.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        view.addSubview(todoListView)
        todoListView.backgroundColor = .systemBackground
        todoListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            todoListView.topAnchor.constraint(equalTo: buttonShowMake.bottomAnchor),
            todoListView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            todoListView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            todoListView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        ])
    
        buttonAdd.widthAnchor.constraint(equalToConstant: 44).isActive = true
        buttonAdd.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonAdd.backgroundColor = .blue
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        buttonAdd.layer.cornerRadius = 22
        buttonAdd.layer.masksToBounds = true
        buttonAdd.addTarget(self, action: #selector(actionButtonAdd), for: .touchDown)
        view.addSubview(buttonAdd)
        
        let image = UIImage.create(type: .plusCircle)
        buttonAdd.setImage(image, for: .normal)
        
        NSLayoutConstraint.activate([
            buttonAdd.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonAdd.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            buttonAdd.widthAnchor.constraint(equalToConstant: 44),
            buttonAdd.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func actionButtonAdd() {
        Task {
            await store.process(.selectedItem(.init(text: "", importance: .usual, isMake: false)))
        }
    }
    
    @objc func showMake() {
        Task {
            await store.process(.showMaking(!store.state.isShowingMakeItem))
        }
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
        DispatchQueue.main.async {
            self.setTitle(state.isShowingMakeItem ? "Скрыть" : "Показать", for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
} 
