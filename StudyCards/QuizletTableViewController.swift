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
    let searchController = UISearchController(searchResultsController: nil)
    
    let cellIdentifier = "qlCellIdentifier"
    
//    lazy var searchBar: UISearchBar =
//        {
//            let searchBarWidth = self.view.frame.width * 0.75
//            let searchBar = UISearchBar(frame: CGRectMake(0, 0, searchBarWidth, 20))
//            return searchBar
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search Quizlet"
        searchController.delegate = self
        tableView.tableHeaderView = searchController.searchBar

        
        searchController.searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
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
//        searchController.searchBar.resignFirstResponder()
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
