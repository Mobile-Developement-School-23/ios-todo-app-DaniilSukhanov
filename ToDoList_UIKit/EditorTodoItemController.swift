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
    var textField: UITextField
    var calendare: UICalendarView
    var buttonDelete: UIButton
    var selectedDate: Date?
    var saveButton: UIButton
    var cancelButton: UIButton
    
    init(store: TodoListStore) {
        self.store = store
        stackView = .init()
        textField = .init()
        calendare = .init()
        buttonDelete = .init()
        saveButton = .init()
        cancelButton = .init()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        var constraint: NSLayoutConstraint
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(actionCancelButton), for: .touchDown)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.backgroundColor = .white
        stackView.addArrangedSubview(cancelButton)
        constraint = cancelButton.widthAnchor.constraint(equalToConstant: .init(Int.max))
        constraint.priority = .init(999)
        constraint.isActive = true
        constraint = cancelButton.heightAnchor.constraint(equalToConstant: 40)
        constraint.isActive = true
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.blue, for: .normal)
        saveButton.backgroundColor = .white
        saveButton.addTarget(self, action: #selector(actionButtonSave), for: .touchDown)
        stackView.addArrangedSubview(saveButton)
        constraint = saveButton.widthAnchor.constraint(equalToConstant: .init(Int.max))
        constraint.priority = .init(999)
        constraint.isActive = true
        constraint = saveButton.heightAnchor.constraint(equalToConstant: 40)
        constraint.isActive = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.text = store.state.selectedItem!.text
        constraint = textField.widthAnchor.constraint(equalToConstant: .init(Int.max))
        constraint.priority = .init(999)
        constraint.isActive = true
        
        calendare.translatesAutoresizingMaskIntoConstraints = false
        calendare.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        stackView.addArrangedSubview(calendare)
        constraint = calendare.widthAnchor.constraint(equalToConstant: .init(Int.max))
        constraint.priority = .init(999)
        constraint.isActive = true
        
        buttonDelete.translatesAutoresizingMaskIntoConstraints = false
        buttonDelete.setTitle("Удалить", for: .normal)
        buttonDelete.setTitleColor(.red, for: .normal)
        buttonDelete.addTarget(self, action: #selector(actionButtonDelete), for: .touchDown)
        buttonDelete.backgroundColor = .white
        stackView.addArrangedSubview(buttonDelete)
        constraint = stackView.widthAnchor.constraint(equalToConstant: .init(Int.max))
        constraint.priority = .init(999)
        constraint.isActive = true
        constraint = stackView.heightAnchor.constraint(equalToConstant: 100)
        constraint.isActive = true
    }
    
    @objc func actionButtonDelete() {
        store.process(.removeItem(store.state.selectedItem!))
    }
    
    @objc func actionButtonSave() {
        let item = TodoItem(
            text: textField.text!,
            importance: .important,
            isMake: false,
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
