//
//  Card+CoreDataProperties.swift
//  StudyCards
//
//  Created by Nanci Frank on 6/11/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Card {

    @NSManaged var answer: String?
    @NSManaged var correctanswers: NSNumber?
    @NSManaged var hidden: NSNumber?
    @NSManaged var ordinal: NSNumber?
    @NSManaged var question: String?
    @NSManaged var wronganswers: NSNumber?
    @NSManaged var imageURL: String?
    @NSManaged var deck: Deck?

}
