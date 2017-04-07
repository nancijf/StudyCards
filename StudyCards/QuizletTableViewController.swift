//
//  QuizletTableViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 5/1/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class QuizletTableViewController: UITableViewController, UISearchBarDelegate, UISplitViewControllerDelegate {
    
    let quizletController = QuizletController()
    var quizletData = [QSetObject]()
    var qlCardData = [CardStruct]()
    var timer: Timer? = nil
    var searchWidthAnchor: NSLayoutConstraint?
    
    let cellIdentifier = "qlCellIdentifier"
    
    lazy var searchBar: UISearchBar = {
        let searchBarWidth = self.view.frame.width
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: searchBarWidth, height: 44.0))

        return searchBar
    }()
    
    lazy var addCancelButton: UIBarButtonItem = {
        let addCancelButton = UIBarButtonItem(title: "Hide Keyboard", style: .plain, target: self, action: #selector(cancelSearch) )
        addCancelButton.isEnabled = true
        
        return addCancelButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createViews()
        definesPresentationContext = false
        searchBar.delegate = self
        searchBar.placeholder = "Search Quizlet..."
        searchBar.showsCancelButton = true
        
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

        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        updateViews()
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
    
    // MARK: - SearchBar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(searchQZ), userInfo: nil, repeats: false)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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

    func cancelSearch() {
        searchBar.resignFirstResponder()
    }
    
    func createViews() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchWidthAnchor = searchBar.widthAnchor.constraint(equalToConstant: view.frame.size.width)
        searchWidthAnchor?.isActive = true
    }
    
    func updateViews() {
        searchBar.frame.size.width = view.frame.size.width
        searchWidthAnchor?.constant = view.frame.size.width
        searchWidthAnchor?.isActive = true
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
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
