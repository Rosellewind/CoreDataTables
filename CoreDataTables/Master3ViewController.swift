//
//  Master3ViewController.swift
//  CoreDataTables
//
//  Created by Roselle Tanner on 3/15/17.
//  Copyright © 2017 Roselle Tanner. All rights reserved.
//

class Master3ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var myParent: Parent? = nil

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Children"
        if myParent != nil {
            // set the edit button
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            
            // set the add button
            self.navigationController?.setToolbarHidden(false, animated: false)
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(sender:)))
            self.setToolbarItems([space, addButton], animated: false)
        }

        
        
        
        
        
        
        

        //        if let split = self.splitViewController {
        //            let controllers = split.viewControllers
        //            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapped(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add A Child", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertAction: UIAlertAction) in
            let nameField = alert.textFields![0] as UITextField
            self.insertNewChild(name: nameField.text!, parent: self.myParent!)////!
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
        
        // Save the context.////infunc
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
        //        if let vc = segue.destination as? Master2ViewController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
        //            vc.myParent = fetchedResultsController.object(at: indexPath) as? Parent
        //        }
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections: \(self.fetchedResultsController.sections?.count ?? 1)")
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("numberOfRows: \(sectionInfo.numberOfObjects) inSection: \(section)")
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let child = self.fetchedResultsController.object(at: indexPath) as! Child
            self.configureCell(cell, withChild: child)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withChild child: Child) {
        cell.textLabel!.text = child.name
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("titleForHeader: \(fetchedResultsController.sections![section].name), in section:\(section)")
        return fetchedResultsController.sections![section].name
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
        //        fetchRequest.predicate = NSPredicate(format: "parent.id == %@", myParent.id!)
        let id = myParent.id!
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "self.parent.id", myParent.id!)
        ////id not optional
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
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
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, withParent: anObject as! Parent)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */
    
}

