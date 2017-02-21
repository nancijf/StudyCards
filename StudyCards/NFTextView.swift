//
//  NFTextView.swift
//  StudyCards
//
//  Created by Nanci Frank on 3/19/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class NFTextView: UITextView {
    
    let defaults = UserDefaults.standard
    
    var fontSize: CGFloat {
        let fontSize = defaults.float(forKey: "fontsize") ?? 17.0
        return CGFloat(fontSize)
    }

    var placeholderText: String = "" {
        didSet {
            self.placeholderLabel.text = placeholderText
            self.placeholderLabel.sizeToFit()
        }
    }
    
    lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: self.fontSize)
        placeholderLabel.frame.origin = CGPoint(x: 10, y: 10)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !self.text.isEmpty
        
        return placeholderLabel
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.addSubview(self.placeholderLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(self.placeholderLabel)
    }
    
}

