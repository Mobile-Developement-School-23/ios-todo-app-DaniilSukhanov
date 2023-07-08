//
//  UITextEditor.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 29.06.2023.
//

import Foundation
import UIKit

class UITextEditor: UITextView {
    var store: TodoListStore
    var heightConstraint: NSLayoutConstraint?

    init(store: TodoListStore) {
        self.store = store
        super.init(frame: .zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        var text = store.state.selectedItem?.text ?? "Введите текст"
        if text == "" {
            text = "Введите текст"
        }
        self.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UITextEditor: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textSize = self.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        guard var heightConstraint else {
            return
        }
        heightConstraint.isActive = false
        heightConstraint = textView.heightAnchor.constraint(equalToConstant: textSize.height)
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint
    }
}
