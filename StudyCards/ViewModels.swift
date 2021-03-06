//
//  ViewModels.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/27/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit

struct DeckStruct {
    var title: String?
    var desc: String?
    var testscore: Float
    var correctanswers: Int32
    var categories: NSOrderedSet?
    var cards: NSOrderedSet?
}

struct CategoryStruct {
    var name: String?
    var decks: NSOrderedSet?
}

struct CardStruct {
    var question: String?
    var answer: String?
    var hidden: Bool
    var cardviewed: Bool
    var iscorrect: Bool
    var wronganswers: Int32
    var ordinal: Int32
    var imageURL: String?
    var deck: Deck?
    var image: UIImage? = nil
    
    init(
        question: String?,
        answer: String?,
        hidden: Bool,
        cardviewed: Bool,
        iscorrect: Bool,
        wronganswers: Int32,
        ordinal: Int32,
        imageURL: String?,
        deck: Deck?)
    {
        self.question = question
        self.answer = answer
        self.hidden = hidden
        self.cardviewed = cardviewed
        self.iscorrect = iscorrect
        self.wronganswers = wronganswers
        self.ordinal = ordinal
        self.imageURL = imageURL
        self.deck = deck
    }
}

struct ImageStruct {
    var imagepath: String?
    var imageURL: NSObject?
    var width: Float = 0.0
    var height: Float = 0.0
    var xpos: Float = 0.0
    var ypos: Float = 0.0
    var cards: NSSet?    
}

class QSetObject: NSObject {
    
    var title: String?
    var id: Int?
    var subjects: [String]?
    var totalQuestions: Int?
    
}


