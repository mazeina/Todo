//
//  ViewController.swift
//  Todo
//
//  Created by Полина Дусин on 25.05.2022.
//

import UIKit

class TodoListViewController: UIViewController {
    var itemArray = ["Find Mike", "Buy Eggs", "Buy tomatoes"]
    
    let defaults = UserDefaults.standard
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ReuseTodoTableViewCell.self, forCellReuseIdentifier: ReuseTodoTableViewCell.identifire)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        // BarButtonItem
       navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationController?.navigationBar.tintColor = .white
        
        //UserDefaults
        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
            itemArray = items
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.title = "Todoey"
        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoye Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // Что случитится, когда пользователь нажмёт на кнопку "добавить элемент" на нашем UIAlertAction
            self.itemArray.append(textField.text!)
            
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)

        present(alert, animated: true)
    }
}

//MARK: - UITableViewDataSource methods
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notes = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseTodoTableViewCell.identifire, for: indexPath) as! ReuseTodoTableViewCell
        cell.textLabel?.text = notes
        
        return cell
    }
}

//MARK: - UITableViewDelegate methods
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SwiftUI
import SwiftUI

struct AuthenticationViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = TodoListViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<AuthenticationViewControllerProvider.ContainerView>) -> TodoListViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: AuthenticationViewControllerProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<AuthenticationViewControllerProvider.ContainerView>) {
            
        }
    }
}
