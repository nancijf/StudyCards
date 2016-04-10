//
//  DetailViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var cardCounter: UITextField!
    @IBOutlet weak var backgroundViewImage: IndexCardImageView!
    
    var deck: Deck?
    var isQuestionShowing: Bool = true
    var cards: [Card]?
    var card: Card?
    
    struct CardIndex {
        private var cardCount: Int = 0
        private var cardIndex: Int = 0
        
        init(cardCount: Int) {
            self.cardCount = cardCount
        }
        
        func current() -> Int {
            return cardIndex
        }
        
        mutating func next() -> Int {
            cardIndex += 1
            if cardIndex >= cardCount {
                cardIndex = 0
            }
            return cardIndex
        }
        
        mutating func previous() -> Int {
            cardIndex -= 1
            if cardIndex < 0 {
                cardIndex = cardCount - 1
            }
            return cardIndex
        }
    }
    
    var cardIndex: CardIndex?
    
    @IBAction func getNextCard(sender: UIBarButtonItem) {
        let nextCardIndex = self.cardIndex!.next()
        let card = self.cards?[nextCardIndex]
        questionLabel.text = card?.question
        answerLabel.text = card?.answer
    }
    
    @IBAction func getPreviousCard(sender: UIBarButtonItem) {
        let prevCardIndex = self.cardIndex!.previous()
        let card = self.cards?[prevCardIndex]
        questionLabel.text = card?.question
        answerLabel.text = card?.answer
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let currentCard = self.card {
            questionLabel.text = currentCard.question
            answerLabel.text = currentCard.answer
            cardCounter.text = String(currentCard.ordinal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.navigationItem.title = deck?.title
        answerLabel.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func counterView(sender: AnyObject) {
        if (isQuestionShowing) {
            
            // hide Question - show Answer
            UIView.transitionFromView(questionLabel,
                                      toView: answerLabel,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                                      completion:nil)
        } else {
            
            // hide Answer - show Question
            UIView.transitionFromView(answerLabel,
                                      toView: questionLabel,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                                      completion: nil)
        }
        isQuestionShowing = !isQuestionShowing
        
    }


}

