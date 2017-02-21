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
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = self.contentView.frame.width
        
        return label
    }()
    
    lazy var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        contentView.addSubview(questionLabel)
        contentView.addSubview(cardImageView)
        
        questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0).isActive = true
        questionLabel.trailingAnchor.constraint(equalTo: cardImageView.leadingAnchor, constant: -10.0).isActive = true
        questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        questionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
        
        cardImageView.leadingAnchor.constraint(equalTo: questionLabel.trailingAnchor, constant: 10.0).isActive = true
        cardImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0).isActive = true
        cardImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        imageViewWidthConstraint = cardImageView.widthAnchor.constraint(equalToConstant: 75.0)
        cardImageView.heightAnchor.constraint(equalToConstant: 75.0).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        cardImageView.image = nil
        questionLabel.text = ""
    }
}
