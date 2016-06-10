//
//  Image.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData


class Image: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Image {
    func asStruct() -> ImageStruct {
        return ImageStruct(imagepath: self.imagepath, imageURL: self.imageURL, width: self.width, height: self.height, xpos: self.xpos, ypos: self.ypos, cards: self.cards)

    }
}

