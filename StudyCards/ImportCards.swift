//
//  ImportCards.swift
//  StudyCards
//
//  Created by Nanci Frank on 10/28/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit

class ImportCards {
    
    class func saveCards(tempCards: [CardStruct]?, tempCardTitle: String?, viewController: UIViewController? = nil) {
        guard let tempCards = tempCards, tempCardTitle = tempCardTitle else {
            return
        }
        let newDeck = DeckStruct(title: tempCardTitle, desc: nil, testscore: 0.0, correctanswers: 0, categories: nil, cards: nil)
        
        let deckEntity = StudyCardsDataStack.sharedInstance.addOrEditDeckObject(newDeck)
        for var tempCard in tempCards {
            var imageName = tempCard.imageURL
            if let image = tempCard.image {
                imageName = saveImage(image)
            }
            tempCard.imageURL = imageName
            tempCard.deck = deckEntity
            StudyCardsDataStack.sharedInstance.addOrEditCardObject(tempCard)
        }
        let alert = UIAlertController(title: "Alert", message: "This deck has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { done in
            if viewController?.isKindOfClass(CardListTableViewController.self) ?? false {
                viewController?.navigationController?.popToRootViewControllerAnimated(true)
            } else if viewController?.isKindOfClass(CardPageViewController.self) ?? false {
                let split = viewController?.splitViewController
                if let navController = split?.viewControllers[0] as? UINavigationController {
                    navController.popToRootViewControllerAnimated(true)
                }
            }
        }))

        viewController?.presentViewController(alert, animated: true, completion: { () -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                alert.dismissViewControllerAnimated(true, completion: nil)
                if viewController?.isKindOfClass(CardListTableViewController.self) ?? false {
                    viewController?.navigationController?.popToRootViewControllerAnimated(true)
                } else if viewController?.isKindOfClass(CardPageViewController.self) ?? false {
                    let split = viewController?.splitViewController
                    if let navController = split?.viewControllers[0] as? UINavigationController {
                        navController.popToRootViewControllerAnimated(true)
                    }
                }
            }
        })
    }
    
    class func saveImage(image: UIImage?) -> String? {
        guard let image = image, data = UIImageJPEGRepresentation(image, 1.0) else {
            return ""
        }
        
        let fileName = createUniqueFileName()
        let fullPath = createFilePath(withFileName: fileName)
        let _ = data.writeToFile(fullPath, atomically: true)
        
        return fileName
    }
    
    class func createUniqueFileName() -> String {
        let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil)) as String
        let uniqueFileName = "card-image-" + uuid + ".jpg"
        
        return uniqueFileName
    }
    
    class func createFilePath(withFileName fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docs: String = paths[0]
        let fullPath = docs + "/" + fileName
        
        return fullPath
    }

}
