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

class AddDeckViewController: UITableViewController, CategoryTableViewControllerDelegate, AddCardsViewControllerDelegate {
    
    var tempCategories: NSOrderedSet?
    var deck: Deck?
    var mode: DeckViewControllerMode?
    
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
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveData))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveData() {
        let titleCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: TableViewSections.Title.rawValue)) as! DeckEditorTableViewCell

        let title = titleCell.titleTextField.text
        let descriptionCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: TableViewSections.Description.rawValue)) as! DeckEditorTableViewCell
        let description = descriptionCell.descTextView.text
        
        if mode == .AddDeck {
            let newDeck = DeckStruct(title: title, desc: description, testscore: 0.0, correctanswers: 0, categories: tempCategories, cards: nil)
            let deckObj = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck)
            if let categories = tempCategories, deckObj = deckObj {
                updateCategories(categories, deck: deckObj)
            }
        } else if mode == .EditDeck {
            if var updateDeck = self.deck?.asStruct() {
                updateDeck.title = title
                updateDeck.desc = description
                updateDeck.categories = tempCategories
                let deckObj = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(updateDeck, deckObj: self.deck)
                if let categories = tempCategories, deckObj = deckObj {
                    updateCategories(categories, deck: deckObj)
                }
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
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
                cell.titleTextField.text = self.deck?.title ?? ""
            case TableViewSections.Description.rawValue:
                cell.titleTextField.hidden = true
                cell.descTextView.text = self.deck?.desc ?? ""
            case TableViewSections.Category.rawValue:
                cell.descTextView.hidden = true
                cell.titleTextField.enabled = false
                if let category = tempCategories![indexPath.item] as? Category {
                    cell.titleTextField.text = category.name
                }
            case TableViewSections.Cards.rawValue:
                cell.descTextView.hidden = true
                cell.titleTextField.enabled = false
                if deck?.cards?.count > 0 {
                    if let card = deck?.cards?[indexPath.item] as? Card {
                        cell.titleTextField.text = card.question
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
                return 40.0
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
                    if mode == .EditDeck {
                        let existingCategories = deck?.categories
                        categoryViewController.selectedCategories = existingCategories?.mutableCopy() as? NSMutableOrderedSet
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
    
    // MARK: - CategoryTableViewControllerDelegate
    
    func categoryTableViewControllerDidFinishSelectingCategory(viewController: CategoryTableViewController, selectedCategories: NSMutableOrderedSet?) {
        tempCategories = selectedCategories
        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
    }
    
    func addCardsViewControllerDidFinishAddingCards(viewController: AddCardsViewController, addedCards: NSMutableOrderedSet?) {
        tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .None)
    }

}
