//
//  QuizletTableViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 5/1/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class QuizletTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    let quizletController = QuizletController()
    var quizletData = [QSetObject]()
    var qlCardData = [CardStruct]()
    let qzSearchController = UISearchController(searchResultsController: nil)
    
    let cellIdentifier = "qlCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in qz viewdidload")
        
        qzSearchController.searchResultsUpdater = self
        qzSearchController.dimsBackgroundDuringPresentation = false
        qzSearchController.definesPresentationContext = false
        qzSearchController.searchBar.sizeToFit()
        qzSearchController.searchBar.placeholder = "Search Quizlet"
        qzSearchController.delegate = self
        qzSearchController.hidesNavigationBarDuringPresentation = true
        tableView.tableHeaderView = qzSearchController.searchBar
        
//        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
//            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

//        if tableView.tableHeaderView == nil {
//            tableView.tableHeaderView = qzSearchController.searchBar
//        }
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }
//        self.tableView.setNeedsLayout()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        print("in qz viewdidappear")
        qzSearchController.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("in qz viewwilldisappear")
        qzSearchController.searchBar.resignFirstResponder()
        qzSearchController.active = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        print("seachcontroller dismissed")
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text where searchText.characters.count > 1 {
            if let escapedText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                quizletController.searchQuizlet(escapedText, onSuccess: { (quizletData) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.quizletData = quizletData
                        self.tableView.reloadData()
                    })
                })
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizletData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)

        let qlData = self.quizletData[indexPath.row]
        cell.textLabel?.text = qlData.title
        if let questionCount = qlData.totalQuestions {
            cell.detailTextLabel?.text = String(questionCount)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let idNum = quizletData[indexPath.row].id
        if let setNum = idNum {
            quizletController.retrieveSets(setNum, onSuccess: { (qlCardData) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.qlCardData = qlCardData
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewControllerWithIdentifier("CardListTableViewController") as? CardListTableViewController
                    controller?.mode = .StructData
                    controller?.tempCards = qlCardData
                    controller?.tempCardTitle = cell?.textLabel?.text
                    self.navigationController?.pushViewController(controller!, animated: true)
                })
            })
        }
    }

}
