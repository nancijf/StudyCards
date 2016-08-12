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
    
    lazy var barGraphView: BarGraphView = {
        let newView = BarGraphView(frame: self.view.bounds)
        newView.deck = self.deck
        
        return newView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(barGraphView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.barGraphView.animate(self.barGraphView.actionButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
