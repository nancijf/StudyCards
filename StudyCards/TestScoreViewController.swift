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
    
//    lazy var barGraphView: BarGraphView = {
//        let newView = BarGraphView(frame: self.view.bounds)
//        newView.deck = self.deck
//        
//        return newView
//    }()

    @IBOutlet weak var chartlabel: UILabel!
    @IBOutlet weak var barGraphView: BarGraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barGraphView.deck = deck
        
        if let totalQuestions = deck?.cards?.count {
            chartlabel.text = "Total Questions: \(totalQuestions)"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.barGraphView.animate(self.barGraphView.actionButton)
        animationRan = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.verticalSizeClass == .Compact {
            barGraphView.stackViewConstraint?.constant = 225
            barGraphView.maxHeight = 210
        } else {
            barGraphView.stackViewConstraint?.constant = 350
            barGraphView.maxHeight = 335
        }
        if animationRan {
            self.barGraphView.animate(self.barGraphView.actionButton)
        }
    }

}
