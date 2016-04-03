//
//  DetailViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    
    var deck: Deck?

//    var deckItem: Deck? {
//        didSet {
//            // Update the view.
//            self.configureView()
//        }
//    }

    func configureView() {
        // Update the user interface for the detail item.
        if let deck = self.deck, cards = deck.cards, card = cards.firstObject as? Card {
            questionTextView.text = card.question
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.navigationItem.title = deck?.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

