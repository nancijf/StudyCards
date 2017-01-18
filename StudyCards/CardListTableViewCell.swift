//
//  CardListTableViewCell.swift
//  StudyCards
//
//  Created by Nanci Frank on 1/14/17.
//  Copyright © 2017 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit

class CardListTableViewCell: UITableViewCell {
    
    var imageViewWidthConstraint: NSLayoutConstraint?
    
    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Left
        label.font = UIFont.systemFontOfSize(17.0)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = self.contentView.frame.width
        
        return label
    }()
    
    lazy var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        contentView.addSubview(questionLabel)
        contentView.addSubview(cardImageView)
        
        questionLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0).active = true
        questionLabel.trailingAnchor.constraintEqualToAnchor(cardImageView.leadingAnchor, constant: -10.0).active = true
        questionLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10.0).active = true
        questionLabel.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10.0).active = true
        
        cardImageView.leadingAnchor.constraintEqualToAnchor(questionLabel.trailingAnchor, constant: 10.0).active = true
        cardImageView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -10.0).active = true
        cardImageView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: 0).active = true
        imageViewWidthConstraint = cardImageView.widthAnchor.constraintEqualToConstant(75.0)
        cardImageView.heightAnchor.constraintEqualToConstant(75.0).active = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        cardImageView.image = nil
        questionLabel.text = ""
    }
}
