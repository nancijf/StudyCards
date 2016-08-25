//
//  MasterViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    var detailViewController: CardPageViewController? = nil
    var quizletController = QuizletController()
    let searchController = UISearchController(searchResultsController: nil)
    var searchPredicate: NSPredicate?
    
    @IBOutlet weak var quizletButton: UIBarButtonItem!
    
    @IBAction func runQuizlet(sender: UIBarButtonItem) {
//        quizletController.searchQuizlet("cities")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchedResultsController.delegate = self
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Category"]
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame))
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CardPageViewController
        }
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            getJSONData("US_Presidents")
            getJSONData("US_Capitol_Cities")
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItem?.enabled = !editing
        self.quizletButton.enabled = !editing
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        if let searchText = searchController.searchBar.text where searchText.characters.count > 1 {
            if scope == "Category" {
                searchPredicate = NSPredicate(format: "SUBQUERY(categories, $category, $category.name contains[c] %@).@count > 0", searchText)
            } else {
                searchPredicate = NSPredicate(format: "title contains[c] %@", searchText)
            }
            self.fetchedResultsController.fetchRequest.predicate = searchPredicate
            
            do {
                try self.fetchedResultsController.performFetch()
                tableView.reloadData()
            } catch {
                abort()
            }
        }
    }

    func didDismissSearchController(searchController: UISearchController) {
        self.fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try self.fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            abort()
        }

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
                                        let categoryToAdd = CategoryStruct(name: category, decks: nil)
                                        if let categoryObject = StudyCardsDataStack.sharedInstance.addOrEditCategoryObject(categoryToAdd) {
                                            newCategories.addObject(categoryObject)                                        
                                        }
                                        continue
                                    }
                                    newCategories.addObject(categoryObject)
                                }
                            }
                            let newDeck = DeckStruct(title: deckTitle, desc: nil, testscore: 0.0, correctanswers: 0, categories: newCategories, cards: nil)
                            if let deckObj = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck) {
                                if let cards = dictionary["deck"]?["cards"] as? [[String: AnyObject]] {
                                    for card: [String: AnyObject] in cards {
                                        if let question = card["card"]?["question"] as? String, let answer = card["card"]?["answer"] as? String {
                                            let newCard = CardStruct(question: question, answer: answer, hidden: false, iscorrect: false, wronganswers: 0, ordinal: 0, imageURL: nil, deck: deckObj)
                                            StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
                                        }
                                    }
                                }
                                if let categories = deckObj.categories {
                                    for category in categories {
                                        if let category = category as? Category {
                                            let tempDecks = category.decks?.mutableCopy() ?? NSMutableOrderedSet()
                                            tempDecks.addObject(deckObj)
                                            category.decks = tempDecks as? NSOrderedSet
                                        }
                                    }
                                    StudyCardsDataStack.sharedInstance.saveContext()                                    
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
                if controller.deck?.cards?.count == 0 {
                    let alert = UIAlertController(title: "Alert", message: "There are no cards in this deck to display.", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(okAction)
                    presentViewController(alert, animated: true, completion: nil)
                } else {
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        } else if segue.identifier == "AddNewDeck" {
            let controller = segue.destinationViewController as! AddDeckViewController
            controller.mode = .AddDeck
        } else if segue.identifier == "EditDeck" {
            let controller = segue.destinationViewController as! AddDeckViewController
            controller.mode = .EditDeck
            controller.deck = sender as? Deck
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
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

}


