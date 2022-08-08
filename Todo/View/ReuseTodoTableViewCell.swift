//
//  ReuseTodoTableViewCell.swift
//  Todo
//
//  Created by Полина Дусин on 25.05.2022.
//

import UIKit

class ReuseTodoTableViewCell: UITableViewCell {
    static let identifire = "TodoItemCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
