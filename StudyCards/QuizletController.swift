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
    
    typealias SuccessBlock = (qlData: [QSetObject]) -> ()
    typealias SuccessBlock2 = (qlCardData: [CardStruct]) -> ()
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    let baseURL = "https://api.quizlet.com/2.0"
    let clientID = "client_id=Z4FeYyPHVu"
    
    let searchSets = "/search/classes?per_page=25&q="
    let getSet = "/sets/"
    
    var tempCards = [CardStruct]()
    var imageURL: String?
    
    func retrieveSets(setID: Int, onSuccess: SuccessBlock2) {
        let urlPath = baseURL + getSet + String(setID) + "?\(clientID)" + "&whitespace=1"
        guard let endpoint = NSURL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        let request = NSMutableURLRequest(URL:endpoint)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        session.dataTaskWithRequest(request) { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: [.AllowFragments]) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }

                if let terms = json["terms"] as? [AnyObject] {
                    self.tempCards.removeAll()
                    for term in terms {
                        if let termDict = term as? [String: AnyObject] {
                            if let question = termDict["term"] as? String, let answer = termDict["definition"] as? String {
                                if let imageData = termDict["image"] as? [String: AnyObject] {
                                    self.imageURL = imageData["url"] as? String
                                }
                                let tempCard = CardStruct(question: question, answer: answer, hidden: false, iscorrect: false, wronganswers: 0, ordinal: 0, imageURL: self.imageURL, deck: nil)
                                self.tempCards.append(tempCard)
                            }
                        }
                    }
                    onSuccess(qlCardData: self.tempCards)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }.resume()
    }

    func searchQuizlet(searchText: String, onSuccess: SuccessBlock) {
        let urlPath = baseURL + searchSets + searchText + "&\(clientID)"
//        print(urlPath)
        guard let endpoint = NSURL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        let request = NSMutableURLRequest(URL:endpoint)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        session.dataTaskWithRequest(request) { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: [.AllowFragments]) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }
                var setData = [QSetObject]()
                if let sets = json["sets"] as? [AnyObject] {
                    for qSet in sets {
                        if let setDict = qSet as? [String: AnyObject] {
                            let qSetObj = QSetObject()
                            qSetObj.title = setDict["title"] as? String
                            qSetObj.id = Int(String(setDict["id"]!))
                            qSetObj.totalQuestions = setDict["term_count"] as? Int
                            qSetObj.subjects = [String(setDict["subjects"])]
                            setData.append(qSetObj)
                        }
                    }
                    onSuccess(qlData: setData)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }.resume()
    }
}

