//
//  Master2ViewController.swift
//  CoreDataTables
//
//  Created by Roselle Tanner on 3/14/17.
//  Copyright © 2017 Roselle Tanner. All rights reserved.
//

import UIKit
import CoreData

class Master2ViewController: MasterViewController {
    var myParent: Parent? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Children"
        if myParent == nil {
            self.navigationItem.rightBarButtonItem = nil
            self.setToolbarItems(nil, animated: false)
        }
    }

    override func addTapped(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add A Child", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertAction: UIAlertAction) in
            let nameField = alert.textFields![0] as UITextField
            self.insertNewChild(name: nameField.text!, parent: self.myParent!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func insertNewChild(name: String, parent: Parent) {
        let context = self.fetchedResultsController.managedObjectContext
        let newChild: Child
        if #available(iOS 10.0, *) {
            newChild = Child(context: context)
        } else {
            newChild = NSEntityDescription.insertNewObject(forEntityName: "Child", into: context) as! Child
        }
        
        // If appropriate, configure the new managed object.
        newChild.id = UUID().uuidString
        newChild.name = name
        newChild.parent = parent
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath) as! Child
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let child = self.fetchedResultsController.object(at: indexPath) as! Child
        self.configureCell(cell, withChild: child)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, withChild child: Child) {
        cell.textLabel!.text = child.name
    }

    // MARK: - Fetched results controller
    
    
    override var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {//NSFetchRequestResult
        //
        if _fetchedResultsController != nil { return _fetchedResultsController! }
        guard let myParent = myParent else { return NSFetchedResultsController() }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, *) {
            fetchRequest = Child.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "Child")
        }
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        print(myParent.id!)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "parent.id", myParent.id!)
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil) // ****cache name needs to be different for every fetchedResults****
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        print(_fetchedResultsController!.fetchedObjects!.count)
        _fetchedResultsController!.fetchedObjects!.forEach { (child: NSFetchRequestResult) in
            if let child = child as? Child {
                print("child: \(child.name!), myParent: \(myParent.name!), parent: \(child.parent!.name!)")
            }
        }
        return _fetchedResultsController!
    }

    
}
