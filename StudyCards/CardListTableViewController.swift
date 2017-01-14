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
    var isShuffleOn: Bool = true
    var isInEditMode: Bool = false
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = tempCardTitle {
            self.navigationItem.title = title
        } else {
            self.navigationItem.title = deck?.title
        }
        if mode == .StructData {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Import", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(importTapped))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editTapped))
        }
        
        isShuffleOn = defaults.boolForKey("shakeToShuffle") ?? true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cards = deck?.cards?.array as? [Card]
        tableView.reloadData()
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
        if isShuffleOn {
            if motion == .MotionShake && mode != .StructData {
                let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(cards!)
                cards = shuffled as? [Card]
                tableView.reloadData()
            }
        }
    }
    
    func editTapped(button: UIBarButtonItem) {
        isInEditMode = !isInEditMode
        button.title = isInEditMode ? "Done" : "Edit"
        button.tintColor = isInEditMode ? UIColor.redColor() : UIColor.blueColor()
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var text: String?
        var hasImage: Bool = false
        
        if mode == .StructData {
            let card = self.tempCards?[indexPath.row]
            text = card?.question
            hasImage = card?.imageURL != nil
        }
        else {
            let card = self.cards?[indexPath.row]
            text = card?.question
            hasImage = card?.imageURL != nil
        }
        let boundingWidth = hasImage ? tableView.frame.width - 200.0 : tableView.frame.width - 75.0
        let boundingSize = CGSize(width: boundingWidth, height: CGFloat.max)
        let rect = text?.boundingRectWithSize(boundingSize, options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName: UIFont.systemFontOfSize(10.0)], context: nil)
        
        return hasImage ? max(100.0, rect?.height ?? 100.0) : (rect?.height ?? 44.0) + 25.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let cardCell = cell as! CardListTableViewCell
        cardCell.imageViewWidthConstraint?.active = false
        var imageURL: String?
        var questionText: String?
        if mode == .StructData {
            imageURL = self.tempCards?[indexPath.row].imageURL
            questionText = self.tempCards?[indexPath.row].question
        } else {
            imageURL = self.cards?[indexPath.row].imageURL
            questionText = self.cards?[indexPath.row].question
        }
        cardCell.questionLabel.text = questionText?.characters.count > 0 ? questionText : "(No Question Text)"
        if let urlString = imageURL?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())?.createFilePath(), let url = NSURL(string: urlString) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                    if self.mode == .StructData {
                        self.tempCards?[indexPath.row].image = image
                    }
                    let scale: CGFloat = 300.0 / image.size.height
                    let scaledImage = image.resize(byPercent: scale)
                    dispatch_async(dispatch_get_main_queue(), {
                        cardCell.imageViewWidthConstraint?.active = true
                        cardCell.cardImageView.image = scaledImage
                        cardCell.setNeedsUpdateConstraints()
                        cardCell.updateConstraintsIfNeeded()
                    })
                }
            })
        }
        cardCell.setNeedsUpdateConstraints()
        cardCell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isInEditMode {
            let card = self.deck?.cards?.objectAtIndex(indexPath.row) as? Card
            if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let addCardsViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCards") as? AddCardsViewController {
                addCardsViewController.deck = deck
                addCardsViewController.card = card
                addCardsViewController.mode = .EditCard
                if splitViewController?.viewControllers.count > 1 {
                    let navController = UINavigationController(rootViewController: addCardsViewController)
                    addCardsViewController.navigationItem.title = "Edit Card"
                    showDetailViewController(navController, sender: self)
                } else {
                    self.navigationController?.pushViewController(addCardsViewController, animated: true)
                }
            }
        } else {
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
}

extension UIImage {
    
    func resize(byPercent percent: CGFloat) -> UIImage? {
        let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(percent, percent))
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

extension String {
    
    func createFilePath() -> String {
        guard !self.containsString("://") else {
            return self
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectory: String = paths[0]
        let fullPath = "file://" + documentDirectory + "/" + self
        
        return fullPath
    }
    
}

