//
//  Category.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData


class Category: NSManagedObject {
    
    func asStruct() -> CategoryStruct {
        return CategoryStruct(name: self.name, decks: nil)
    }

}
