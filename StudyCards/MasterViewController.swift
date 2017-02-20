//
//  MasterViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISplitViewControllerDelegate {

    var detailViewController: CardPageViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var searchPredicate: NSPredicate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        self.fetchedResultsController.delegate = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0; // set to whatever your "average" cell height is
        
        splitViewController?.preferredDisplayMode = .AllVisible
        self.tabBarController?.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addDeck))
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Category"]
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            getJSONData("US_Presidents")
            getJSONData("US_Capitol_Cities")
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if !tableView.editing && self.splitViewController?.viewControllers.count > 1 {
            let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
            let navController = UINavigationController(rootViewController: detailViewController!)
            self.showDetailViewController(navController, sender: self)
        }
        self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = !editing
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed

        self.tabBarController?.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addDeck))
        UITabBar.appearance().barTintColor = UIColor ( red: 0.7843, green: 0.7843, blue: 0.7843, alpha: 1.0 )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame))
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        searchController.active = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addDeck(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("AddNewDeck", sender: nil)
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
    
    func didPresentSearchController(searchController: UISearchController) {
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(88, 0, tabBarHeight, 0)
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
        
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame))
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
                                            let newCard = CardStruct(question: question, answer: answer, hidden: false, cardviewed: false, iscorrect: false, wronganswers: 0, ordinal: 0, imageURL: nil, deck: deckObj)
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
        if segue.identifier == "ShowCardList" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let deck = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Deck
                
                if deck?.cards?.count == 0 {
                    let alert = UIAlertController(title: "Alert", message: "There are no cards in this deck to display.", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(okAction)
                    presentViewController(alert, animated: true, completion: { () -> Void in
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                } else {
                    let navController = segue.destinationViewController as! UINavigationController
                    let controller = navController.topViewController as! CardListTableViewController
                    controller.deck = deck
                }
            }
        } else if segue.identifier == "AddNewDeck" {
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.topViewController as! AddDeckViewController
            controller.mode = .AddDeck
        } else if segue.identifier == "EditDeck" {
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.topViewController as! AddDeckViewController
            controller.mode = .EditDeck
            controller.deck = sender as? Deck
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "ShowCardList" {
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
        if let currentTitle = deck?.title, let cardCount: NSString = NSString(format: "%d", (deck?.cards?.count)!) {
            cell.textLabel?.text = currentTitle + " (\(cardCount) Cards)"
            cell.detailTextLabel?.text = deck?.desc
        } 
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


