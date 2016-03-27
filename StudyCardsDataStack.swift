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
    private init() {}
    
    var managedObjectContext: NSManagedObjectContext?
    
    func addOrEditDeckObject(deck: DeckStruct, deckObj: Deck? = nil) {
        var deckEntity = deckObj
        
        if deckEntity == nil {
            deckEntity = NSEntityDescription.insertNewObjectForEntityForName("Deck", inManagedObjectContext: self.managedObjectContext!) as? Deck
        }
        
        deckEntity?.title = deck.title
        deckEntity?.desc = deck.desc
        deckEntity?.testscore = deck.testscore
        deckEntity?.categories = deck.categories
        deckEntity?.cards = deck.cards
        
        // Save the context.
        do {
            try self.managedObjectContext?.save()
        } catch {
            abort()
        }
    }
    
    func addOrEditCategoryObject(category: CategoryStruct, categoryObj: Category? = nil) {
        var categoryEntity = categoryObj
        
        if categoryEntity == nil {
            categoryEntity = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: self.managedObjectContext!) as? Category
        }
        
        categoryEntity?.name = category.name
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            abort()
        }
    }
    
    func addOrEditCardObject(card: CardStruct, cardObj: Card? = nil) -> Card? {
        var cardEntity = cardObj
        
        if cardEntity == nil {
            cardEntity = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: self.managedObjectContext!) as? Card
        }
        
        cardEntity?.question = card.question
        cardEntity?.answer = card.answer
        cardEntity?.deck = card.deck
        cardEntity?.ordinal = card.ordinal
        cardEntity?.hidden = card.hidden
        cardEntity?.correctanswers = card.correctanswers
        cardEntity?.wronganswers = card.wronganswers
        cardEntity?.images = nil
        cardEntity?.deck = card.deck
        
        
        // Save the context.
        do {
            try self.managedObjectContext?.save()

        } catch {
            abort()
        }
        
        return cardEntity

    }
    
    func deleteCardObject(cardObj: Card? = nil, deckObj: Deck?) {
        if let cardEntity = cardObj, let cards = deckObj?.cards?.mutableCopy() {
            cards.removeObject(cardEntity)
            deckObj?.cards = cards as? NSOrderedSet
            self.managedObjectContext?.deleteObject(cardEntity)
            
            // Save the context.
            do {
                try self.managedObjectContext?.save()
                
            } catch {
                abort()
            }
        }
    }
    
    func fetchedResultsController(entityName: String, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) -> NSFetchedResultsController? {
        
        var fetchedResultsController: NSFetchedResultsController?
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        if let aFetchedResultsController: NSFetchedResultsController? = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: entityName) {
            fetchedResultsController = aFetchedResultsController
            do {
                try fetchedResultsController!.performFetch()
            } catch {
                abort()
            }
        }
        
        return fetchedResultsController
    }
    
}
