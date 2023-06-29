//
//  EditorTodoItemController.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 24.06.2023.
//

import Foundation
import UIKit

class EditorTodoItemController: UIViewController {
    var store: TodoListStore
    var stackView: UIStackView
    var calendare: UICalendarView
    var buttonDelete: UIButton
    var selectedDate: Date?
    var saveButton: UIButton
    var cancelButton: UIButton
    var scrollView: UIScrollView
    var radioImportance: UIRadioImportance
    var textEditor: UITextEditor
    
    init(store: TodoListStore) {
        self.store = store
        stackView = .init()
        calendare = .init()
        buttonDelete = .init()
        saveButton = .init()
        cancelButton = .init()
        scrollView = .init()
        textEditor = .init(store: store)
        radioImportance = .init(store: store)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(actionCancelButton), for: .touchDown)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.backgroundColor = .white
        stackView.addArrangedSubview(cancelButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.blue, for: .normal)
        saveButton.backgroundColor = .white
        saveButton.addTarget(self, action: #selector(actionButtonSave), for: .touchDown)
        stackView.addArrangedSubview(saveButton)
        
        textEditor.translatesAutoresizingMaskIntoConstraints = false
        textEditor.layer.borderWidth = 3
        textEditor.isScrollEnabled = false
        textEditor.layer.borderColor = UIColor.gray.cgColor
        textEditor.font = .systemFont(ofSize: 20)
        textEditor.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stackView.addArrangedSubview(textEditor)
        
        stackView.addArrangedSubview(radioImportance)
        
        calendare.translatesAutoresizingMaskIntoConstraints = false
        calendare.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        stackView.addArrangedSubview(calendare)
        calendare.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        buttonDelete.translatesAutoresizingMaskIntoConstraints = false
        buttonDelete.setTitle("Удалить", for: .normal)
        buttonDelete.setTitleColor(.red, for: .normal)
        buttonDelete.addTarget(self, action: #selector(actionButtonDelete), for: .touchDown)
        buttonDelete.backgroundColor = .white
        stackView.addArrangedSubview(buttonDelete)
        
    }
    
    
    @objc func actionButtonDelete() {
        store.process(.removeItem(store.state.selectedItem!))
    }
    
    @objc func actionButtonSave() {
        let item = TodoItem(
            text: textEditor.text!,
            importance: radioImportance.importance,
            isMake: true,
            deadline: selectedDate
        )
        store.process(.addItem(item))
    }
    
    @objc func actionCancelButton() {
        store.process(.selectedItem(nil))
    }
}

extension EditorTodoItemController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selectedDate = dateComponents?.date
    }
}
