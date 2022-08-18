//
//  ViewController.swift
//  Todo
//
//  Created by Полина Дусин on 25.05.2022.
//

import UIKit

class TodoListViewController: UIViewController {
    var itemArray = [Item]()
    let dateFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ReuseTodoTableViewCell.self, forCellReuseIdentifier: ReuseTodoTableViewCell.identifire)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dateFilePath)
        
        tableView.dataSource = self
        tableView.delegate = self
        setupView()
        setupConstraints()
        loadItems()
        
        // BarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationController?.navigationBar.tintColor = .white
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
    
    //MARK: - Add new items
    @objc func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoye Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // Что случитится, когда пользователь нажмёт на кнопку "добавить элемент" на нашем UIAlertAction
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    //MARK: - Model manupulation methods
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dateFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dateFilePath!) {
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
}

//MARK: - Setup view, Setup constraints
extension TodoListViewController {
    private func setupView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
        ])
    }
}

//MARK: - UITableViewDataSource methods
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseTodoTableViewCell.identifire, for: indexPath) as! ReuseTodoTableViewCell
        cell.textLabel?.text = note.title
        
        // Отображение галочки в зависимости от состояния заметки
        cell.accessoryType = note.isDone ? .checkmark : .none
        
        return cell
    }
}

//MARK: - UITableViewDelegate methods
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Переключение состояния заметки true <-> false
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        
        saveItems()
        
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
