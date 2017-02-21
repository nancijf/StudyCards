//
//  StudyCardsDataStack.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/27/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData


class StudyCardsDataStack {
    
    static let sharedInstance = StudyCardsDataStack()
    
    fileprivate init() {}
    
    var managedObjectContext: NSManagedObjectContext?
    
    func addOrEditDeckObject(_ deck: DeckStruct, deckObj: Deck? = nil) -> Deck? {
        var deckEntity = deckObj
        
        if deckEntity == nil {
            deckEntity = NSEntityDescription.insertNewObject(forEntityName: "Deck", into: self.managedObjectContext!) as? Deck
        }
        
        deckEntity?.title = deck.title
        deckEntity?.desc = deck.desc
        deckEntity?.testscore = deck.testscore
        deckEntity?.correctanswers = deck.correctanswers
        deckEntity?.categories = deck.categories
        deckEntity?.cards = deck.cards
        
        // Save the context.
        self.saveContext()
        
        return deckEntity
    }
    
    func addOrEditCategoryObject(_ category: CategoryStruct, categoryObj: Category? = nil) -> Category? {
        var categoryEntity = categoryObj
        
        if categoryEntity == nil {
            categoryEntity = NSEntityDescription.insertNewObject(forEntityName: "Category", into: self.managedObjectContext!) as? Category
        }
        
        categoryEntity?.name = category.name
        categoryEntity?.decks = category.decks
        
        self.saveContext()
        
        return categoryEntity
    }
    
    func addOrEditCardObject(_ card: CardStruct, cardObj: Card? = nil) -> Card? {
        var cardEntity = cardObj
        
        if cardEntity == nil {
            cardEntity = NSEntityDescription.insertNewObject(forEntityName: "Card", into: self.managedObjectContext!) as? Card
        }
        
        cardEntity?.question = card.question
        cardEntity?.answer = card.answer
        cardEntity?.ordinal = card.ordinal
        cardEntity?.hidden = card.hidden
        cardEntity?.cardviewed = card.cardviewed
        cardEntity?.iscorrect = card.iscorrect
        cardEntity?.wronganswers = card.wronganswers
        cardEntity?.imageURL = card.imageURL
        cardEntity?.deck = card.deck
        
        // Save the context.
        self.saveContext()
        
        return cardEntity
    }
    
    func deleteCardObject(_ cardObj: Card? = nil, deckObj: Deck?) {
        if let cardEntity = cardObj, let cards = deckObj?.cards?.mutableCopy() {
            (cards as AnyObject).remove(cardEntity)
            deckObj?.cards = cards as? NSOrderedSet
            self.managedObjectContext?.delete(cardEntity)
            
            // Save the context.
            self.saveContext()
                
        }
    }
    
    func updateCounts(_ deck: Deck?, card: Card?, isCorrect: Bool) {
        let updateCount = isCorrect ? 1 : -1
        deck?.correctanswers += updateCount
        if let totalCards = deck?.cards?.count {
            deck?.testscore = Float((deck?.correctanswers)!) / Float(totalCards)
        }
        card?.iscorrect = isCorrect
        
        self.saveContext()
            
    }
    
    func updateCardView(_ card: Card?, cardviewed: Bool) {
        card?.cardviewed = cardviewed
        
        self.saveContext()
    }
    
    func fetchedResultsController(_ entityName: String?, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) -> NSFetchedResultsController<NSFetchRequestResult>? {
        
        var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
        
        guard let entityName = entityName else { return nil }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        if let aFetchedResultsController: NSFetchedResultsController? = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil) {
            fetchedResultsController = aFetchedResultsController
            do {
                try fetchedResultsController!.performFetch()
            } catch {
                abort()
            }
        }
        
        return fetchedResultsController
    }
    
    func saveContext () {
        if let hasChanges = managedObjectContext?.hasChanges, hasChanges {
            managedObjectContext?.performAndWait({ 
                do {
                    try self.managedObjectContext?.save()
                } catch {
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            })
        }
    }
    
}
