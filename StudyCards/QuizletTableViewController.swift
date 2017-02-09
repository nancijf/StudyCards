//
//  QuizletTableViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 5/1/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class QuizletTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISplitViewControllerDelegate {
    
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
        qzSearchController.searchBar.placeholder = "Search Quizlet"
        qzSearchController.delegate = self
        qzSearchController.hidesNavigationBarDuringPresentation = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        qzSearchController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(qzSearchController.view)
        qzSearchController.view.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        qzSearchController.view.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        qzSearchController.view.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        qzSearchController.view.heightAnchor.constraintEqualToConstant(44).active = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(44, 0, tabBarHeight, 0)
        }

        qzSearchController.active = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        qzSearchController.active = false
    }
    
    override func viewDidLayoutSubviews() {
        var searchBarFrame = qzSearchController.searchBar.frame
        searchBarFrame.size.width = view.frame.size.width
        qzSearchController.searchBar.frame = searchBarFrame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let navcontroller = segue.destinationViewController as! UINavigationController
            let controller = navcontroller.topViewController as! CardListTableViewController
            controller.mode = .StructData
            controller.setNum = quizletData[indexPath.row].id
            controller.tempCardTitle = self.tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        }
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
        qzSearchController.active = false
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(searchQZ), userInfo: nil, repeats: false)
    }

    func searchQZ() {
        if let searchText = qzSearchController.searchBar.text where searchText.characters.count > 1 {
            if let escapedText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                quizletController.searchQuizlet(escapedText, onSuccess: { [weak self] (quizletData) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.quizletData = quizletData
                        self?.tableView.reloadData()
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
}
