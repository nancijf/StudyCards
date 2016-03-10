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
    var cards: NSSet?
}

struct CategoryStruct {
    var name: String?
    var decks: NSSet?
}

