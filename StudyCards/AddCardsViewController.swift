//
//  CardsViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 3/14/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import Foundation
import Photos

let imageExtra: CGFloat = 70.0
let topInsetForLandscape: CGFloat = 60.0
let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
let boundingRightLeftInset: CGFloat = 50.0

protocol AddCardsViewControllerDelegate: class {
    func addCardsViewControllerDidFinishAddingCards(viewController: AddCardsViewController, addedCards: NSMutableOrderedSet?)
}

enum AddCardViewControllerMode: Int {
    case AddCard = 0
    case EditCard
}

class AddCardsViewController: UIViewController, UITextViewDelegate {
    
    var isQuestionShowing: Bool = true
    var imageAdded: Bool = false
    var doesCardContainText: Bool {
        get {
            return !qTextView.text.isEmpty || !answerTextView.text.isEmpty || photoImageView.image != nil
        }
    }
    var wasCardSaved: Bool = true
    var deck: Deck?
    var card: Card?
    var delegate: AddCardsViewControllerDelegate?
    var addedCards: NSMutableOrderedSet?
    var ordinal: Int32 = 0
    var mode: AddCardViewControllerMode?
    var autoSave: Bool = false
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var textHeightAnchor: NSLayoutConstraint?
    var textBottomAnchor: NSLayoutConstraint?
    var imageHeightConstraint: NSLayoutConstraint?
    var textTopAnchor: NSLayoutConstraint?
    
    let leftRightInset: CGFloat = 20.0
    let topInset: CGFloat = 100.0
    let bottomInset: CGFloat = 50.0
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect.zero
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        return imageView
    }()
    lazy var qTextView: NFTextView = {
        let textView = NFTextView()
        textView.frame = CGRect.zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 100
        textView.textContainer.lineBreakMode = .ByWordWrapping

        return textView
    }()
    lazy var deleteImageButton: UIButton = {
        let imageButton = UIButton()
        imageButton.addTarget(self, action: #selector(AddCardsViewController.deleteImage(_:)), forControlEvents: .TouchUpInside)
        imageButton.setTitle("X", forState: .Normal)
        imageButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        imageButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageButton.titleLabel?.font = UIFont.boldSystemFontOfSize(50)
        
        return imageButton
    }()
    var fontSize: CGFloat {
        let fontSize = defaults.floatForKey("fontsize") ?? 17.0
        return CGFloat(fontSize)
    }
    
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var answerTextView: NFTextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var photoBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = deck?.title
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        autoSave = defaults.boolForKey("autosave") ?? false
        
        createViews()
        
        answerTextView.font = UIFont.systemFontOfSize(fontSize)
        qTextView.font = UIFont.systemFontOfSize(fontSize)

        answerTextView.placeholderText = "Enter answer here..."
        answerTextView.delegate = self
        answerTextView.hidden = true

        qTextView.placeholderText = "Enter question here..."
        qTextView.delegate = self
        qTextView.hidden = false
        
        switchButton.setTitle("Switch to Answer", forState: .Normal)
        
        subscribeToKeyboardNotifications()
        
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        if mode == .EditCard {
            qTextView.text = card?.question ?? ""
            qTextView.placeholderLabel.hidden = (qTextView.text == "") ? false : true
            
            answerTextView.text = card?.answer
            answerTextView.placeholderLabel.hidden = true
            
            if let imageURL = card?.imageURL {
                let imagePath = imageURL.createFilePath()
                if let data = NSData(contentsOfURL: NSURL(string: imagePath)!) {
                    imageAdded = true
                    photoImageView.image = UIImage(data: data)
                    photoImageView.userInteractionEnabled = true
                    deleteImageButton.frame.size = photoImageView.bounds.size
                    photoImageView.addSubview(deleteImageButton)
                    updateViews()
                }
            }
            else {
                updateViews()
            }
        }
        else {
            updateViews()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func updateViews() {
        let topInset = self.traitCollection.verticalSizeClass == .Compact ? topInsetForLandscape : self.topInset
        textTopAnchor?.constant = topInset
        
        if photoImageView.image != nil {
            let textViewHeight = qTextView.boundingHeight(inView: view, withPadding: fontSize)
            let imageH = view.frame.size.height - (topInset + textViewHeight + imageExtra)

            textHeightAnchor?.constant = textViewHeight
            textHeightAnchor?.active = true
            imageHeightConstraint?.constant = imageH
            imageHeightConstraint?.active = true
            textHeightAnchor?.active = true
            textBottomAnchor?.active = false
        } else {
            imageHeightConstraint?.active = false
            textBottomAnchor?.active = true
            textHeightAnchor?.active = false
        }

        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
    }
    
    func createViews() {
        
        view.addSubview(qTextView)
        view.addSubview(photoImageView)
        let topInset = self.traitCollection.verticalSizeClass == .Compact ? topInsetForLandscape : self.topInset
        textTopAnchor = qTextView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: topInset)
        textTopAnchor?.active = true
        
        qTextView.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: leftRightInset).active = true
        qTextView.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -leftRightInset).active = true
        
        textBottomAnchor = qTextView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -bottomInset)
        textHeightAnchor = qTextView.heightAnchor.constraintEqualToConstant(qTextView.contentSize.height + (fontSize + 10))
        
        imageHeightConstraint = photoImageView.heightAnchor.constraintEqualToConstant(0)
        
        photoImageView.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: leftRightInset).active = true
        photoImageView.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -leftRightInset).active = true
        photoImageView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -bottomInset).active = true
        
        createKeyboardDoneButton(qTextView)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        let boundingSize = CGSize(width: size.width - boundingRightLeftInset, height: CGFloat.max)
        let textViewHeight = qTextView.boundingHeight(boundingSize: boundingSize, withPadding: fontSize)
        let topInset = (size.width > size.height && self.traitCollection.userInterfaceIdiom != .Pad) ? topInsetForLandscape : self.topInset
        let imageH = size.height - (topInset + textViewHeight + imageExtra)
        self.imageHeightConstraint?.constant = imageH
        self.textHeightAnchor?.constant = textViewHeight
        self.textTopAnchor?.constant = topInset

        coordinator.animateAlongsideTransition({ (coordinator) in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func doneWithKeyboard() {
        if isQuestionShowing {
            qTextView.resignFirstResponder()
        } else {
            answerTextView.resignFirstResponder()
        }
    }
    
    func createKeyboardDoneButton(currentView: NFTextView) {
        let doneButtonView = UINavigationBar()
        doneButtonView.sizeToFit()
        doneButtonView.barTintColor = UIColor.lightGrayColor()
        doneButtonView.tintColor = UIColor.blackColor()
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doneWithKeyboard))
        doneButtonView.pushNavigationItem(navItem, animated: true)
        currentView.inputAccessoryView = doneButtonView
        currentView.becomeFirstResponder()
    }
    
    func keyboardWillShow() {
        toolBar.hidden = true
    }
    
    func keyboardWillHide() {
        toolBar.hidden = false
    }
    
    func backButtonTapped(sender: UIBarButtonItem) {
        if autoSave {
            if !wasCardSaved && doesCardContainText {
                saveCard()
            }
            self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            if splitViewController?.viewControllers.count > 1 {
                let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
                let navController = UINavigationController(rootViewController: detailViewController!)
                showDetailViewController(navController, sender: self)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            if !wasCardSaved && doesCardContainText {
                let alert = UIAlertController(title: "Caution", message: "Changes were made to your card. Do you want to save it?", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (action) -> Void in
                    if self.splitViewController?.viewControllers.count > 1 {
                        let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
                        let navController = UINavigationController(rootViewController: detailViewController!)
                        self.showDetailViewController(navController, sender: self)
                    } else {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                let saveAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                    self.saveCard()
                    self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
                    if self.splitViewController?.viewControllers.count > 1 {
                        let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
                        let navController = UINavigationController(rootViewController: detailViewController!)
                        self.showDetailViewController(navController, sender: self)
                    } else {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
                
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                presentViewController(alert, animated: true, completion: nil)
            } else {
                self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
                if splitViewController?.viewControllers.count > 1 {
                    let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("CardPageViewController") as? CardPageViewController
                    let navController = UINavigationController(rootViewController: detailViewController!)
                    showDetailViewController(navController, sender: self)
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    func deleteImage(sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Do you want to permanently delete this image from the card?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (action) -> Void in}
        let okAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            self.photoImageView.hidden = true
            self.photoImageView.image = nil
            self.imageAdded = false
            self.wasCardSaved = false
            self.updateViews()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    func textViewDidChange(textView: UITextView) {
        if let nfTextView = textView as? NFTextView {
            nfTextView.placeholderLabel.hidden = !nfTextView.text.isEmpty
            self.view.layoutIfNeeded()
            if imageHeightConstraint?.active ?? false {
                updateViews()
            }
        }
        wasCardSaved = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func deleteButton(sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Do you want to delete this card?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) { (action) -> Void in }
        let saveAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            let delCard = self.card
            StudyCardsDataStack.sharedInstance.deleteCardObject(delCard, deckObj: self.deck)
            self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        saveCard()
        let alert = UIAlertController(title: "Alert", message: "Your card has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: { () -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    @IBAction func addPhoto(sender: UIButton) {
        showPhotoMenu()
    }
    
    @IBAction func counterView(sender: AnyObject) {
        if (isQuestionShowing) {

            // hide Question - show Answer
            UIView.transitionFromView(qTextView,
                toView: answerTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                completion:nil)
            switchButton.setTitle("Switch to Question", forState: .Normal)
            photoImageView.hidden = true
            photoButton.hidden = true
            answerTextView.placeholderLabel.hidden = (answerTextView.text == "") ? false : true
            createKeyboardDoneButton(answerTextView)

        } else {

            // hide Answer - show Question
            UIView.transitionFromView(answerTextView,
                toView: qTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                completion: nil)
            switchButton.setTitle("Switch to Answer", forState: .Normal)
            photoImageView.hidden = photoImageView.image != nil ? false : true
            photoButton.hidden = false
            createKeyboardDoneButton(qTextView)
        }
        isQuestionShowing = !isQuestionShowing
    }
    
    func saveCard() {
        if mode == .AddCard {
            let imageURL = imageAdded ? ImportCards.saveImage(photoImageView.image) : nil
            let newCard = CardStruct(question: qTextView.text, answer: answerTextView.text, hidden: false, cardviewed: false, iscorrect: false, wronganswers: 0, ordinal: ordinal, imageURL: imageURL, deck: deck)
            card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
            mode = .EditCard
        } else if mode == .EditCard {
            if var updateCard = self.card?.asStruct() {
                updateCard.imageURL = imageAdded ? ImportCards.saveImage(photoImageView.image) : nil
                updateCard.question = qTextView.text
                updateCard.answer = answerTextView.text
                card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(updateCard, cardObj: self.card)
            }
        }
        wasCardSaved = true
    }
    
    func addTapped(sender: UIBarButtonItem) {
        if !wasCardSaved && doesCardContainText {
            saveCard()
            if self.splitViewController?.viewControllers.count > 1 {
                self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            }
        }
        mode = .AddCard
        card = nil
        qTextView.text = ""
        answerTextView.text = ""
        qTextView.placeholderLabel.hidden = false
        answerTextView.placeholderLabel.hidden = false
        photoImageView.hidden = true
        photoImageView.image = nil
        imageAdded = false
        if !isQuestionShowing {
            counterView(switchButton)
        }
        wasCardSaved = false
    }
}

extension AddCardsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .Popover
        imagePicker.popoverPresentationController?.sourceView = self.view
        imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Any
        imagePicker.popoverPresentationController?.barButtonItem = self.photoBarButtonItem
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.cameraCaptureMode = .Photo
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoImageView.image = image
        photoImageView.hidden = false
        imageAdded = true
        wasCardSaved = false
        picker.dismissViewControllerAnimated(true, completion: {(done) in
            self.updateViews()
        })
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showPhotoMenu() {
        
        let alertController = UIAlertController(title: "Add Photo", message: "Import Photo", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        if appDelegate.isCameraAvailable {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera() })
            alertController.addAction(takePhotoAction)
        }
        if appDelegate.isPhotoLibAvailable {
            let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary() })
            alertController.addAction(chooseFromLibraryAction)
        }

        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension UITextView {
    func boundingHeight(inView view: UIView, withPadding padding: CGFloat = 0) -> CGFloat {
        let string = self.text
        let boundingSize = CGSize(width: view.frame.width - 40, height: CGFloat.max)
        let textRect = string?.boundingRectWithSize(boundingSize, options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName: self.font!], context: nil)

        return (textRect?.height ?? self.font!.pointSize) + padding
    }

    func boundingHeight(boundingSize boundingSize: CGSize, withPadding padding: CGFloat = 0) -> CGFloat {
        let string = self.text
        let textRect = string?.boundingRectWithSize(boundingSize, options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName: self.font!], context: nil)

        return (textRect?.height ?? self.font!.pointSize) + padding
    }

}
