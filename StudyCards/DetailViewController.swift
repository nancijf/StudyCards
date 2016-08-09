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
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var checkbox: CardCheckBox!
    
    var deck: Deck?
    var isQuestionShowing: Bool = true
    var isUsingCardStruct: Bool = false
    var card: Card?
    var tempCard: CardStruct?
    var tempCardTitle: String?
    var isCorrect: Bool = false
    
    @IBAction func checkmarkTapped(sender: UIButton) {
        sender.selected = !sender.selected
        if card?.iscorrect == true {
            card?.iscorrect = false
        } else {
            card?.iscorrect = true
        }
        if !isUsingCardStruct {
            StudyCardsDataStack.sharedInstance.updateCounts(deck, card: card, isCorrect: sender.selected)
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if isUsingCardStruct {
            if let currentCard = self.tempCard {
                questionLabel.text = currentCard.question
                answerLabel.text = currentCard.answer
                cardCounter.text = String(currentCard.ordinal)
                if let image = currentCard.imageURL {
                        if let data = NSData(contentsOfURL: NSURL(string: image)!) {
                            cardImage.hidden = false
                            cardImage.image = UIImage(data: data)
                        }
                }
            }
        } else {
            if let currentCard = self.card {
                questionLabel.text = currentCard.question
                answerLabel.text = currentCard.answer
                cardCounter.text = String(currentCard.ordinal)
                if card?.iscorrect == true {
                    checkbox.selected = true
                }
                if let image = currentCard.imageURL {
                    if let data = NSData(contentsOfURL: NSURL(string: image)!) {
                        cardImage.hidden = false
                        cardImage.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerLabel.hidden = true
        cardImage.hidden = true
        self.configureView()
//        self.navigationItem.title = deck?.title
//        testScore = UIBarButtonItem(title: "Score", style: .Plain, target: self, action: #selector(showScore))
//        self.navigationItem.rightBarButtonItem = testScore
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        self.view.setNeedsDisplay()
    }
    
    @IBAction func counterView(sender: AnyObject) {
        if (isQuestionShowing) {
            
            // hide Question - show Answer
            cardImage.hidden = true
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
            cardImage.hidden = false
        }
        isQuestionShowing = !isQuestionShowing
        
    }


}

