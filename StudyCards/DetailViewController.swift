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
    let defaults = UserDefaults.standard
    
    var deck: Deck?
    var isQuestionShowing: Bool = true
    var isUsingCardStruct: Bool = false
    var card: Card?
    var tempCard: CardStruct?
    var tempCardTitle: String?
    var isCorrect: Bool = false
    var isUsingDefaultCard: Bool = false
    
    var fontSize: CGFloat {
        let fontSize = defaults.float(forKey: "fontsize") ?? 17.0
        return CGFloat(fontSize)
    }
    
    @IBAction func checkmarkTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if card?.iscorrect == true {
            card?.iscorrect = false
        } else {
            card?.iscorrect = true
        }
        if !isUsingCardStruct {
            StudyCardsDataStack.sharedInstance.updateCounts(deck, card: card, isCorrect: sender.isSelected)
        }
    }
    
    func configureView() {
        if isUsingCardStruct {
            if let currentCard = self.tempCard {
                questionLabel.text = currentCard.question
                questionLabel.textColor = isUsingDefaultCard ? UIColor.lightGray : UIColor.black
                questionLabel.sizeToFit()
                answerLabel.text = currentCard.answer
                cardCounter.text = String(currentCard.ordinal)
                if let image = currentCard.imageURL {
                    if let data = try? Data(contentsOf: URL(string: image)!) {
                        cardImage.isHidden = false
                        cardImage.image = UIImage(data: data)
                        self.tempCard?.image = cardImage.image
                    }
                } else if isUsingDefaultCard {
                    cardImage.isHidden = false
                    cardImage.image = UIImage(named: "SDImageGray")
                    if isUsingDefaultCard && UIDevice.current.userInterfaceIdiom == .pad {
                        cardImage.contentMode = .center
                    } else {
                        cardImage.contentMode = .scaleAspectFit
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
                    checkbox.isSelected = true
                }
                if let image = currentCard.imageURL {
                    var imagePath = image
                    if !image.contains("://") {
                        imagePath = "file://" + createFilePath(withFileName: image)
                    }
                    if let data = try? Data(contentsOf: URL(string: imagePath)!) {
                        cardImage.isHidden = false
                        cardImage.image = UIImage(data: data)


                    }
                }
            }
        }
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        questionLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        answerLabel.isHidden = true
        cardImage.isHidden = true
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.view.setNeedsDisplay()
    }
    
    func createFilePath(withFileName fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docs: String = paths[0]
        let fullPath = docs + "/" + fileName
        
        return fullPath
    }
    
    @IBAction func counterView(_ sender: AnyObject) {
        if (isQuestionShowing) {
            
            // hide Question - show Answer
            UIView.transition(from: cardStakView,
                                      to: answerLabel,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.transitionFlipFromLeft, UIViewAnimationOptions.showHideTransitionViews],
                                      completion:nil)
        } else {
            
            // hide Answer - show Question
            UIView.transition(from: answerLabel,
                                      to: cardStakView,
                                      duration: 1.0,
                                      options: [UIViewAnimationOptions.transitionFlipFromRight, UIViewAnimationOptions.showHideTransitionViews],
                                      completion: nil)
        }
        isQuestionShowing = !isQuestionShowing
        
    }


}

