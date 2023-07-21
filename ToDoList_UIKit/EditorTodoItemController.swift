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
    var toolBar: UIToolbar

    init(store: TodoListStore) {
        self.store = store
        stackView = .init()
        calendare = .init()
        buttonDelete = .init()
        saveButton = .init()
        cancelButton = .init()
        scrollView = .init()
        toolBar = .init()
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
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionHiddenKeyboard)))

        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.items = [
            .init(title: "Отмена", style: .done, target: self, action: #selector(actionCancelButton)).design {
                $0.tintColor = .red
            },
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            .init(title: "Дело", style: .done, target: self, action: nil).design {
                $0.tintColor = .white
            },
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            .init(title: "Сохранение", style: .done, target: nil, action: #selector(actionButtonSave))
        ]
        view.addSubview(toolBar)
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: view.topAnchor),
            toolBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 56)
        ])

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 16),
            scrollView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
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
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        textEditor.translatesAutoresizingMaskIntoConstraints = false
        textEditor.isScrollEnabled = false
        textEditor.layer.borderWidth = 2
        textEditor.layer.borderColor = UIColor.darkGray.cgColor
        textEditor.font = .systemFont(ofSize: 20)
        stackView.addArrangedSubview(textEditor)

        stackView.addArrangedSubview(radioImportance)

        calendare.translatesAutoresizingMaskIntoConstraints = false
        calendare.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        stackView.addArrangedSubview(calendare)
        calendare.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true

        buttonDelete.translatesAutoresizingMaskIntoConstraints = false
        buttonDelete.heightAnchor.constraint(equalToConstant: 30).withPriority(999).isActive = true
        buttonDelete.setTitle("Удалить", for: .normal)
        buttonDelete.setTitleColor(.red, for: .normal)
        buttonDelete.addTarget(self, action: #selector(actionButtonDelete), for: .touchDown)
        stackView.addArrangedSubview(buttonDelete)

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft, .landscapeRight:
            buttonDelete.isHidden = true
            calendare.isHidden = true
            saveButton.isHidden = true
            cancelButton.isHidden = true
            radioImportance.isHidden = true
            toolBar.isHidden = true
        default:
            buttonDelete.isHidden = false
            toolBar.isHidden = false
            calendare.isHidden = false
            saveButton.isHidden = false
            cancelButton.isHidden = false
            radioImportance.isHidden = false
        }
    }

    @objc func actionHiddenKeyboard() {
        textEditor.endEditing(true)
    }

    @objc func actionButtonDelete() {
        Task {
            await store.process(.removeItem(store.state.selectedItem!))
        }
        
    }

    @objc func actionButtonSave() {
        let item = TodoItem(
            text: textEditor.text!,
            importance: radioImportance.importance,
            isMake: store.state.selectedItem?.isMake ?? false,
            deadline: selectedDate,
            id: store.state.selectedItem?.id ?? UUID().uuidString
        )
        Task {
            await store.process(.addItem(item))
        }
    }

    @objc func actionCancelButton() {
        Task {
            await store.process(.selectedItem(nil))
        }
    }
}

extension EditorTodoItemController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selectedDate = dateComponents?.date
    }
}
