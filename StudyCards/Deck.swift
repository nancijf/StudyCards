//
//  Deck.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData


class Deck: NSManagedObject {
    
}

extension Deck {
    
    func asStruct() -> DeckStruct {
        return DeckStruct(title: self.title, desc: self.desc, testscore: self.testscore, correctanswers: self.correctanswers, categories: self.categories, cards: self.cards)
    }
    
}
