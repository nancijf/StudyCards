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
    var timer: Timer? = nil
    
    let cellIdentifier = "qlCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        qzSearchController.searchResultsUpdater = self
        qzSearchController.dimsBackgroundDuringPresentation = false
        qzSearchController.searchBar.placeholder = "Search Quizlet"
        qzSearchController.delegate = self
        qzSearchController.hidesNavigationBarDuringPresentation = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        qzSearchController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(qzSearchController.view)
        qzSearchController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        qzSearchController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        qzSearchController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        qzSearchController.view.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(44, 0, tabBarHeight, 0)
        }

        qzSearchController.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qzSearchController.isActive = false
    }
    
    override func viewDidLayoutSubviews() {
        var searchBarFrame = qzSearchController.searchBar.frame
        searchBarFrame.size.width = view.frame.size.width
        qzSearchController.searchBar.frame = searchBarFrame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let navcontroller = segue.destination as! UINavigationController
            let controller = navcontroller.topViewController as! CardListTableViewController
            controller.mode = .structData
            controller.setNum = quizletData[indexPath.row].id
            controller.tempCardTitle = self.tableView.cellForRow(at: indexPath)?.textLabel?.text
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(44, 0, tabBarHeight, 0)
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }
        qzSearchController.isActive = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(searchQZ), userInfo: nil, repeats: false)
    }

    func searchQZ() {
        if let searchText = qzSearchController.searchBar.text, searchText.characters.count > 1 {
            if let escapedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                quizletController.searchQuizlet(escapedText, onSuccess: { [weak self] (quizletData) in
                    DispatchQueue.main.async(execute: {
                        self?.quizletData = quizletData
                        self?.tableView.reloadData()
                    })
                })
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizletData.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let qlData = self.quizletData[indexPath.row]
        cell.textLabel?.text = qlData.title
        if let questionCount = qlData.totalQuestions {
            cell.detailTextLabel?.text = String(questionCount)
        }

        return cell
    }
}
