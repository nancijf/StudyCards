//
//  DeckEditorTableViewCell.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/21/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class DeckEditorTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var cardImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleTextField.text = ""
        self.descTextView.text = ""
        self.titleTextField.isHidden = false
        self.descTextView.isHidden = false
        self.titleTextField.isEnabled = true
        self.cardImageView.isHidden = false
        self.cardImageView.image = nil
    }

}
