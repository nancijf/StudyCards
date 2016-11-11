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
    
    let indexCard = IndexCard()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var deck: Deck?
    var isQuestionShowing: Bool = true
    var isUsingCardStruct: Bool = false
    var card: Card?
    var tempCard: CardStruct?
    var tempCardTitle: String?
    var isCorrect: Bool = false
    var qLabel = UILabel()
    var aLabel = UILabel()
    var imageView = UIImageView()
    
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
                qLabel.text = currentCard.question
                answerLabel.text = currentCard.answer
                cardCounter.text = String(currentCard.ordinal)
                if let image = currentCard.imageURL {
                    if let data = NSData(contentsOfURL: NSURL(string: image)!) {
                        imageView.hidden = false
                        imageView.image = UIImage(data: data)
                        self.tempCard?.image = imageView.image
                    }
                }
            }
        } else {
            if let currentCard = self.card {
                qLabel.text = currentCard.question
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
                        imageView.hidden = false
                        imageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fontSize = defaults.stringForKey("fontsize") ?? "17"
        
        createViews()
        if let fontValue = Double(fontSize) {
            answerLabel.font = answerLabel.font.fontWithSize(CGFloat(fontValue))
            qLabel.font = questionLabel.font.fontWithSize(CGFloat(fontValue))
        }
        questionLabel.hidden = true
        answerLabel.hidden = true
        imageView.hidden = true
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
    
    func createViews() {
        imageView.frame = CGRect.zero
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.view.addSubview(imageView)
        
        qLabel.frame = CGRect.zero
        qLabel.translatesAutoresizingMaskIntoConstraints = false
        qLabel.font = UIFont.systemFontOfSize(22)
        qLabel.sizeToFit()
        
        self.view.addSubview(qLabel)
        qLabel.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        qLabel.leftAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leftAnchor).active = true
        qLabel.rightAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.rightAnchor).active = true
        qLabel.bottomAnchor.constraintEqualToAnchor(imageView.topAnchor, constant: -10).active = true
        qLabel.heightAnchor.constraintGreaterThanOrEqualToConstant(50).active = true
        
        imageView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: -50).active = true
        imageView.topAnchor.constraintEqualToAnchor(qLabel.bottomAnchor).active = true
        imageView.leftAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.rightAnchor).active = true
        self.updateViewConstraints()
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
            imageView.hidden = true
            UIView.transitionFromView(qLabel,
                                      toView: answerLabel,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                                      completion:nil)
        } else {
            
            // hide Answer - show Question
            UIView.transitionFromView(answerLabel,
                                      toView: qLabel,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                                      completion: nil)
            imageView.hidden = false
        }
        isQuestionShowing = !isQuestionShowing
        
    }


}

