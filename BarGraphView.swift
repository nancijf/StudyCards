//
//  BarGraphView.swift
//  StudyCards
//
//  Created by Nanci Frank on 8/9/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import Foundation

class BarGraphView: UIView {
    
    var deck: Deck?
    var totalViewed: Int?
    var maxHeight = 225
    var bottomPadding = 100
    var bottomConstraint: NSLayoutConstraint?
    var stackViewConstant: Int = 225
    
    lazy var greenBar: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.green
        return view
    }()
    lazy var greenLabel: UILabel = {
        let label = UILabel()
        label.text = "Correct"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = label.font.withSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var redBar: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        return view
    }()
    lazy var redLabel: UILabel = {
        let label = UILabel()
        label.text = "Not Answered"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = label.font.withSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var blueBar: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.blue
        return view
    }()
    lazy var blueLabel: UILabel = {
        let label = UILabel()
        label.text = "% Correct"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = label.font.withSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Go", for: UIControlState())
        return button
    }()
    
    var greenBarConstraint: NSLayoutConstraint?
    var redBarConstraint: NSLayoutConstraint?
    var blueBarConstraint: NSLayoutConstraint?
    var stackViewConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
//        backgroundColor = UIColor(red: 1.0, green: 0.9912, blue: 0.9546, alpha: 1.0)
        
        let greenStackView = UIStackView(arrangedSubviews: [greenBar, greenLabel])
        greenStackView.translatesAutoresizingMaskIntoConstraints = false
        greenStackView.axis = .vertical
        
        let redStackView = UIStackView(arrangedSubviews: [redBar, redLabel])
        redStackView.translatesAutoresizingMaskIntoConstraints = false
        redStackView.axis = .vertical
        
        let blueStackView = UIStackView(arrangedSubviews: [blueBar, blueLabel])
        blueStackView.translatesAutoresizingMaskIntoConstraints = false
        blueStackView.axis = .vertical
        
        let stackView = UIStackView(arrangedSubviews: [greenStackView, redStackView, blueStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .lastBaseline
        
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        self.addSubview(stackView)
        
        let views = ["greenBar": greenBar, "redBar": redBar, "blueBar": blueBar, "stackView": stackView, "greenLabel": greenLabel, "redLabel": redLabel, "blueLabel": blueLabel]
        let metrics = ["bottomPadding": bottomPadding, "barSpacing": 50, "barWidth": 400]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stackView]-|", options: [], metrics: metrics, views: views))
        self.stackViewConstraint = NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300)
        self.addConstraint(stackViewConstraint!)
        
        self.bottomConstraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        self.addConstraint(self.bottomConstraint!)

        stackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[greenBar(<=barWidth)]", options: [], metrics: metrics, views: views))
        stackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[redBar(==greenBar)]", options: [], metrics: metrics, views: views))
        stackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[blueBar(==greenBar)]", options: [], metrics: metrics, views: views))
        self.greenBarConstraint = NSLayoutConstraint(item: greenBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2)
        stackView.addConstraint(self.greenBarConstraint!)
        self.redBarConstraint = NSLayoutConstraint(item: redBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2)
        stackView.addConstraint(self.redBarConstraint!)
        self.blueBarConstraint = NSLayoutConstraint(item: blueBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2)
        stackView.addConstraint(self.blueBarConstraint!)
        
        self.updateConstraintsIfNeeded()
    }
    
    func animate(_ button: UIButton) {

        if let testScore = self.deck?.testscore, let totalCorrect = self.deck?.correctanswers {
            if let correctAnswers = deck?.correctanswers {
                greenLabel.text = "\(correctAnswers) Correct"
                let incorrect = (deck?.cards?.count)! - Int(correctAnswers)
                redLabel.text = "\(incorrect) Incorrect"
            }
            let correctHeight = testScore * Float(self.maxHeight)
            let wrongHeight = (1.0 - testScore) * Float(self.maxHeight)
            let correctPercentHeight = (Float(totalCorrect)/Float(totalViewed!)) * Float(self.maxHeight)
            self.greenBarConstraint?.constant = 2
            self.redBarConstraint?.constant = 2
            self.blueBarConstraint?.constant = 2

                UIView.animate(withDuration: 5.0, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0, options: UIViewAnimationOptions(), animations: {
                    self.greenBarConstraint?.constant = CGFloat(correctHeight)
                    self.redBarConstraint?.constant = CGFloat(wrongHeight)
                    self.blueBarConstraint?.constant = CGFloat(correctPercentHeight)
                    self.layoutIfNeeded()
                    }, completion: nil)
        }
    }
}
