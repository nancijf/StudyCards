//
//  IndexCardImageView.swift
//  StudyCards
//
//  Created by Nanci Frank on 4/10/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit


class IndexCardImageView: UIImageView {

    let topSpacing: CGFloat = 80.0
    
    @IBInspectable var lineColor = UIColor.clearColor()
    @IBInspectable var lineWidth: CGFloat = 1.0
    @IBInspectable var topLineColor = UIColor.clearColor()
    @IBInspectable var topLineWidth: CGFloat = 2.0
    @IBInspectable var lineSpacing: CGFloat = 35.0
    @IBInspectable var withLines: Bool = true
    
    init(frame: CGRect,
         backgroundColor: UIColor = UIColor(red: 0.9999, green: 0.9956, blue: 0.9749, alpha: 1.0),
         lineColor: UIColor = UIColor(red: 0.3964, green: 0.6393, blue: 0.9988, alpha: 0.5),
         topLineColor:UIColor = UIColor(red: 0.8338, green: 0.3722, blue: 0.3937, alpha: 0.5)) {
        
        super.init(frame: frame)
        
        self.backgroundColor = backgroundColor
        self.topLineColor = topLineColor
        self.lineColor = lineColor
        
        self.image = self.drawIndexCard(frame, lineSpacing: lineSpacing, withLines: withLines)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let backgroundColor: UIColor = UIColor(red: 0.9999, green: 0.9956, blue: 0.9749, alpha: 1.0)
        let lineColor: UIColor = UIColor(red: 0.3964, green: 0.6393, blue: 0.9988, alpha: 0.5)
        let topLineColor:UIColor = UIColor(red: 0.8338, green: 0.3722, blue: 0.3937, alpha: 0.5)
            
        super.init(coder: aDecoder)
        
        self.backgroundColor = backgroundColor
        self.topLineColor = topLineColor
        self.lineColor = lineColor
        
        self.image = self.drawIndexCard(frame, lineSpacing: lineSpacing, withLines: withLines)
    }
    
    func drawIndexCard(rect: CGRect, lineSpacing: CGFloat = 24.0, withLines: Bool = true) -> UIImage? {
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        // top red line
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, topLineColor.CGColor)
        CGContextSetLineWidth(context, topLineWidth)
        CGContextMoveToPoint(context, 0.0, topSpacing)
        CGContextAddLineToPoint(context, rect.width, topSpacing)
        CGContextStrokePath(context)
        
        // add blue lines if we want them
        if withLines {
            let deltaY: CGFloat = lineSpacing;
            let numberOfLines: Int = Int((rect.height - topSpacing) / deltaY)
            CGContextBeginPath(context)
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
            CGContextSetLineWidth(context, lineWidth)
            for i in 1...numberOfLines {
                let Y = CGFloat(i) * deltaY;
                CGContextMoveToPoint(context, 0.0, topSpacing + Y)
                CGContextAddLineToPoint(context, rect.width, topSpacing + Y)
            }
            CGContextStrokePath(context)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
