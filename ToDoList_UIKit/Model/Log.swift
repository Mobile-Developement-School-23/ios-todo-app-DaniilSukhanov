//
//  Logger.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 19.06.2023.
//

import Foundation
import OSLog

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "None", category: category)
    }
}

extension String {
    static func logFormat(_ line: Int = #line, _ file: String = #fileID, _ function: String = #function ) -> Self {
        "[\(file) : \(function) : \(line)] "
    }
}

 
