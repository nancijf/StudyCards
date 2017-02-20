//
//  Image+CoreDataProperties.swift
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

extension Image {

    @NSManaged var imagepath: String?
    @NSManaged var imageURL: NSObject?
    @NSManaged var width: Float
    @NSManaged var height: Float
    @NSManaged var xpos: Float
    @NSManaged var ypos: Float
    @NSManaged var cards: NSSet?

}
