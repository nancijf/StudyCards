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
    var imageSet: NSSet?
    
    lazy var mainStoryBoard: UIStoryboard = {
        let storyboard: UIStoryboard = UIStoryboard(name: kStoryBoardID, bundle: nil)
            
        return storyboard
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if usingCardStruct {
            if let tempCards = tempCards {
                for (idx, tempCard) in tempCards.enumerate() {
                    if let controller = cardViewControllerWithStruct(tempCard)  {
                        controllerArray.append(controller)
//                        tempCard.ordinal = idx + 1
                    }
                }
                setViewControllers([controllerArray[currentIndex]], direction: .Forward, animated: true, completion: nil)
            }
        } else {
            if let cards = deck?.cards?.array as? [Card] {
                for (idx, card) in cards.enumerate() {
                    if let controller = cardViewControllerWith(card) {
                        controllerArray.append(controller)
                        card.ordinal = idx + 1
                    }
                }
                setViewControllers([controllerArray[currentIndex]], direction: .Forward, animated: true, completion: nil)
            }
        }
        
        dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let title = tempCardTitle {
            self.navigationItem.title = title
            let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveTapped))
            self.navigationItem.rightBarButtonItem = saveButton
        } else {
            self.navigationItem.title = deck?.title
        }

        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveTapped(sender: UIBarButtonItem) {
        let newDeck = DeckStruct(title: tempCardTitle, desc: nil, testscore: 0.0, categories: nil, cards: nil)

        let deckEntity = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck)
        for tempCard in tempCards! {
//            print(tempCard.images)
            let newCard = CardStruct(question: tempCard.question, answer: tempCard.answer, hidden: false, correctanswers: 0, wronganswers: 0, ordinal: 0, images: tempCard.images, deck: deckEntity)
            StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
        }
        if let navCotroller = self.navigationController {
            navCotroller.popViewControllerAnimated(true)
        }
    }
    
    func cardViewControllerWith(card: Card) -> DetailViewController? {
        if let cardViewController = mainStoryBoard.instantiateViewControllerWithIdentifier(kViewControllerID) as? DetailViewController {
            cardViewController.card = card
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
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = controllerArray.indexOf(viewController as! DetailViewController) else {
            return nil
        }
        
        var previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 {
            previousIndex = controllerArray.count - 1
        }
        
        return controllerArray[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = controllerArray.indexOf(viewController as! DetailViewController) else {
            return nil
        }
        
        var nextIndex = viewControllerIndex + 1
        
        if nextIndex >= controllerArray.count {
            nextIndex = 0
        }
        
        return controllerArray[nextIndex]
    }
    

}
