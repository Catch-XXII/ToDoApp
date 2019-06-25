//
//  ItemsTableViewController.swift
//  ToDoApp
//
//  Created by Cüneyd on 24.06.2019.
//  Copyright © 2019 J8R. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemsTableViewController: SwipeTableViewController {

    
    var toDoItems: Results<Item>?
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!

    var selectedCategory: Category?
    {
        didSet
        {
            loadItems()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
       
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    
    //MARK: - NavBar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String)
    {
        guard let navBar = (navigationController?.navigationBar) else {fatalError("Navigation controller does not exist")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        searchBarOutlet.barTintColor = navBarColor

    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return toDoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)        
        if let item = toDoItems?[indexPath.row]
        {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count))
            {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
    
            // Ternary operator ==> value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else
        {
            cell.textLabel?.text = "No Items Added Yet"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch {
                print("Error saving done status \(error)")
            }
            
        }
        tableView.reloadData()
        // flash in gray selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addItemsClicked(_ sender: Any)
    {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New To Do", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch
                {
                    print("Error while saving the realm object ==> \(error)")
                }
            }
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems()
    {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath)
    {
        if let item = toDoItems?[indexPath.row]
        {
            do
            {
                try realm.write
                {
                    realm.delete(item)
                }
            }
            catch
            {
                print("Error while deleting object from realm in items table")
            }
            
        }
    }
} // End of Class

//MARK: - Search bar methods

extension ItemsTableViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text?.count == 0
        {
            loadItems()
            DispatchQueue.main.async
            {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
