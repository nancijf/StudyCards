//
//  CardCheckBox.swift
//  StudyCards
//
//  Created by Nanci Frank on 8/4/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit

class CardCheckBox: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage(named: "BoxUnchecked"), for: UIControlState())
        self.setImage(UIImage(named: "BoxChecked"), for: UIControlState.selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setImage(UIImage(named: "BoxUnchecked"), for: UIControlState())
        self.setImage(UIImage(named: "BoxChecked"), for: UIControlState.selected)
    }
    
}
