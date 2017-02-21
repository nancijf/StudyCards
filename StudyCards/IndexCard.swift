//
//  IndexCard.swift
//  NaviHell
//
//  Created by Stuart Levine on 4/10/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class IndexCard: UIView {
    let topSpacing: CGFloat = 80.0
    let defaults = UserDefaults.standard
    
    @IBInspectable var lineWidth: CGFloat = 1.0
    @IBInspectable var topLineWidth: CGFloat = 2.0
    @IBInspectable var lineSpacing: CGFloat = 30.0
    @IBInspectable var withLines: Bool = true
    @IBInspectable var topLineColor = UIColor(red: 0.8338, green: 0.3722, blue: 0.3937, alpha: 0.5)
    @IBInspectable var lineColor = UIColor(red: 0.3964, green: 0.6393, blue: 0.9988, alpha: 0.5)
    @IBInspectable var cardBackgroundColor = UIColor(red: 0.9999, green: 0.9956, blue: 0.9749, alpha: 1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = self.cardBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = self.cardBackgroundColor
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let cardLines = defaults.bool(forKey: "cardlines") ?? true
        if !cardLines {
            topLineWidth = 0.0
            withLines = false
        }
        
        // top red line
        context!.beginPath()
        context!.setStrokeColor(topLineColor.cgColor)
        context!.setLineWidth(topLineWidth)
        context!.move(to: CGPoint(x: 0.0, y: topSpacing))
        context!.addLine(to: CGPoint(x: rect.width, y: topSpacing))
        context!.strokePath()
        
        // add blue lines if we want them
        if withLines {
            let deltaY: CGFloat = lineSpacing;
            let numberOfLines: Int = Int((rect.height - topSpacing) / deltaY)
            context!.beginPath()
            context!.setStrokeColor(lineColor.cgColor)
            context!.setLineWidth(lineWidth)
            for i in 1...numberOfLines {
                let Y = CGFloat(i) * deltaY;
                context!.move(to: CGPoint(x: 0.0, y: topSpacing + Y))
                context!.addLine(to: CGPoint(x: rect.width, y: topSpacing + Y))
            }
            context!.strokePath()
        }
        
        UIGraphicsEndImageContext()
    }
    
}
