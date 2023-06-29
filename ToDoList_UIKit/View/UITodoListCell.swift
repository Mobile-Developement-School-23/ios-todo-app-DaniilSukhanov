//
//  UITodoListCell.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 26.06.2023.
//

import Foundation
import UIKit


class UITodoListCell: UITableViewCell {
    var circle: UIView
    var title: UILabel

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        circle = .init()
        title = .init()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadView()
    }
    
    private func loadView() {
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 12
        circle.layer.masksToBounds = true
        circle.layer.borderWidth = 1.5
        circle.clipsToBounds = true
        addSubview(circle)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        
        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            circle.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            circle.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            circle.heightAnchor.constraint(equalToConstant: 24),
            circle.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            title.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            title.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            title.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configure(with item: TodoItem) {
        title.text = item.text
        if item.isMake {
            circle.backgroundColor = .green
            circle.layer.borderColor = UIColor.green.cgColor
        } else if item.importance == .important {
            circle.layer.borderColor = UIColor.red.cgColor
            circle.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 0.2)
        } else {
            circle.layer.borderColor = UIColor.gray.cgColor
            circle.backgroundColor = .systemBackground
            
        }
        
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


