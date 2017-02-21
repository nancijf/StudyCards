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
    func categoryTableViewControllerDidFinishSelectingCategory(_ viewController: CategoryTableViewController, selectedCategories: NSMutableOrderedSet?)
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
        actionBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(addTapped))
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        self.navigationItem.rightBarButtonItem = actionBarButton
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped(_ sender: UIBarButtonItem) {
        if didMakeChanges {
            let alert = UIAlertController(title: "Caution", message: "Changes were made to your selected categories. Do you want to save them?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action) -> Void in
                self.navigationController?.popViewController(animated: true)
            }
            let saveAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                self.delegate?.categoryTableViewControllerDidFinishSelectingCategory(self, selectedCategories: self.selectedCategories)
                self.navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func addTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.modalPresentationStyle = .popover
        alert.popoverPresentationController?.barButtonItem = sender
        
        let addCategory = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action) -> Void in
            self.addNewCategory()
        }
        let editDeleteCategory = UIAlertAction(title: "Edit/Delete", style: UIAlertActionStyle.default) { (action) -> Void in
            self.setEditing(true, animated: true)
        }
        let saveCategory = UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { (action) -> Void in
            self.delegate?.categoryTableViewControllerDidFinishSelectingCategory(self, selectedCategories: self.selectedCategories)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        alert.addAction(addCategory)
        alert.addAction(editDeleteCategory)
        alert.addAction(saveCategory)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = self.doneBarButton
        }
        else {
            navigationItem.rightBarButtonItem = self.actionBarButton
        }
    }
    
    func editTapped(_ sender: UIBarButtonItem) {
        self.setEditing(false, animated: true)
    }
    
    func addNewCategory() {
        var inputTextField: UITextField?
        
        let alertController = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        let addCat = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            if let tempTextHolder = inputTextField?.text, tempTextHolder.characters.count > 0 {
                let newCategory = CategoryStruct(name: tempTextHolder, decks: nil)
                if let addedCategory = StudyCardsDataStack.sharedInstance.addOrEditCategoryObject(newCategory) {
                    self.selectedCategories?.add(addedCategory)
                    self.tableView.reloadData()
                }
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        
        alertController.addAction(addCat)
        alertController.addAction(cancel)
        
        alertController.addTextField { (textField) -> Void in
            inputTextField = textField
        } 
        
        DispatchQueue.main.async { 
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func editCategory(_ selectedCategory: Category) {
        var inputTextField: UITextField?
        
        let editAlertController = UIAlertController(title: "Edit Category", message: nil, preferredStyle: .alert)
        let editCat = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            if let tempTextHolder = inputTextField?.text, tempTextHolder.characters.count > 0 {
                var categoryStruct = selectedCategory.asStruct()
                categoryStruct.name = tempTextHolder
                StudyCardsDataStack.sharedInstance.addOrEditCategoryObject(categoryStruct, categoryObj: selectedCategory)
                self.tableView.reloadData()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        
        editAlertController.addAction(editCat)
        editAlertController.addAction(cancel)
        
        editAlertController.addTextField { (textField) -> Void in
            textField.text = selectedCategory.name
            inputTextField = textField
        }
        
        DispatchQueue.main.async { 
            self.present(editAlertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCategoryCellIdentifier, for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let categoryModel = self.fetchedResultsController.object(at: indexPath) as? Category

        if selectedCategories?.contains(categoryModel!) == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = categoryModel?.name
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let selectedCategory = self.fetchedResultsController.object(at: indexPath) as! Category
        if tableView.isEditing {
            editCategory(selectedCategory)
        } else {
            self.didMakeChanges = true
            if cell?.accessoryType == .checkmark {
                cell?.accessoryType = .none
                selectedCategories?.remove(selectedCategory)
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                selectedCategories?.add(selectedCategory)
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
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
                self.tableView(self.tableView, didSelectRowAt: newIndexPath!)
            case .delete:
                self.selectedCategories?.remove(anObject)
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }



}
