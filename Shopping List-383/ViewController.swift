//
//  ViewController.swift
//  Shopping List-383
//
//  Created by Jeremiah Steidinger on 5/5/18.
//  Copyright © 2018 Blue Diamond Developers. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private var shoppingListItems = [ShoppingListItem]()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return shoppingListItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_item", for: indexPath)
        
        if indexPath.row < shoppingListItems.count
        {
            let item = shoppingListItems[indexPath.row]
            cell.textLabel?.text = item.item
            
            let accessory: UITableViewCellAccessoryType = item.checked ? .checkmark: .none
            cell.accessoryType = accessory
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < shoppingListItems.count
        {
            let item = shoppingListItems[indexPath.row]
            item.checked = !item.checked
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc
    func didTapAddItemButton(_ sender: UIBarButtonItem)
    {
        let alert = UIAlertController(
            title: "Add Item",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .whileEditing
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: {(_) in
            if let title = alert.textFields?[0].text
            {
                self.addNewShoppingListItem(title: title)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addNewShoppingListItem(title: String)
    {
        let newIndex = shoppingListItems.count
        
        shoppingListItems.append(ShoppingListItem(item: title))
        
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if indexPath.row < shoppingListItems.count
        {
            shoppingListItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My List"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector
        (ViewController.didTapAddItemButton(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        do
        {
            self.shoppingListItems = try [ShoppingListItem].readFromPersistence()
        }
        catch let error as NSError
        {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError
            {
                NSLog("No persistence file found, not necesserially an error...")
            }
            else
            {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not load shopping list.",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                NSLog("Error loading from persistence: \(error)")
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc
    public func applicationDidEnterBackground(_ notification: NSNotification)
    {
        do
        {
            try shoppingListItems.writeToPersistence()
        }
        catch let error
        {
            NSLog("Error writing to persistence: \(error)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
