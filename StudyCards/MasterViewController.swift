//
//  MasterViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISplitViewControllerDelegate {

    var detailViewController: CardPageViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var searchPredicate: NSPredicate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.fetchedResultsController.delegate = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0; // set to whatever your "average" cell height is
        
        splitViewController?.preferredDisplayMode = .allVisible
        self.tabBarController?.navigationItem.leftBarButtonItem = self.editButtonItem
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDeck))
        
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if !tableView.isEditing && self.splitViewController?.viewControllers.count > 1 {
            let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CardPageViewController") as? CardPageViewController
            let navController = UINavigationController(rootViewController: detailViewController!)
            self.showDetailViewController(navController, sender: self)
        }
        self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = !editing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed

        self.tabBarController?.navigationItem.leftBarButtonItem = self.editButtonItem
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDeck))
        UITabBar.appearance().barTintColor = UIColor ( red: 0.7843, green: 0.7843, blue: 0.7843, alpha: 1.0 )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.isActive = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addDeck(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "AddNewDeck", sender: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        if let searchText = searchController.searchBar.text, searchText.characters.count > 1 {
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
    
    func didPresentSearchController(_ searchController: UISearchController) {
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(88, 0, tabBarHeight, 0)
        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
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
        self.tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
    }

    func getJSONData(_ file: String) {
        if let filePath = Bundle.main.path(forResource: file, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    let jsonString = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
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
                                            newCategories.add(categoryObject)                                        
                                        }
                                        continue
                                    }
                                    newCategories.add(categoryObject)
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
                                            (tempDecks as AnyObject).add(deckObj)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCardList" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let deck = self.fetchedResultsController.object(at: indexPath) as? Deck
                
                if deck?.cards?.count == 0 {
                    let alert = UIAlertController(title: "Alert", message: "There are no cards in this deck to display.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: { () -> Void in
                        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    })
                } else {
                    let navController = segue.destination as! UINavigationController
                    let controller = navController.topViewController as! CardListTableViewController
                    controller.deck = deck
                }
            }
        } else if segue.identifier == "AddNewDeck" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! AddDeckViewController
            controller.mode = .addDeck
        } else if segue.identifier == "EditDeck" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! AddDeckViewController
            controller.mode = .editDeck
            controller.deck = sender as? Deck
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "ShowCardList" {
            if tableView.isEditing {
                return false
            }
        }
        return true
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
            return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let sectionInfo = self.fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
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
               abort()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deck = self.fetchedResultsController.object(at: indexPath) as? Deck
        if tableView.isEditing {
            self.performSegue(withIdentifier: "EditDeck", sender: deck)
        }
    }

    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let deck = self.fetchedResultsController.object(at: indexPath) as? Deck
        if let currentTitle = deck?.title, let cardCount: NSString = NSString(format: "%d", (deck?.cards?.count)!) {
            cell.textLabel?.text = currentTitle + " (\(cardCount) Cards)"
            cell.detailTextLabel?.text = deck?.desc
        } 
    }
        
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
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
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

}


