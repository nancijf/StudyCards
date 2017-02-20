//
//  Card+CoreDataProperties.swift
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

extension Card {

    @NSManaged var question: String?
    @NSManaged var answer: String?
    @NSManaged var hidden: Bool
    @NSManaged var cardviewed: Bool
    @NSManaged var iscorrect: Bool
    @NSManaged var wronganswers: Int32
    @NSManaged var ordinal: Int32
    @NSManaged var imageURL: String?
    @NSManaged var deck: Deck?

}
