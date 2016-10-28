//
//  CardListTableViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 4/10/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import GameplayKit

enum CardListControllerMode: Int {
    case ObjectData
    case StructData
}

class CardListTableViewController: UITableViewController {
    
    var deck: Deck?
    var cards: [Card]?
    var tempCards: [CardStruct]?
    var mode: CardListControllerMode?
    var tempCardTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cards = deck?.cards?.array as? [Card]
        if let title = tempCardTitle {
            self.navigationItem.title = title
        } else {
            self.navigationItem.title = deck?.title
        }
        self.tableView.estimatedRowHeight = 40
        self.tableView.rowHeight = UITableViewAutomaticDimension
        if mode == .StructData {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Import", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(importTapped))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake && mode != .StructData {
            let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(cards!)
            cards = shuffled as? [Card]
            tableView.reloadData()
        }
    }
    
    func importTapped(sender: UIBarButtonItem) {
        ImportCards.saveCards(tempCards, tempCardTitle: tempCardTitle, viewController: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .StructData {
            guard let cardCount = tempCards?.count else {
                return 0
            }
            return cardCount
        } else {
            guard let cardCount = cards?.count else {
                return 0
            }
            return cardCount
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        if mode == .StructData {
            let card = self.tempCards?[indexPath.row]
            cell.textLabel?.text = card?.question
            cell.detailTextLabel?.text = String((indexPath.row + 1))
        } else {
            let card = self.cards?[indexPath.row]
            cell.textLabel?.text = card?.question
            cell.detailTextLabel?.text = String((indexPath.row + 1))
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyBoard = UIStoryboard(name: kStoryBoardID, bundle: nil)
        if let navController = storyBoard.instantiateViewControllerWithIdentifier("DetailNavController") as? UINavigationController, controller = navController.topViewController as? CardPageViewController {
            if mode == .StructData {
                controller.tempCards = self.tempCards
                controller.usingCardStruct = true
                controller.tempCardTitle = tempCardTitle
            } else {
                controller.deck = self.deck
                controller.usingCardStruct = false
            }
            controller.currentIndex = indexPath.row
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            self.splitViewController?.showDetailViewController(navController, sender: self.splitViewController?.viewControllers.first)
        }
    }
}
