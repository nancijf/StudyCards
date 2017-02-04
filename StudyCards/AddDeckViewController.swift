//
//  AddDeckViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData


let kCellIdentifier = "DeckEditorCell"

enum DeckViewControllerMode: Int {
    case AddDeck
    case EditDeck
}

class AddDeckViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate, CategoryTableViewControllerDelegate, AddCardsViewControllerDelegate, UISplitViewControllerDelegate {
    
    var tempCategories: NSOrderedSet?
    var deck: Deck?
    var mode: DeckViewControllerMode?
    var tempTitle: String?
    var tempDesc: String?
    var didMakeChanges: Bool = false
    var deckEditorCell: DeckEditorTableViewCell?
    var detailViewController: CardPageViewController? = nil
    
    
    enum TableViewSections: Int {
        case Title = 0
        case Description
        case Category
        case Cards
    }
    
    enum AddButtonType: Int {
        case Category = 0
        case Card
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mode == .AddDeck {
            self.navigationItem.title = "Add Deck"
        } else {
            self.navigationItem.title = "Edit Deck"
        }

        tempCategories = deck?.categories
        tempDesc = deck?.desc
        tempTitle = deck?.title
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveData))
        let backButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonPressed))
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    func primaryViewControllerForCollapsingSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
//        print("collapsing controllers")
//        let controllers = splitViewController.viewControllers
//        self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CardPageViewController
//        
//        let navController = UINavigationController(rootViewController: detailViewController!)
//        return navController
//    }
//    
//    func primaryViewControllerForExpandingSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
//        print("expanding controllers")
//        let controllers = splitViewController.viewControllers
//        let navController = controllers.first as! UINavigationController
//        if splitViewController.viewControllers.count == 1 {
//            if let _ = deck?.cards?.count, card = self.deck?.cards?.objectAtIndex(0) as? Card {
//                if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let addCardsViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCards") as? AddCardsViewController {
//                    addCardsViewController.deck = deck
//                    addCardsViewController.card = card
//                    addCardsViewController.mode = .EditCard
//                    addCardsViewController.delegate = self
//                    addCardsViewController.navigationItem.title = "Edit Card"
//                    navController.pushViewController(addCardsViewController, animated: false)
//                }
//            }
//        }
//        return navController
//    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tempTitle = textField.text
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        didMakeChanges = true
        tempTitle = textField.text
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        didMakeChanges = true
        tempDesc = textView.text
    }
    
    func saveData() {
        self.view.endEditing(true)
        if mode == .AddDeck {
            let newDeck = DeckStruct(title: tempTitle, desc: tempDesc, testscore: 0.0, correctanswers: 0, categories: tempCategories, cards: nil)
            let deckObj = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck)
            if let categories = tempCategories, let deckObj = deckObj {
                updateCategories(categories, deck: deckObj)
            }
        } else if mode == .EditDeck {
            if var updateDeck = self.deck?.asStruct() {
                updateDeck.title = tempTitle
                updateDeck.desc = tempDesc
                updateDeck.categories = tempCategories
                let deckObj = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(updateDeck, deckObj: self.deck)
                if let categories = tempCategories, let deckObj = deckObj {
                    updateCategories(categories, deck: deckObj)
                }
            }
        }
        if self.splitViewController?.viewControllers.count > 1 {
            let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
            let navController = UINavigationController(rootViewController: detailViewController!)
            self.showDetailViewController(navController, sender: self)
        }
        self.navigationController?.navigationController?.popViewControllerAnimated(true)
    }
    
    func backButtonPressed(sender: UIBarButtonItem) {
        let titleCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: TableViewSections.Title.rawValue)) as? DeckEditorTableViewCell
        let title = titleCell?.titleTextField.text
        let descriptionCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: TableViewSections.Description.rawValue)) as? DeckEditorTableViewCell
        let desc = descriptionCell?.descTextView.text
        
        didMakeChanges = didMakeChanges || (title != (deck?.title ?? "") || desc != (deck?.desc ?? ""))

        if didMakeChanges {
            let alert = UIAlertController(title: "Caution", message: "Do you want to save your changes?", preferredStyle: UIAlertControllerStyle.Alert)
            let saveAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                self.saveData()
            })
            let cancelAction = UIAlertAction(title: "No", style: .Default, handler: { (action) -> Void in
                if self.splitViewController?.viewControllers.count > 1 {
                    let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
                    let navController = UINavigationController(rootViewController: detailViewController!)
                    self.showDetailViewController(navController, sender: self)
                }
                self.navigationController?.navigationController?.popViewControllerAnimated(true)

            })
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            if self.splitViewController?.viewControllers.count > 1 {
                let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
                let navController = UINavigationController(rootViewController: detailViewController!)
                self.showDetailViewController(navController, sender: self)
            }
            self.navigationController?.navigationController?.popViewControllerAnimated(true)
            
        }
    }
    
    func updateCategories(categories: NSOrderedSet, deck: Deck) {
        for category in categories {
            if let category = category as? Category {
                let tempDecks = category.decks?.mutableCopy() ?? NSMutableOrderedSet()
                tempDecks.addObject(deck)
                category.decks = tempDecks as? NSOrderedSet
            }
        }
        StudyCardsDataStack.sharedInstance.saveContext()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case TableViewSections.Title.rawValue:
                return 1
            case TableViewSections.Description.rawValue:
                return 1
            case TableViewSections.Category.rawValue:
                guard let categoryCount = tempCategories?.count else {
                    return 0
                }
                return categoryCount
            case TableViewSections.Cards.rawValue:
                guard let cardCount = deck?.cards?.count else {
                    return 0
                }
                return cardCount
            default:
                return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! DeckEditorTableViewCell

        switch indexPath.section {
            case TableViewSections.Title.rawValue:
                cell.descTextView.hidden = true
                cell.cardImageView.hidden = true
                cell.titleTextField.text = tempTitle ?? ""
            case TableViewSections.Description.rawValue:
                cell.titleTextField.hidden = true
                cell.cardImageView.hidden = true
                cell.descTextView.text = tempDesc ?? ""
            case TableViewSections.Category.rawValue:
                cell.descTextView.hidden = true
                cell.cardImageView.hidden = true
                cell.titleTextField.enabled = false
                if let category = tempCategories![indexPath.item] as? Category {
                    cell.titleTextField.text = category.name
                }
            case TableViewSections.Cards.rawValue:
                cell.descTextView.hidden = true
                cell.titleTextField.enabled = false
                if deck?.cards?.count > 0 {
                    if let card = deck?.cards?[indexPath.item] as? Card {
                        if card.imageURL != nil {
                            let imageURL = card.imageURL
                            if let urlString = imageURL?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())?.createFilePath(), let url = NSURL(string: urlString) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                                    if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            cell.cardImageView.image = image
                                        })
                                    }
                                })
                            }
                        } else {
                            cell.cardImageView.hidden = true
                        }
                        let row = String(indexPath.row + 1)
                        if card.question == "" {
                            cell.titleTextField.text = "\(row). (No question)"
                        } else {
                            if let question = card.question {
                                cell.titleTextField.text = "\(row). \(question)"
                            }
                        }
                     }
                }
            default:
                break
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if mode == .AddDeck && section == TableViewSections.Cards.rawValue {
            return 0
        } else {
            return 44.0
        }
    }
     
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
            case TableViewSections.Title.rawValue:
                return 44.0
            case TableViewSections.Description.rawValue:
                return 88.0
            case TableViewSections.Category.rawValue:
                return 40.0
            case TableViewSections.Cards.rawValue:
                let card = deck?.cards?[indexPath.row] as? Card
                return card?.imageURL != nil ? 100.0 : 44.0
            default:
                return 44.0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView: UIView = UIView(frame: CGRectZero) {
            headerView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            
            let titleLabel = UILabel(frame: CGRectZero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFontOfSize(17.0)
            titleLabel.textColor = UIColor.darkGrayColor()
            titleLabel.textAlignment = .Left
            
            let rightAccessoryView = UIButton(type: .ContactAdd)
            rightAccessoryView.translatesAutoresizingMaskIntoConstraints = false
            rightAccessoryView.addTarget(self, action: #selector(tappedAddButton), forControlEvents: .TouchUpInside)
            
            switch section {
                case TableViewSections.Title.rawValue:
                    titleLabel.text = "Title"
                    rightAccessoryView.hidden = true
                case TableViewSections.Description.rawValue:
                    titleLabel.text = "Description"
                    rightAccessoryView.hidden = true
                case TableViewSections.Category.rawValue:
                    titleLabel.text = "Category"
                    rightAccessoryView.hidden = false
                    rightAccessoryView.tag = AddButtonType.Category.rawValue
                case TableViewSections.Cards.rawValue:
                    if mode == .EditDeck {
                        titleLabel.text = "Cards"
                        rightAccessoryView.hidden = false
                        rightAccessoryView.tag = AddButtonType.Card.rawValue
                    } else {
                        titleLabel.hidden = true
                        rightAccessoryView.hidden = true
                    }
                default:
                    titleLabel.text = ""
                    rightAccessoryView.hidden = true
            }
            
            headerView.addSubview(titleLabel)
            headerView.addSubview(rightAccessoryView)
            titleLabel.sizeToFit()
            
            let bottomBorder = UIView(frame: CGRectZero)
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            bottomBorder.backgroundColor = UIColor.lightGrayColor()
            headerView.addSubview(bottomBorder)
            
            let views = ["titleLabel": titleLabel, "rightAccessoryView": rightAccessoryView, "bottomBorder": bottomBorder]
            let metrics = ["leftRightInset": 10, "spacer": 5, "accessoryWidth": 30, "borderHeight": 1]
            
            // add constraints for title and bottom border
            headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-leftRightInset-[titleLabel]-spacer-[rightAccessoryView(accessoryWidth)]-leftRightInset-|", options: [], metrics: metrics, views: views))
            headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomBorder]|", options: [], metrics: metrics, views: views))
            headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomBorder(borderHeight)]|", options: [], metrics: metrics, views: views))
            
            // center vertically on Y axis
            headerView.addConstraint(NSLayoutConstraint(item: rightAccessoryView, attribute: .CenterY, relatedBy: .Equal, toItem: headerView, attribute: .CenterY, multiplier: 1.0, constant: 0))
            headerView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: headerView, attribute: .CenterY, multiplier: 1.0, constant: 0))
            
            return headerView
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == TableViewSections.Cards.rawValue {
            let card = self.deck?.cards?.objectAtIndex(indexPath.row) as? Card
            if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let addCardsViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCards") as? AddCardsViewController {
                addCardsViewController.deck = deck
                addCardsViewController.card = card
                addCardsViewController.mode = .EditCard
                addCardsViewController.delegate = self
                self.navigationController?.pushViewController(addCardsViewController, animated: true)
            }
        }
    }
    
    func tappedAddButton(sender: UIBarButtonItem) {
        switch sender.tag {
            case AddButtonType.Category.rawValue:
                if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let categoryViewController = storyboard?.instantiateViewControllerWithIdentifier("Category") as? CategoryTableViewController {
                    if let existingCategories = tempCategories {
                        categoryViewController.selectedCategories = existingCategories.mutableCopy() as? NSMutableOrderedSet
                    }

                    categoryViewController.delegate = self
                    self.navigationController?.pushViewController(categoryViewController, animated: true)
                }
            case AddButtonType.Card.rawValue:
                if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let addCardsViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCards") as? AddCardsViewController {
                    addCardsViewController.deck = deck as Deck?
                    addCardsViewController.mode = .AddCard
                    addCardsViewController.delegate = self
                    self.navigationController?.pushViewController(addCardsViewController, animated: true)
                }
            default:
                return
            
        }
    }
    
    // MARK: - CategoryTableViewControllerDelegate, AddCardsViewControllerDelegate
    
    func categoryTableViewControllerDidFinishSelectingCategory(viewController: CategoryTableViewController, selectedCategories: NSMutableOrderedSet?) {
        if tempCategories != selectedCategories {
            tempCategories = selectedCategories
            didMakeChanges = true
        }
        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
    }
    
    func addCardsViewControllerDidFinishAddingCards(viewController: AddCardsViewController, addedCards: NSMutableOrderedSet?) {
        didMakeChanges = true
        tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .None)
    }

}
