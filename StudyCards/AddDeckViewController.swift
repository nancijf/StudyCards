//
//  AddDeckViewController.swift
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



let kCellIdentifier = "DeckEditorCell"

enum DeckViewControllerMode: Int {
    case addDeck
    case editDeck
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
        case title = 0
        case description
        case category
        case cards
    }
    
    enum AddButtonType: Int {
        case category = 0
        case card
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == .addDeck {
            self.navigationItem.title = "Add Deck"
        } else {
            self.navigationItem.title = "Edit Deck"
        }

        tempCategories = deck?.categories
        tempDesc = deck?.desc
        tempTitle = deck?.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveData))
        navigationItem.rightBarButtonItem = saveButton
        if let splitView = self.splitViewController {
            if splitView.isCollapsed {
                navigationItem.setHidesBackButton(true, animated: true)
                let backButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonPressed))
                navigationItem.leftBarButtonItem = backButton
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tempTitle = textField.text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        didMakeChanges = true
        tempTitle = textField.text
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        didMakeChanges = true
        tempDesc = textView.text
    }
    
    func saveData() {
        self.view.endEditing(true)
        if mode == .addDeck {
            let newDeck = DeckStruct(title: tempTitle, desc: tempDesc, testscore: 0.0, correctanswers: 0, categories: tempCategories, cards: nil)
            let deckObj = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck)
            if let categories = tempCategories, let deckObj = deckObj {
                updateCategories(categories, deck: deckObj)
            }
        } else if mode == .editDeck {
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
            let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CardPageViewController") as? CardPageViewController
            let navController = UINavigationController(rootViewController: detailViewController!)
            self.showDetailViewController(navController, sender: self)
        }
        self.navigationController?.navigationController?.popViewController(animated: true)
    }
    
    func backButtonPressed(_ sender: UIBarButtonItem) {
        let titleCell = self.tableView.cellForRow(at: IndexPath(item: 0, section: TableViewSections.title.rawValue)) as? DeckEditorTableViewCell
        let title = titleCell?.titleTextField.text
        let descriptionCell = self.tableView.cellForRow(at: IndexPath(item: 0, section: TableViewSections.description.rawValue)) as? DeckEditorTableViewCell
        let desc = descriptionCell?.descTextView.text
        
        didMakeChanges = didMakeChanges || (title != (deck?.title ?? "") || desc != (deck?.desc ?? ""))

        if didMakeChanges {
            let alert = UIAlertController(title: "Caution", message: "Do you want to save your changes?", preferredStyle: UIAlertControllerStyle.alert)
            let saveAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                self.saveData()
            })
            let cancelAction = UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
                if self.splitViewController?.viewControllers.count > 1 {
                    let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CardPageViewController") as? CardPageViewController
                    let navController = UINavigationController(rootViewController: detailViewController!)
                    self.showDetailViewController(navController, sender: self)
                }
                self.navigationController?.navigationController?.popViewController(animated: true)

            })
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            if self.splitViewController?.viewControllers.count > 1 {
                let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CardPageViewController") as? CardPageViewController
                let navController = UINavigationController(rootViewController: detailViewController!)
                self.showDetailViewController(navController, sender: self)
            }
            self.navigationController?.navigationController?.popViewController(animated: true)
            
        }
    }
    
    func updateCategories(_ categories: NSOrderedSet, deck: Deck) {
        for category in categories {
            if let category = category as? Category {
                let tempDecks = category.decks?.mutableCopy() ?? NSMutableOrderedSet()
                (tempDecks as AnyObject).add(deck)
                category.decks = tempDecks as? NSOrderedSet
            }
        }
        StudyCardsDataStack.sharedInstance.saveContext()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case TableViewSections.title.rawValue:
                return 1
            case TableViewSections.description.rawValue:
                return 1
            case TableViewSections.category.rawValue:
                guard let categoryCount = tempCategories?.count else {
                    return 0
                }
                return categoryCount
            case TableViewSections.cards.rawValue:
                guard let cardCount = deck?.cards?.count else {
                    return 0
                }
                return cardCount
            default:
                return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! DeckEditorTableViewCell

        switch indexPath.section {
            case TableViewSections.title.rawValue:
                cell.descTextView.isHidden = true
                cell.cardImageView.isHidden = true
                cell.titleTextField.text = tempTitle ?? ""
            case TableViewSections.description.rawValue:
                cell.titleTextField.isHidden = true
                cell.cardImageView.isHidden = true
                cell.descTextView.text = tempDesc ?? ""
            case TableViewSections.category.rawValue:
                cell.descTextView.isHidden = true
                cell.cardImageView.isHidden = true
                cell.titleTextField.isEnabled = false
                if let category = tempCategories![indexPath.item] as? Category {
                    cell.titleTextField.text = category.name
                }
            case TableViewSections.cards.rawValue:
                cell.descTextView.isHidden = true
                cell.titleTextField.isEnabled = false
                if deck?.cards?.count > 0 {
                    if let card = deck?.cards?[indexPath.item] as? Card {
                        if card.imageURL != nil {
                            let imageURL = card.imageURL
                            if let urlString = imageURL?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)?.createFilePath(), let url = URL(string: urlString) {
                                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
                                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                        DispatchQueue.main.async(execute: {
                                            cell.cardImageView.image = image
                                        })
                                    }
                                })
                            }
                        } else {
                            cell.cardImageView.isHidden = true
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if mode == .addDeck && section == TableViewSections.cards.rawValue {
            return 0
        } else {
            return 44.0
        }
    }
     
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
            case TableViewSections.title.rawValue:
                return 44.0
            case TableViewSections.description.rawValue:
                return 88.0
            case TableViewSections.category.rawValue:
                return 40.0
            case TableViewSections.cards.rawValue:
                let card = deck?.cards?[indexPath.row] as? Card
                return card?.imageURL != nil ? 100.0 : 44.0
            default:
                return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView: UIView = UIView(frame: CGRect.zero) {
            headerView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            
            let titleLabel = UILabel(frame: CGRect.zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFont(ofSize: 17.0)
            titleLabel.textColor = UIColor.darkGray
            titleLabel.textAlignment = .left
            
            let rightAccessoryView = UIButton(type: .contactAdd)
            rightAccessoryView.translatesAutoresizingMaskIntoConstraints = false
            rightAccessoryView.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
            
            switch section {
                case TableViewSections.title.rawValue:
                    titleLabel.text = "Title"
                    rightAccessoryView.isHidden = true
                case TableViewSections.description.rawValue:
                    titleLabel.text = "Description"
                    rightAccessoryView.isHidden = true
                case TableViewSections.category.rawValue:
                    titleLabel.text = "Category"
                    rightAccessoryView.isHidden = false
                    rightAccessoryView.tag = AddButtonType.category.rawValue
                case TableViewSections.cards.rawValue:
                    if mode == .editDeck {
                        titleLabel.text = "Cards"
                        rightAccessoryView.isHidden = false
                        rightAccessoryView.tag = AddButtonType.card.rawValue
                    } else {
                        titleLabel.isHidden = true
                        rightAccessoryView.isHidden = true
                    }
                default:
                    titleLabel.text = ""
                    rightAccessoryView.isHidden = true
            }
            
            headerView.addSubview(titleLabel)
            headerView.addSubview(rightAccessoryView)
            titleLabel.sizeToFit()
            
            let bottomBorder = UIView(frame: CGRect.zero)
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            bottomBorder.backgroundColor = UIColor.lightGray
            headerView.addSubview(bottomBorder)
            
            let views = ["titleLabel": titleLabel, "rightAccessoryView": rightAccessoryView, "bottomBorder": bottomBorder]
            let metrics = ["leftRightInset": 10, "spacer": 5, "accessoryWidth": 30, "borderHeight": 1]
            
            // add constraints for title and bottom border
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftRightInset-[titleLabel]-spacer-[rightAccessoryView(accessoryWidth)]-leftRightInset-|", options: [], metrics: metrics, views: views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomBorder]|", options: [], metrics: metrics, views: views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomBorder(borderHeight)]|", options: [], metrics: metrics, views: views))
            
            // center vertically on Y axis
            headerView.addConstraint(NSLayoutConstraint(item: rightAccessoryView, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1.0, constant: 0))
            headerView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1.0, constant: 0))
            
            return headerView
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == TableViewSections.cards.rawValue {
            let card = self.deck?.cards?.object(at: indexPath.row) as? Card
            if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let addCardsViewController = storyboard?.instantiateViewController(withIdentifier: "AddCards") as? AddCardsViewController {
                addCardsViewController.deck = deck
                addCardsViewController.card = card
                addCardsViewController.mode = .editCard
                addCardsViewController.delegate = self
                self.navigationController?.pushViewController(addCardsViewController, animated: true)
            }
        }
    }
    
    func tappedAddButton(_ sender: UIBarButtonItem) {
        switch sender.tag {
            case AddButtonType.category.rawValue:
                if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let categoryViewController = storyboard?.instantiateViewController(withIdentifier: "Category") as? CategoryTableViewController {
                    if let existingCategories = tempCategories {
                        categoryViewController.selectedCategories = existingCategories.mutableCopy() as? NSMutableOrderedSet
                    }

                    categoryViewController.delegate = self
                    self.navigationController?.pushViewController(categoryViewController, animated: true)
                }
            case AddButtonType.card.rawValue:
                if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let addCardsViewController = storyboard?.instantiateViewController(withIdentifier: "AddCards") as? AddCardsViewController {
                    addCardsViewController.deck = deck as Deck?
                    addCardsViewController.mode = .addCard
                    addCardsViewController.delegate = self
                    self.navigationController?.pushViewController(addCardsViewController, animated: true)
                }
            default:
                return
            
        }
    }
    
    // MARK: - CategoryTableViewControllerDelegate, AddCardsViewControllerDelegate
    
    func categoryTableViewControllerDidFinishSelectingCategory(_ viewController: CategoryTableViewController, selectedCategories: NSMutableOrderedSet?) {
        if tempCategories != selectedCategories {
            tempCategories = selectedCategories
            didMakeChanges = true
        }
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
    
    func addCardsViewControllerDidFinishAddingCards(_ viewController: AddCardsViewController, addedCards: NSMutableOrderedSet?) {
        didMakeChanges = true
        tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }

}
