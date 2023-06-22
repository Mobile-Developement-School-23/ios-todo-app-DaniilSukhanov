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
    
    
    init(store: TodoListStore) {
        self.store = store
        todoListView = .init(store: store)
        buttonAdd = .init()
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scrollView = UIScrollView()
        scrollView.frame = .init(x: 0, y: 0,
                                 width: 400,
                                 height: 400)
        todoListView.frame = .init(x: 0, y: 0,
                                   width: 400,
                                   height: todoListView.contentSize.height)
        
        todoListView.backgroundColor = .brown
        scrollView.contentSize = todoListView.contentSize
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(todoListView)
        
        view.addSubview(scrollView)
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        
        buttonAdd.titleLabel?.text = "test"
        buttonAdd.widthAnchor.constraint(equalToConstant: 44).isActive = true
        buttonAdd.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonAdd.backgroundColor = .green
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonAdd.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        view.addSubview(buttonAdd)
    }


}


