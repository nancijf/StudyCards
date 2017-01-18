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
    var timer: NSTimer? = nil
    
    let cellIdentifier = "qlCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        qzSearchController.searchResultsUpdater = self
        qzSearchController.dimsBackgroundDuringPresentation = false
        qzSearchController.searchBar.sizeToFit()
        qzSearchController.searchBar.placeholder = "Search Quizlet"
        qzSearchController.delegate = self
        definesPresentationContext = false
        tableView.tableHeaderView = qzSearchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }

        qzSearchController.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        qzSearchController.active = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(44, 0, tabBarHeight, 0)
        }

    }
    
    func didDismissSearchController(searchController: UISearchController) {
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(searchQZ), userInfo: nil, repeats: false)
    }

    func searchQZ() {
        if let searchText = qzSearchController.searchBar.text where searchText.characters.count > 1 {
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
