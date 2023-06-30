//
//  UIBarButtonItem+design.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 30.06.2023.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    func design(_ clouser: (Self) -> ()) -> Self {
        clouser(self)
        return self
    }
}
