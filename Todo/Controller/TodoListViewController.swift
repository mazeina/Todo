//
//  ViewController.swift
//  Todo
//
//  Created by Полина Дусин on 25.05.2022.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: UIViewController {
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReuseTodoTableViewCell.self, forCellReuseIdentifier: ReuseTodoTableViewCell.identifire)
        
        return tableView
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = false
        
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        setupView()
        setupConstraints()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.flatPurple()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.title = "Todoey"
        navigationController?.navigationBar.standardAppearance = appearance
//                navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: - Add new items
    @objc func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoye Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // Что случитится, когда пользователь нажмёт на кнопку "добавить элемент" на нашем UIAlertAction
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.isDone = false
//            newItem.color = UIColor.flatSkyBlue().hexValue()
            
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
        do {
           try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
          itemArray = try context.fetch(request)
        } catch {
            print("Error fatching data from context, \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Setup view, Setup constraints
extension TodoListViewController {
    private func setupView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // AddBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationController?.navigationBar.tintColor = .white
        
        // Add searchController
        navigationItem.searchController = searchController
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
        cell.tintColor = UIColor.flatPurple()
        
        // Отображение галочки в зависимости от состояния заметки
        cell.accessoryType = note.isDone ? .checkmark : .none
        
        if let color = UIColor.flatWhite().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Удаление заметки по свайпу
        if editingStyle == .delete {
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveItems()
        }
    }
}

//MARK: - UISearchBarDelegate methods
extension TodoListViewController: UISearchBarDelegate {

    // Поиск заметок по соответствию
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
     
        loadItems(with: request)
    }
    
    // Когда в UISearchBar нет текста - отображаются исходные данные
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
