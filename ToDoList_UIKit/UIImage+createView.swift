//
//  UIImage+createView.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 27.06.2023.
//

import Foundation
import UIKit

enum ImageType: String {
    case plusCircle
    case whiteСheckmarkCircle
    case greenСheckmarkCircle
    case info
    case invisibilityСheckmarkCircle
    case trash
    case doubleRedExclamationMarks
    case arrow
}

extension UIImage {
    static func create(type image: ImageType) -> UIImage {
        let string = image.rawValue
        let name = string.first!.uppercased() + string.dropFirst()
        return .init(named: name)!
    }
}

extension UIImageView {
    static func create(type image: ImageType) -> UIImageView {
        .init(image: UIImage.create(type: image))
    }
}
