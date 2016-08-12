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
    var maxHeight = 300
    
    lazy var greenBar: UIView = {
        let view = UIView(frame: CGRectZero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.greenColor()
        return view
    }()
    lazy var greenLabel: UILabel = {
        let label = UILabel()
        label.text = "Correct"
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.font = label.font.fontWithSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var redBar: UIView = {
        let view = UIView(frame: CGRectZero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.redColor()
        return view
    }()
    lazy var redLabel: UILabel = {
        let label = UILabel()
        label.text = "Not Answered"
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.font = label.font.fontWithSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var blueBar: UIView = {
        let view = UIView(frame: CGRectZero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.blueColor()
        return view
    }()
    lazy var blueLabel: UILabel = {
        let label = UILabel()
        label.text = "% Correct"
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.font = label.font.fontWithSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
//    lazy var orangeBar: UIView = {
//        let view = UIView(frame: CGRectZero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.orangeColor()
//        return view
//    }()
//    lazy var orangeLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Spend"
//        label.textColor = UIColor.blackColor()
//        label.textAlignment = .Center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    lazy var chartLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .RoundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Go", forState: .Normal)
        return button
    }()
    
    var greenBarConstraint: NSLayoutConstraint?
    var redBarConstraint: NSLayoutConstraint?
    var blueBarConstraint: NSLayoutConstraint?
    var orangeBarConstraint: NSLayoutConstraint?
    var chartLabelConstraints: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        backgroundColor = UIColor(red: 1.0, green: 0.9912, blue: 0.9546, alpha: 1.0)
        actionButton.addTarget(self, action: #selector(animate), forControlEvents: .TouchUpInside)
        
        let greenStackView = UIStackView(arrangedSubviews: [greenBar, greenLabel])
        greenStackView.translatesAutoresizingMaskIntoConstraints = false
        greenStackView.axis = .Vertical
        
        let redStackView = UIStackView(arrangedSubviews: [redBar, redLabel])
        redStackView.translatesAutoresizingMaskIntoConstraints = false
        redStackView.axis = .Vertical
        
        let blueStackView = UIStackView(arrangedSubviews: [blueBar, blueLabel])
        blueStackView.translatesAutoresizingMaskIntoConstraints = false
        blueStackView.axis = .Vertical
        
//        let orangeStackView = UIStackView(arrangedSubviews: [orangeBar, orangeLabel])
//        orangeStackView.translatesAutoresizingMaskIntoConstraints = false
//        orangeStackView.axis = .Vertical
        
        let stackView = UIStackView(arrangedSubviews: [greenStackView, redStackView, blueStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Horizontal
        stackView.alignment = .LastBaseline
        stackView.distribution = .EqualSpacing
        
        self.addSubview(stackView)
//        self.addSubview(actionButton)
        self.addSubview(chartLabel)
        
        let views = ["greenBar": greenBar, "redBar": redBar, "blueBar": blueBar, "stackView": stackView, "greenLabel": greenLabel, "redLabel": redLabel, "blueLabel": blueLabel, "chartLabel": chartLabel]
        let metrics = ["bottomPadding": 100, "barSpacing": 50, "barWidth": 75]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[stackView]-30-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[stackView]-bottomPadding-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[chartLabel]", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[chartLabel]", options: [], metrics: metrics, views: views))

        
//        greenStackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[greenBar]-20-[greenLabel]", options: [], metrics: metrics, views: views))
//        redStackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[redBar]-20-[redLabel]", options: [], metrics: metrics, views: views))
//        blueStackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[blueBar]-20-[blueLabel]", options: [], metrics: metrics, views: views))
//        orangeStackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[orangeBar]-20-[orangeLabel]", options: [], metrics: metrics, views: views))
        
        stackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[greenBar(barWidth)]", options: [], metrics: metrics, views: views))
        stackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[redBar(barWidth)]", options: [], metrics: metrics, views: views))
        stackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[blueBar(barWidth)]", options: [], metrics: metrics, views: views))
//        stackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[orangeBar(barWidth)]", options: [], metrics: metrics, views: views))
        
        self.greenBarConstraint = NSLayoutConstraint(item: greenBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2)
        stackView.addConstraint(self.greenBarConstraint!)
        self.redBarConstraint = NSLayoutConstraint(item: redBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2)
        stackView.addConstraint(self.redBarConstraint!)
        self.blueBarConstraint = NSLayoutConstraint(item: blueBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2)
        stackView.addConstraint(self.blueBarConstraint!)
//        self.orangeBarConstraint = NSLayoutConstraint(item: orangeBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2)
//        stackView.addConstraint(self.orangeBarConstraint!)
        
//        self.addConstraint(NSLayoutConstraint(item: actionButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
//        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[actionButton(100)]-10-|", options: [], metrics: nil, views: ["actionButton": actionButton]))
        
        self.updateConstraintsIfNeeded()
    }
    
    func animate(button: UIButton) {

        if let cardCount = self.deck?.cards?.count {
            chartLabel.text = "Total Questions: \(cardCount)"
        }
        let correctHeight = (self.deck?.testscore)! * Float(self.maxHeight)
        let wrongHeight = (1.0 - (self.deck?.testscore)!) * Float(self.maxHeight)

        if button.titleLabel?.text == "Reset" {
            UIView.animateWithDuration(5.0, delay: 0.2, options: [.CurveEaseInOut], animations: {
                self.greenBarConstraint?.constant = 2
                self.redBarConstraint?.constant = 2
                self.blueBarConstraint?.constant = 2
//                self.orangeBarConstraint?.constant = 2
                
//                self.updateConstraintsIfNeeded()
                self.layoutIfNeeded()
                }, completion: { done in
                    self.actionButton.setTitle("Go", forState: .Normal)
                    
            })
        }
        else {
            UIView.animateWithDuration(5.0, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0, options: [.CurveEaseInOut], animations: {
                self.greenBarConstraint?.constant = CGFloat(correctHeight)
                self.redBarConstraint?.constant = CGFloat(wrongHeight)
                self.blueBarConstraint?.constant = 50
//                self.orangeBarConstraint?.constant = 100
                
//                self.updateConstraintsIfNeeded()
                self.layoutIfNeeded()
                }, completion: { done in
                    self.actionButton.setTitle("Reset", forState: .Normal)
            })
        }
    }
}
