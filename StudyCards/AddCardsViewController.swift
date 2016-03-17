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

class AddCardsViewController: UIViewController {
    
    var isQuestionShowing: Bool = true
    var deckName: String?
    var delegate: AddCardsViewControllerDelegate?
    var addedCards: NSMutableOrderedSet?
    
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var questionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerTextView.hidden = true
        self.navigationItem.title = deckName
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addTapped:")
        self.navigationItem.rightBarButtonItem = addBarButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveButton(sender: AnyObject) {
        print("save button was tapped")
    }
    
    @IBAction func counterView(sender: AnyObject) {
        if (isQuestionShowing) {

            //hide Question - show Answer
            UIView.transitionFromView(questionTextView,
                toView: answerTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                completion:nil)
        } else {

            //hide Answer - show Question
            UIView.transitionFromView(answerTextView,
                toView: questionTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                completion: nil)
        }
        isQuestionShowing = !isQuestionShowing
        
    }
    
    func addTapped(sender: UIBarButtonItem) {
        print("Add button was tapped")
    }
    



}
