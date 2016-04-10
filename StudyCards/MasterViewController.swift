//
//  MasterViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: CardPageViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchedResultsController.delegate = self
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CardPageViewController
        }
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            getJSONData("US_Presidents")
            getJSONData("US_Capitol_Cities")
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem?.enabled = !editing
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getJSONData(file: String) {
        if let filePath = NSBundle.mainBundle().pathForResource(file, ofType: "json") {
            do {
                let data = try NSData(contentsOfFile: filePath, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonString = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    if let dictionary = jsonString as? [String: AnyObject] {
                        if let deckTitle = dictionary["deck"]?["title"] as? String {
                            let newCategories = NSMutableOrderedSet()
                            if let categories = dictionary["deck"]?["categories"] as? [String] {
                                for category in categories {
                                    let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "name", ascending: true)]
                                    let resultsController = StudyCardsDataStack.sharedInstance.fetchedResultsController("Category", sortDescriptors: sortDescriptors, predicate: NSPredicate(format: "name == %@", category))
                                    
                                    guard let categoryObject = resultsController?.fetchedObjects?.first as? Category else {
                                        let categoryToAdd = CategoryStruct(name: category)
                                        if let categoryObject = StudyCardsDataStack.sharedInstance.addOrEditCategoryObject(categoryToAdd) {
                                            newCategories.addObject(categoryObject)                                        
                                        }
                                        continue
                                    }
                                    newCategories.addObject(categoryObject)
                                }
                                print("Categories: \(newCategories)")
                            }
                            let newDeck = DeckStruct(title: deckTitle, desc: nil, testscore: 0.0, categories: newCategories, cards: nil)
                            if let deckObj = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck) {
                                if let cards = dictionary["deck"]?["cards"] as? [[String: AnyObject]] {
                                    var cardNum: Int32 = 1
                                    for card: [String: AnyObject] in cards {
                                        if let question = card["card"]?["question"] as? String, let answer = card["card"]?["answer"] as? String {
//                                            print ("\(question)\n")
//                                            print("\(answer)\n")
                                            let newCard = CardStruct(question: question, answer: answer, hidden: false, correctanswers: 0, wronganswers: 0, ordinal: cardNum, images: nil, deck: deckObj)
                                            StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
                                            cardNum += 1
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename or path")
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDeck" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let deck = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CardPageViewController
                controller.deck = deck as? Deck
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        else if segue.identifier == "AddNewDeck" {
            let controller = segue.destinationViewController as! AddDeckViewController
            controller.mode = .AddDeck
        }
        else if segue.identifier == "EditDeck" {
            let controller = segue.destinationViewController as! AddDeckViewController
            controller.mode = .EditDeck
            controller.deck = sender as? Deck
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
    {
        if identifier == "ShowDeck" {
            if tableView.editing {
                return false
            }
        }
        return true
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
        let deck = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Deck
        if tableView.editing {
            self.performSegueWithIdentifier("EditDeck", sender: deck)
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let deck = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Deck
        cell.textLabel!.text = deck?.title
        if let cardCount: NSString = NSString(format: "%d", (deck?.cards?.count)!) {
            cell.textLabel?.text = (cell.textLabel?.text)! + " (\(cardCount) Cards)"
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("CardListTableViewController") as? CardListTableViewController
        controller?.deck = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Deck
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "title", ascending: true)]
        guard let frc = StudyCardsDataStack.sharedInstance.fetchedResultsController("Deck", sortDescriptors: sortDescriptors, predicate: nil) else {
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
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
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

