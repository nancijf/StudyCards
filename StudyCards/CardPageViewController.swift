//
//  CardPageViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 4/9/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData

let kViewControllerID = "DetailViewController"
let kStoryBoardID = "Main"

class CardPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var controllerArray = [DetailViewController]()
    var deck: Deck?
    var isQuestionShowing: Bool = true
    var cards: [Card]?
    var currentIndex: Int = 0
    var tempCards: [CardStruct]?
    var usingCardStruct = false
    var tempCardTitle: String?
    var testScore: UIBarButtonItem!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    lazy var mainStoryBoard: UIStoryboard = {
        let storyboard: UIStoryboard = UIStoryboard(name: kStoryBoardID, bundle: nil)
            
        return storyboard
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        controllerArray.removeAll()
        
        if usingCardStruct {
            if let tempCards = tempCards {
                for tempCard in tempCards {
                    if let controller = cardViewControllerWithStruct(tempCard)  {
                        controllerArray.append(controller)
                    }
                }
            }
        } else if let cards = deck?.cards?.array as? [Card] {
            let hideCorrect = defaults.boolForKey("locked")

            for (idx, card) in cards.enumerate() {
                if hideCorrect && card.iscorrect {
                    continue
                } else if let controller = cardViewControllerWith(card) {
                    controllerArray.append(controller)
                    card.ordinal = idx + 1
                }
            }

        } else {
            let tempCard = CardStruct(question: "Tap a Deck to view Cards", answer: nil, hidden: false, cardviewed: false, iscorrect: false, wronganswers: 0, ordinal: 0, imageURL: nil, deck: nil)
            for _ in 0...2 {
                if let controller = cardViewControllerWithStruct(tempCard) {
                    controllerArray.append(controller)
                }
            }
        }
        
        if controllerArray.count > 0 {
            setViewControllers([controllerArray[currentIndex]], direction: .Forward, animated: true, completion: nil)
        }
        
        dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let fontSize = defaults.stringForKey("fontsize")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let title = tempCardTitle {
            self.navigationItem.title = title
            let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveTapped))
            self.navigationItem.rightBarButtonItem = saveButton
        } else {
            self.navigationItem.title = deck?.title
            testScore = UIBarButtonItem(title: "Score", style: .Plain, target: self, action: #selector(showScore))
            self.navigationItem.rightBarButtonItem = testScore
        }

        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showScore() {
        if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let testScoreViewController = storyboard?.instantiateViewControllerWithIdentifier("ShowTestScores") as? TestScoreViewController {
            if let cards = deck?.cards?.array as? [Card] {
                var totalViewed = 0
                for card in cards {
                    if card.cardviewed {
                        totalViewed += 1
                    }
                }
                testScoreViewController.totalViewed = totalViewed
            }
            testScoreViewController.deck = deck
            self.navigationController?.pushViewController(testScoreViewController, animated: true)
        }
    }
    
    func saveTapped(sender: UIBarButtonItem) {
        let newDeck = DeckStruct(title: tempCardTitle, desc: nil, testscore: 0.0, correctanswers: 0, categories: nil, cards: nil)

        let deckEntity = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck)
        for var tempCard in tempCards! {
            var imageName = tempCard.imageURL
            if let image = tempCard.image {
                imageName = saveImage(image)
            }
            tempCard.imageURL = imageName
            tempCard.deck = deckEntity
//            let newCard = CardStruct(question: tempCard.question, answer: tempCard.answer, hidden: false, cardviewed: false, iscorrect: false, wronganswers: 0, ordinal: 0, imageURL: imageName, deck: deckEntity)
            StudyCardsDataStack.sharedInstance.addOrEditCardObject(tempCard)
        }
        let alert = UIAlertController(title: "Alert", message: "This deck has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: { () -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    func saveImage(image: UIImage?) -> String? {
        guard let image = image, data = UIImageJPEGRepresentation(image, 1.0) else {
            return ""
        }
        
        let fileName = createUniqueFileName()
        let fullPath = createFilePath(withFileName: fileName)
        let _ = data.writeToFile(fullPath, atomically: true)
        
        return fileName
    }
    
    func createUniqueFileName() -> String {
        let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil)) as String
        let uniqueFileName = "card-image-" + uuid + ".jpg"
        
        return uniqueFileName
    }
    
    func createFilePath(withFileName fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docs: String = paths[0]
        let fullPath = docs + "/" + fileName
        
        return fullPath
    }
    
    func cardViewControllerWith(card: Card) -> DetailViewController? {
        if let cardViewController = mainStoryBoard.instantiateViewControllerWithIdentifier(kViewControllerID) as? DetailViewController {
            cardViewController.card = card
            cardViewController.deck = deck
            cardViewController.isUsingCardStruct = false
            
            return cardViewController
        }
        return nil
    }
    
    func cardViewControllerWithStruct(tempCard: CardStruct) -> DetailViewController? {
        if let cardViewController = mainStoryBoard.instantiateViewControllerWithIdentifier(kViewControllerID) as? DetailViewController {
            cardViewController.tempCard = tempCard
            cardViewController.isUsingCardStruct = true
            cardViewController.tempCardTitle = tempCardTitle
            return cardViewController
        }
        return nil
    }
    
    // MARK: pageViewController Delegate calls
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = controllerArray.indexOf(viewController as! DetailViewController) else {
            return nil
        }
        if controllerArray.count == 1 {
            return nil
        } else {
            var previousIndex = viewControllerIndex - 1
            
            if previousIndex < 0 {
                previousIndex = controllerArray.count - 1
            }
            
            return controllerArray[previousIndex]            
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = controllerArray.indexOf(viewController as! DetailViewController) else {
            return nil
        }
        
        if controllerArray.count == 1 {
            return nil
        } else {
            var nextIndex = viewControllerIndex + 1
            
            if nextIndex >= controllerArray.count {
                nextIndex = 0
            }
            
            return controllerArray[nextIndex]
        }
    }

}
