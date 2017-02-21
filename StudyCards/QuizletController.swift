//
//  QuizletController.swift
//  StudyCards
//
//  Created by Nanci Frank on 4/30/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit
class QuizletController: NSObject {
    
    typealias SuccessBlock = (_ qlData: [QSetObject]) -> ()
    typealias SuccessBlock2 = (_ qlCardData: [CardStruct]) -> ()
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    let baseURL = "https://api.quizlet.com/2.0"
    let clientID = "client_id=Z4FeYyPHVu"
    
    let searchSets = "/search/sets?per_page=25&q="
    let getSet = "/sets/"
    
    var tempCards = [CardStruct]()
    var imageURL: String?
    
    func retrieveSets(_ setID: Int, onSuccess: @escaping SuccessBlock2) {
        let urlPath = baseURL + getSet + String(setID) + "?\(clientID)" + "&whitespace=1"
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        let request = URLRequest(url:endpoint)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }

                if let terms = json["terms"] as? [AnyObject] {
                    self.tempCards.removeAll()
                    for term in terms {
                        if let termDict = term as? [String: AnyObject] {
                            if var question = termDict["term"] as? String, var answer = termDict["definition"] as? String {
                                if let imageData = termDict["image"] as? [String: AnyObject] {
                                    self.imageURL = imageData["url"] as? String
                                    if answer.isEmpty && !question.isEmpty {
                                        answer = question
                                        question = ""
                                    }
                                } else {
                                    self.imageURL = nil
                                }
                                let tempCard = CardStruct(question: question, answer: answer, hidden: false, cardviewed: false, iscorrect: false, wronganswers: 0, ordinal: 0, imageURL: self.imageURL, deck: nil)
                                self.tempCards.append(tempCard)
                            }
                        }
                    }
                    onSuccess(self.tempCards)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }) .resume()
    }

    func searchQuizlet(_ searchText: String, onSuccess: @escaping SuccessBlock) {
        let urlPath = baseURL + searchSets + searchText + "&\(clientID)"
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        let request = URLRequest(url:endpoint)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }
                var setData = [QSetObject]()
                if let sets = json["sets"] as? [AnyObject] {
                    for qSet in sets {
                        if let setDict = qSet as? [String: AnyObject] {
                            let qSetObj = QSetObject()
                            qSetObj.title = setDict["title"] as? String
                            qSetObj.id = Int(String(describing: setDict["id"]!))
                            qSetObj.totalQuestions = setDict["term_count"] as? Int
                            qSetObj.subjects = [String(describing: setDict["subjects"])]
                            setData.append(qSetObj)
                        }
                    }
                    onSuccess(setData)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }) .resume()
    }
}

