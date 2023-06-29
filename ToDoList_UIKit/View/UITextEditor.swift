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
    
    init(store: TodoListStore) {
        self.store = store
        super.init(frame: .zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        text = store.state.selectedItem?.text ?? ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UITextEditor: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textSize = self.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        textView.heightAnchor.constraint(equalToConstant: textSize.height).isActive = true
        updateConstraints()
    }
}
