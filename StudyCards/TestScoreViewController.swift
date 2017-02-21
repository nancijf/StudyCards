//
//  TestScoreViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 8/9/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import Foundation

class TestScoreViewController: UIViewController {
    
    var deck: Deck?
    var animationRan: Bool = false
    var totalViewed: Int?
    
    @IBOutlet weak var chartlabel: UILabel!
    @IBOutlet weak var barGraphView: BarGraphView!
    @IBOutlet weak var cardsViewedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let totalQuestions = deck?.cards?.count, let totalViewed = totalViewed {
            chartlabel.text = "Total Cards: \(totalQuestions)"
            cardsViewedLabel.text = "Total Cards Viewed: \(totalViewed)"
        }
        barGraphView.deck = deck
        barGraphView.totalViewed = totalViewed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.barGraphView.animate(self.barGraphView.actionButton)
        animationRan = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.verticalSizeClass == .compact {
            barGraphView.stackViewConstraint?.constant = 225
            barGraphView.maxHeight = 210
//            barGraphView.stackViewConstant = 225
        } else {
            barGraphView.stackViewConstraint?.constant = 350
            barGraphView.maxHeight = 335
//            barGraphView.stackViewConstant = 350
        }
        if animationRan {
            self.barGraphView.animate(self.barGraphView.actionButton)
        }
    }

}
