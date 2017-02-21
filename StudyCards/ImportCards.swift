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
    
    class func saveCards(_ tempCards: [CardStruct]?, tempCardTitle: String?, viewController: UIViewController? = nil) {
        guard let tempCards = tempCards, let tempCardTitle = tempCardTitle else {
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
        let alert = UIAlertController(title: "Alert", message: "This deck has been saved.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { done in
            self.popCurrentVC(viewController)
        }))

        viewController?.present(alert, animated: true, completion: { () -> Void in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                alert.dismiss(animated: true, completion: nil)
                self.popCurrentVC(viewController)
            }
        })
    }
    
    class func popCurrentVC(_ viewController: UIViewController?) {
        if viewController?.isKind(of: CardListTableViewController.self) ?? false {
            viewController?.navigationController?.popToRootViewController(animated: true)
        } else if viewController?.isKind(of: CardPageViewController.self) ?? false {
            let split = viewController?.splitViewController
            if let navController = split?.viewControllers[0] as? UINavigationController {
                navController.popToRootViewController(animated: true)
            }
        }
    }
    
    class func saveImage(_ image: UIImage?) -> String? {
        guard let image = image, let data = UIImageJPEGRepresentation(image, 1.0) else {
            return ""
        }
        
        let fileName = createUniqueFileName()
        let fullPath = createFilePath(withFileName: fileName)
        let _ = (try? data.write(to: URL(fileURLWithPath: fullPath), options: [.atomic])) != nil
        
        return fileName
    }
    
    class func createUniqueFileName() -> String {
        let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil)) as String
        let uniqueFileName = "card-image-" + uuid + ".jpg"
        
        return uniqueFileName
    }
    
    class func createFilePath(withFileName fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docs: String = paths[0]
        let fullPath = docs + "/" + fileName
        
        return fullPath
    }

}
