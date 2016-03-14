//
//  CardsViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 3/14/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

protocol AddCardsViewControllerDelegate: class {
    func addCardsViewControllerDidFinishAddingCards(viewController: AddCardsViewController, addedCards: NSMutableSet?)
}


class AddCardsViewController: UIViewController {
    
    var isQuestionShowing: Bool = true
    var deckName: String?
    var delegate: AddCardsViewControllerDelegate?
    var addedCards: NSMutableSet?
    
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var questionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerTextView.hidden = true
        self.navigationItem.title = deckName

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

            //show Graph

//            setupGraphDisplay()

            UIView.transitionFromView(answerTextView,
                toView: questionTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                completion: nil)
        }
        isQuestionShowing = !isQuestionShowing
        
    }
    
//      Code used to transition between question and answer
    
    
//    @IBAction func counterViewTap(gesture:UITapGestureRecognizer?) {
//        if (isQuestionShowing) {
//            
//            //hide Question - show Answer
//            UIView.transitionFromView(graphView,
//                toView: counterView,
//                duration: 1.0,
//                options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
//                completion:nil)
//        } else {
//            
//            //show Graph
//            
//            setupGraphDisplay()
//            
//            UIView.transitionFromView(counterView,
//                toView: graphView,
//                duration: 1.0,
//                options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
//                completion: nil)
//        }
//        isGraphViewShowing = !isGraphViewShowing
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
