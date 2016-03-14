//
//  Deck+CoreDataProperties.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Deck {

    @NSManaged var title: String?
    @NSManaged var desc: String?
    @NSManaged var testscore: Float
    @NSManaged var categories: NSOrderedSet?
    @NSManaged var cards: NSOrderedSet?

}
