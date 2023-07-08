//
//  UIRadioImportance.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 29.06.2023.
//

import Foundation
import UIKit

class UIRadioImportance: UIView, UITextViewDelegate {
    var importance: TodoItem.Importance
    var segmentedControl: UISegmentedControl
    var titleView: UILabel
    var store: TodoListStore

    init(store: TodoListStore) {
        titleView = .init()
        self.store = store
        segmentedControl = .init()
        importance = store.state.selectedItem?.importance ?? .usual
        super.init(frame: .zero)
        loadView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadView() {
        titleView.text = "Важность"
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            titleView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            titleView.widthAnchor.constraint(equalToConstant: 120),
            titleView.heightAnchor.constraint(equalTo: layoutMarginsGuide.heightAnchor)
        ])

        segmentedControl.addTarget(self, action: #selector(actionRadioImportance), for: .allEvents)
        segmentedControl.insertSegment(withTitle: nil, at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Нет", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: nil, at: 2, animated: true)
        segmentedControl.setImage(.create(type: .arrow), forSegmentAt: 0)
        segmentedControl.setImage(.create(type: .doubleRedExclamationMarks), forSegmentAt: 2)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.leftAnchor.constraint(equalTo: titleView.rightAnchor, constant: 16),
            segmentedControl.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            segmentedControl.heightAnchor.constraint(equalTo: layoutMarginsGuide.heightAnchor),
            segmentedControl.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor)
        ])

    }

    @objc func actionRadioImportance(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: importance = .unimportant
        case 1: importance = .usual
        case 2: importance = .important
        default: break
        }
    }
}
