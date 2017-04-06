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
    var searchWidthAnchor: NSLayoutConstraint?
    
    let cellIdentifier = "qlCellIdentifier"
    
    lazy var searchBar: UISearchBar = {
        let searchBarWidth = self.view.frame.width
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: searchBarWidth, height: 44.0))
        return searchBar
    }()
    
    lazy var addCancelButton: UIBarButtonItem = {
        let addCancelButton = UIBarButtonItem(title: "Hide Search", style: .plain, target: self, action: #selector(cancelSearch) )
        addCancelButton.isEnabled = true
        
        return addCancelButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        qzSearchController.searchResultsUpdater = self
//        qzSearchController.dimsBackgroundDuringPresentation = false
//        qzSearchController.searchBar.placeholder = "Search Quizlet"
//        qzSearchController.delegate = self
//        qzSearchController.searchBar.delegate = self
        createViews()

        definesPresentationContext = false

        searchBar.delegate = self
        searchBar.placeholder = "Search Quizlet..."
        let viewWidth = self.view.frame.width
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 44))
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = addCancelButton
        navBar.pushItem(navItem, animated: false)
        searchBar.inputAccessoryView = navBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
//            self.tableView.contentInset = UIEdgeInsetsMake(44, 0, tabBarHeight, 0)
//        }

//        qzSearchController.isActive = true
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
//        qzSearchController.isActive = false
    }
    
    override func viewDidLayoutSubviews() {
        updateViews()
//        qzSearchController.searchBar.showsCancelButton = false
//        var searchBarFrame = qzSearchController.searchBar.frame
//        searchBarFrame.size.width = view.frame.size.width
//        view.setNeedsUpdateConstraints()
//        view.updateConstraintsIfNeeded()
//        qzSearchController.searchBar.frame = searchBarFrame
//        view.layoutIfNeeded()
//        self.updateViewConstraints()
//        view.updateConstraintsIfNeeded()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
        
    func cancelSearch() {
        searchBar.resignFirstResponder()
//        qzSearchController.isActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(searchQZ), userInfo: nil, repeats: false)
    }

    
//    func didPresentSearchController(_ searchController: UISearchController) {
//
//        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
//            self.tableView.contentInset = UIEdgeInsetsMake(44, 0, tabBarHeight, 0)
//        }
//    }
    
    func createViews() {
//        qzSearchController.view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(qzSearchController.view)
//        qzSearchController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        qzSearchController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        qzSearchController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        qzSearchController.view.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        searchWidthAnchor = qzSearchController.view.widthAnchor.constraint(equalToConstant: view.frame.size.width)
//        searchWidthAnchor?.isActive = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchWidthAnchor = qzSearchController.view.widthAnchor.constraint(equalToConstant: view.frame.size.width)
        searchWidthAnchor?.isActive = true

    }
    
    func updateViews() {
        searchBar.showsCancelButton = false
        searchBar.frame.size.width = view.frame.size.width
        searchWidthAnchor?.constant = view.frame.size.width
        searchWidthAnchor?.isActive = true
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight, 0)
        }
        qzSearchController.isActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel clicked")
        self.dismiss(animated: false, completion: nil)
    }
    

    
    func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(searchQZ), userInfo: nil, repeats: false)
    }

    func searchQZ() {
        if let searchText = searchBar.text, searchText.characters.count > 1 {
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
