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
    @IBOutlet weak var cardStakView: UIStackView!
    
    let indexCard = IndexCard()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var deck: Deck?
    var isQuestionShowing: Bool = true
    var isUsingCardStruct: Bool = false
    var card: Card?
    var tempCard: CardStruct?
    var tempCardTitle: String?
    var isCorrect: Bool = false
    
    var fontSize: CGFloat {
        let fontSize = defaults.floatForKey("fontsize") ?? 17.0
        return CGFloat(fontSize)
    }
    
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
        if isUsingCardStruct {
            if let currentCard = self.tempCard {
                questionLabel.text = currentCard.question
                questionLabel.sizeToFit()
                answerLabel.text = currentCard.answer
                cardCounter.text = String(currentCard.ordinal)
                if let image = currentCard.imageURL {
                    if let data = NSData(contentsOfURL: NSURL(string: image)!) {
                        cardImage.hidden = false
                        cardImage.image = UIImage(data: data)
                        self.tempCard?.image = cardImage.image
                    }
                }
            }
        } else {
            if let currentCard = self.card {
                questionLabel.text = currentCard.question
                questionLabel.sizeToFit()
                answerLabel.text = currentCard.answer
                cardCounter.text = String(currentCard.ordinal)
                if card?.iscorrect == true {
                    checkbox.selected = true
                }
                if let image = currentCard.imageURL {
                    var imagePath = image
                    if !image.containsString("://") {
                        imagePath = "file://" + createFilePath(withFileName: image)
                    }
                    if let data = NSData(contentsOfURL: NSURL(string: imagePath)!) {
                        cardImage.hidden = false
                        cardImage.image = UIImage(data: data)
                        cardImage.sizeToFit()
                    }
                }
            }
        }
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerLabel.font = UIFont.systemFontOfSize(CGFloat(fontSize))
        questionLabel.font = UIFont.systemFontOfSize(CGFloat(fontSize))
        answerLabel.hidden = true
        cardImage.hidden = true
        if let wasViewed = card?.cardviewed {
            if !wasViewed {
                StudyCardsDataStack.sharedInstance.updateCardView(card, cardviewed: true)
            }
        }

        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        self.view.setNeedsDisplay()
    }
    
    func createFilePath(withFileName fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docs: String = paths[0]
        let fullPath = docs + "/" + fileName
        
        return fullPath
    }
    
    @IBAction func counterView(sender: AnyObject) {
        if (isQuestionShowing) {
            
            // hide Question - show Answer
            UIView.transitionFromView(cardStakView,
                                      toView: answerLabel,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                                      completion:nil)
        } else {
            
            // hide Answer - show Question
            UIView.transitionFromView(answerLabel,
                                      toView: cardStakView,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                                      completion: nil)
        }
        isQuestionShowing = !isQuestionShowing
        
    }


}

