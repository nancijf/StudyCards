//
//  ViewModels.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/27/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation

struct DeckStruct {
    var title: String?
    var desc: String?
    var testscore: Float
    var categories: NSOrderedSet?
    var cards: NSOrderedSet?
}

struct CategoryStruct {
    var name: String?
}

struct CardStruct {
    var question: String?
    var answer: String?
    var hidden: Bool
    var correctanswers: Int32
    var wronganswers: Int32
    var ordinal: Int32
    var images: NSSet?
    var decks: NSSet?
}

