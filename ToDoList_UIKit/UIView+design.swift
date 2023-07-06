//
//  UIView+design.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 29.06.2023.
//

import Foundation
import UIKit

extension UIView {
    func design(_ clouser: (Self) -> Void) -> Self {
        clouser(self)
        return self
    }
}
