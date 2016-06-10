//
//  Card.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData


class Card: NSManagedObject {
    
// Insert code here to add functionality to your managed object subclass

}

extension Card {
    func asStruct() -> CardStruct {
        var imageData = [ImageStruct]()
        for image in (images?.allObjects as? [Image])! {
            imageData.append(image.asStruct())
        }
        return CardStruct(question: self.question, answer: self.answer, hidden: self.hidden, correctanswers: self.correctanswers, wronganswers: self.wronganswers, ordinal: self.ordinal, images: imageData, deck: self.deck)
    }
}
