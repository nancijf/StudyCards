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

class AddDeckViewController: UITableViewController, CategoryTableViewControllerDelegate {
    
    var tempCategories: NSOrderedSet?
    var deck: Deck?
    var mode: DeckViewControllerMode?
    
    enum TableViewSections: Int {
        case Title = 0
        case Description
        case Category
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mode == .AddDeck {
            self.navigationItem.title = "Add Deck"
        } else {
            self.navigationItem.title = "Edit Deck"
        }
        
        tempCategories = deck?.categories
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveData")
        navigationItem.rightBarButtonItem = saveButton
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
            let newDeck = DeckStruct(title: title, desc: description, testscore: 0.0, categories: tempCategories, cards: nil)
            StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck)
        }
        else if mode == .EditDeck {
            if var updateDeck = self.deck?.asStruct() {
                updateDeck.title = title
                updateDeck.desc = description
                updateDeck.categories = tempCategories
                StudyCardsDataStack.sharedInstance.addOrEditDeckObject(updateDeck, deckObj: self.deck)
            }
        }
        
        self.navigationController?.popViewControllerAnimated(true)

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
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
            default:
                break
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
     
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
            case TableViewSections.Title.rawValue:
                return 44.0
            case TableViewSections.Description.rawValue:
                return 88.0
            case TableViewSections.Category.rawValue:
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
            rightAccessoryView.addTarget(self, action: "tappedAddCategoryButton:", forControlEvents: .TouchUpInside)
            
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
    
    func tappedAddCategoryButton(sender: UIBarButtonItem) {
        if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let categoryViewController = storyboard?.instantiateViewControllerWithIdentifier("Category") as? CategoryTableViewController {
            if mode == .EditDeck {
                let existingCategories = deck?.categories
                categoryViewController.selectedCategories = existingCategories?.mutableCopy() as? NSMutableOrderedSet
            }
            categoryViewController.delegate = self
            self.navigationController?.pushViewController(categoryViewController, animated: true)
        }
    }
    
    // MARK: - CategoryTableViewControllerDelegate
    
    func categoryTableViewControllerDidFinishSelectingCategory(viewController: CategoryTableViewController, selectedCategories: NSMutableOrderedSet?) {
//        self.deck?.categories = selectedCategories
        tempCategories = selectedCategories
        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
