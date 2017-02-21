//
//  CardListTableViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 4/10/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import GameplayKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum CardListControllerMode: Int {
    case objectData
    case structData
}

class CardListTableViewController: UITableViewController, AddCardsViewControllerDelegate {
    
    var deck: Deck?
    var cards: [Card]?
    var tempCards: [CardStruct]?
    var mode: CardListControllerMode?
    var tempCardTitle: String?
    var isShuffleOn: Bool = true
    var isInEditMode: Bool = false
    var detailViewController: CardPageViewController?
    let defaults = UserDefaults.standard
    let quizletController = QuizletController()
    var setNum: Int?
    
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = tempCardTitle {
            self.navigationItem.title = title
        } else {
            self.navigationItem.title = deck?.title
        }
        if mode == .structData {
            
            indicator.color = UIColor.darkGray
            indicator.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
            indicator.center = self.view.center
            self.view.addSubview(indicator)
            indicator.bringSubview(toFront: self.view)
            indicator.startAnimating()
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Import", style: UIBarButtonItemStyle.plain, target: self, action: #selector(importTapped))
            if let setNum = setNum {
                quizletController.retrieveSets(setNum, onSuccess: { [weak self] (qlCardData) in
                    DispatchQueue.main.async(execute: {
                        self?.tempCards = qlCardData
                        self?.indicator.stopAnimating()
                        self?.indicator.hidesWhenStopped = true
                        self?.tableView.reloadData()
                    })
                })
            }
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editTapped))
        }
        
        isShuffleOn = defaults.bool(forKey: "shakeToShuffle") ?? true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cards = deck?.cards?.array as? [Card]
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if isShuffleOn {
            if motion == .motionShake && mode != .structData {
                let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: cards!)
                cards = shuffled as? [Card]
                tableView.reloadData()
            }
        }
    }

    func editTapped(_ button: UIBarButtonItem) {
        isInEditMode = !isInEditMode
        button.title = isInEditMode ? "Done" : "Edit"
        button.tintColor = isInEditMode ? UIColor.red : UIColor.blue
    }
    
    func importTapped(_ sender: UIBarButtonItem) {
        ImportCards.saveCards(tempCards, tempCardTitle: tempCardTitle, viewController: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .structData {
            guard let cardCount = tempCards?.count else {
                return 0
            }
            return cardCount
        } else {
            guard let cardCount = cards?.count else {
                return 0
            }
            return cardCount
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var text: String?
        var hasImage: Bool = false
        
        if mode == .structData {
            let card = self.tempCards?[indexPath.row]
            text = card?.question
            hasImage = card?.imageURL != nil
        }
        else {
            let card = self.cards?[indexPath.row]
            text = card?.question
            hasImage = card?.imageURL != nil
        }
        let boundingWidth = hasImage ? tableView.frame.width - 200.0 : tableView.frame.width - 75.0
        let boundingSize = CGSize(width: boundingWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = text?.boundingRect(with: boundingSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)], context: nil)
        
        return hasImage ? max(100.0, rect?.height ?? 100.0) : (rect?.height ?? 44.0) + 25.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cardCell = cell as! CardListTableViewCell
        cardCell.imageViewWidthConstraint?.isActive = false
        var imageURL: String?
        var questionText: String?
        if mode == .structData {
            imageURL = self.tempCards?[indexPath.row].imageURL
            questionText = self.tempCards?[indexPath.row].question
        } else {
            imageURL = self.cards?[indexPath.row].imageURL
            questionText = self.cards?[indexPath.row].question
        }
        cardCell.questionLabel.text = questionText?.characters.count > 0 ? questionText : "(No Question Text)"
        if let urlString = imageURL?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)?.createFilePath(), let url = URL(string: urlString) {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    if self.mode == .structData {
                        self.tempCards?[indexPath.row].image = image
                    }
                    let scale: CGFloat = 300.0 / image.size.height
                    let scaledImage = image.resize(byPercent: scale)
                    DispatchQueue.main.async(execute: {
                        cardCell.imageViewWidthConstraint?.isActive = true
                        cardCell.cardImageView.image = scaledImage
                        cardCell.setNeedsUpdateConstraints()
                        cardCell.updateConstraintsIfNeeded()
                    })
                }
            })
        }
        cardCell.setNeedsUpdateConstraints()
        cardCell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isInEditMode {
            let card = self.deck?.cards?.object(at: indexPath.row) as? Card
            if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let addCardsViewController = storyboard?.instantiateViewController(withIdentifier: "AddCards") as? AddCardsViewController {
                addCardsViewController.deck = deck
                addCardsViewController.card = card
                addCardsViewController.mode = .editCard
                addCardsViewController.delegate = self
                self.navigationController?.pushViewController(addCardsViewController, animated: true)
            }
        } else {
            if let storyBoard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let controller = storyBoard?.instantiateViewController(withIdentifier: "CardPageViewController") as? CardPageViewController {
                if mode == .structData {
                    controller.tempCards = self.tempCards
                    controller.usingCardStruct = true
                    controller.tempCardTitle = tempCardTitle
                } else {
                    controller.deck = self.deck
                    controller.usingCardStruct = false
                }
                controller.currentIndex = indexPath.row
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func addCardsViewControllerDidFinishAddingCards(_ viewController: AddCardsViewController, addedCards: NSMutableOrderedSet?) {
        cards = deck?.cards?.array as? [Card]
        tableView.reloadData()
    }
}

extension UIImage {
    
    func resize(byPercent percent: CGFloat) -> UIImage? {
        let size = self.size.applying(CGAffineTransform(scaleX: percent, y: percent))
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

extension String {
    
    func createFilePath() -> String {
        guard !self.contains("://") else {
            return self
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory: String = paths[0]
        let fullPath = "file://" + documentDirectory + "/" + self
        
        return fullPath
    }
    
}

