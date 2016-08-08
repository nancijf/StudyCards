//
//  CardsViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 3/14/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

protocol AddCardsViewControllerDelegate: class {
    func addCardsViewControllerDidFinishAddingCards(viewController: AddCardsViewController, addedCards: NSMutableOrderedSet?)
}

enum AddCardViewControllerMode: Int {
    case AddCard = 0
    case EditCard
}

class AddCardsViewController: UIViewController, UITextViewDelegate {
    
    var isQuestionShowing: Bool = true
    var doesCardContainText: Bool {
        get {
            return !questionTextView.text.isEmpty || !answerTextView.text.isEmpty
        }
    }
    var wasCardSaved: Bool = false
    var deck: Deck?
    var card: Card?
    var delegate: AddCardsViewControllerDelegate?
    var addedCards: NSMutableOrderedSet?
    var ordinal: Int32 = 0
    var mode: AddCardViewControllerMode?
    
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var answerTextView: NFTextView!
    @IBOutlet weak var questionTextView: NFTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = deck?.title
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        questionTextView.placeholderText = "Enter question here..."
        answerTextView.placeholderText = "Enter answer here..."
        questionTextView.delegate = self
        answerTextView.delegate = self
        
        if mode == .EditCard {
            questionTextView.text = card?.question
            answerTextView.text = card?.answer
            questionTextView.placeholderLabel.hidden = true
            answerTextView.placeholderLabel.hidden = true
        }
        
        switchButton.setTitle("Switch to Answer", forState: .Normal)
        answerTextView.hidden = true
        questionTextView.becomeFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        if let nfTextView = textView as? NFTextView {
            nfTextView.placeholderLabel.hidden = !nfTextView.text.isEmpty
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func deleteButton(sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Do you want to delete this card?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (action) -> Void in }
        let saveAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            let delCard = self.card
            StudyCardsDataStack.sharedInstance.deleteCardObject(delCard, deckObj: self.deck)
            self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        var alertMessage = ""
        if mode == .AddCard {
            let newCard = CardStruct(question: questionTextView.text, answer: answerTextView.text, hidden: false, iscorrect: false, wronganswers: 0, ordinal: ordinal, imageURL: nil, deck: deck)
            card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
            mode = .EditCard
            alertMessage = "Your new card has been saved."
        } else if mode == .EditCard {
            if var updateCard = self.card?.asStruct() {
                updateCard.question = questionTextView.text
                updateCard.answer = answerTextView.text
                card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(updateCard, cardObj: self.card)
                alertMessage = "Changes to your card have been saved."
            }
        }
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: { () -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        wasCardSaved = true
    }
    
    @IBAction func doneWasPressed(sender: AnyObject) {
        if doesCardContainText && !wasCardSaved {
            let alert = UIAlertController(title: "Alert", message: "Do you want to save this card?", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (action) -> Void in
                self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
                self.navigationController?.popViewControllerAnimated(true)
            }
            let saveAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                if self.mode == .AddCard {
                    let newCard = CardStruct(question: self.questionTextView.text, answer: self.answerTextView.text, hidden: false, iscorrect: false, wronganswers: 0, ordinal: self.ordinal, imageURL: nil, deck: self.deck)
                    self.card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
                } else if self.mode == .EditCard {
                    if var updateCard = self.card?.asStruct() {
                        updateCard.question = self.questionTextView.text
                        updateCard.answer = self.answerTextView.text
                        self.card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(updateCard, cardObj: self.card)
                    }
                }
                self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
                self.navigationController?.popViewControllerAnimated(true)
            })
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func counterView(sender: AnyObject) {
        if (isQuestionShowing) {

            // hide Question - show Answer
            UIView.transitionFromView(questionTextView,
                toView: answerTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                completion:nil)
            switchButton.setTitle("Switch to Question", forState: .Normal)
            answerTextView.becomeFirstResponder()

        } else {

            // hide Answer - show Question
            UIView.transitionFromView(answerTextView,
                toView: questionTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                completion: nil)
            switchButton.setTitle("Switch to Answer", forState: .Normal)
            questionTextView.becomeFirstResponder()
        }
        isQuestionShowing = !isQuestionShowing
        
    }
    
    func addTapped(sender: UIBarButtonItem) {
        mode = .AddCard
        card = nil
        questionTextView.text = ""
        answerTextView.text = ""
        questionTextView.placeholderLabel.hidden = false
        answerTextView.placeholderLabel.hidden = false
        if !isQuestionShowing {
            counterView(switchButton)
        }
        wasCardSaved = false
    }

}
