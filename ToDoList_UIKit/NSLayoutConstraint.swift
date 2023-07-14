//
//  NSLayoutConstraint.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 30.06.2023.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: Float) -> Self {
        self.priority = .init(priority)
        return self
    }
}
