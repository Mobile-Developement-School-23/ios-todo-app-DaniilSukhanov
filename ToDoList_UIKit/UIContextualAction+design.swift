//
//  UIContextualAction+design.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 28.06.2023.
//

import Foundation
import UIKit

extension UIContextualAction {
    func design(_ clouser: (Self) -> ()) -> Self {
        clouser(self)
        return self
    }
}

