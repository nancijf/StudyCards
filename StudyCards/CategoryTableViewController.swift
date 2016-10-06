//
//  CategoryTableViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/27/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol CategoryTableViewControllerDelegate: class {
    func categoryTableViewControllerDidFinishSelectingCategory(viewController: CategoryTableViewController, selectedCategories: NSMutableOrderedSet?)
}

let kCategoryCellIdentifier = "categoryCell"

class CategoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var selectedCategories: NSMutableOrderedSet?
    weak var delegate: CategoryTableViewControllerDelegate?
    var actionBarButton: UIBarButtonItem?
    var doneBarButton: UIBarButtonItem?
    var didMakeChanges: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.selectedCategories == nil {
            self.selectedCategories = NSMutableOrderedSet()
        }
        
        self.fetchedResultsController.delegate = self
        actionBarButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(addTapped))
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(editTapped))
        self.navigationItem.rightBarButtonItem = actionBarButton
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(title: "< Back", style: .Plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationController?.interactivePopGestureRecognizer!.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped(sender: UIBarButtonItem) {
        if didMakeChanges {
            let alert = UIAlertController(title: "Caution", message: "Changes were made to your selected categories. Do you want to save them?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            }
            let saveAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                self.delegate?.categoryTableViewControllerDidFinishSelectingCategory(self, selectedCategories: self.selectedCategories)
                self.navigationController?.popViewControllerAnimated(true)
            })
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    func addTapped(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.modalPresentationStyle = .Popover
        alert.popoverPresentationController?.barButtonItem = sender
        
        let addCategory = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.addNewCategory()
        }
        let editDeleteCategory = UIAlertAction(title: "Edit/Delete", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.setEditing(true, animated: true)
        }
        let saveCategory = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.delegate?.categoryTableViewControllerDidFinishSelectingCategory(self, selectedCategories: self.selectedCategories)
            self.navigationController?.popViewControllerAnimated(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        alert.addAction(addCategory)
        alert.addAction(editDeleteCategory)
        alert.addAction(saveCategory)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = self.doneBarButton
        }
        else {
            navigationItem.rightBarButtonItem = self.actionBarButton
        }
    }
    
    func editTapped(sender: UIBarButtonItem) {
        self.setEditing(false, animated: true)
    }
    
    func addNewCategory() {
        var inputTextField: UITextField?
        
        let alertController = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .Alert)
        let addCat = UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            if let tempTextHolder = inputTextField?.text where tempTextHolder.characters.count > 0 {
                let newCategory = CategoryStruct(name: tempTextHolder, decks: nil)
                if let addedCategory = StudyCardsDataStack.sharedInstance.addOrEditCategoryObject(newCategory) {
                    self.selectedCategories?.addObject(addedCategory)
                    self.tableView.reloadData()
                }
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
        
        alertController.addAction(addCat)
        alertController.addAction(cancel)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            inputTextField = textField
        } 
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func editCategory(selectedCategory: Category) {
        var inputTextField: UITextField?
        
        let editAlertController = UIAlertController(title: "Edit Category", message: nil, preferredStyle: .Alert)
        let editCat = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            if let tempTextHolder = inputTextField?.text where tempTextHolder.characters.count > 0 {
                var categoryStruct = selectedCategory.asStruct()
                categoryStruct.name = tempTextHolder
                StudyCardsDataStack.sharedInstance.addOrEditCategoryObject(categoryStruct, categoryObj: selectedCategory)
                self.tableView.reloadData()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
        
        editAlertController.addAction(editCat)
        editAlertController.addAction(cancel)
        
        editAlertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.text = selectedCategory.name
            inputTextField = textField
        }
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.presentViewController(editAlertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCategoryCellIdentifier, forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let categoryModel = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Category

        if selectedCategories?.containsObject(categoryModel!) == true {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        cell.textLabel?.text = categoryModel?.name
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let selectedCategory = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Category
        if tableView.editing {
            editCategory(selectedCategory)
        } else {
            self.didMakeChanges = true
            if cell?.accessoryType == .Checkmark {
                cell?.accessoryType = .None
                selectedCategories?.removeObject(selectedCategory)
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                selectedCategories?.addObject(selectedCategory)
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        guard let frc = StudyCardsDataStack.sharedInstance.fetchedResultsController("Category", sortDescriptors: sortDescriptors, predicate: nil) else {
            abort()
        }
        
        do {
            try frc.performFetch()
        } catch {
            abort()
        }
        
        return frc
    }()

    // MARK: - NSFetchedResultsControllerDelegate calls
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                self.tableView(self.tableView, didSelectRowAtIndexPath: newIndexPath!)
            case .Delete:
                self.selectedCategories?.removeObject(anObject)
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }



}
