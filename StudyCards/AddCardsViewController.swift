//
//  CardsViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 3/14/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import Photos

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
            return !questionTextView.text.isEmpty || !answerTextView.text.isEmpty
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
    let photoImageView = UIImageView()
    let qTextView = NFTextView()
    
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var answerTextView: NFTextView!
    @IBOutlet weak var questionTextView: NFTextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var photoBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = deck?.title
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        let fontSize = defaults.stringForKey("fontsize") ?? "17"
        if let fontValue = Double(fontSize) {
            answerTextView.font = answerTextView.font?.fontWithSize(CGFloat(fontValue))
            questionTextView.font = questionTextView.font?.fontWithSize(CGFloat(fontValue))
        }
        autoSave = defaults.boolForKey("autosave") ?? false
        
//        questionTextView.placeholderText = "Enter question here..."
        answerTextView.placeholderText = "Enter answer here..."
//        questionTextView.delegate = self
        answerTextView.delegate = self
//        imageView.hidden = true
        switchButton.setTitle("Switch to Answer", forState: .Normal)
        answerTextView.hidden = true
        questionTextView.hidden = true
        createViews()
        
        subscribeToKeyboardNotifications()
//        createKeyboardDoneButton(questionTextView)
        
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        if mode == .EditCard {
            if let imageURL = card?.imageURL {
                var imagePath = imageURL
                if !imageURL.containsString("://") {
                    imagePath = "file://" + createFilePath(withFileName: imageURL)
                }
                if let data = NSData(contentsOfURL: NSURL(string: imagePath)!) {
                    imageAdded = true
//                    imageView.hidden = false
                    photoImageView.image = UIImage(data: data)
                    photoImageView.userInteractionEnabled = true
                    let deleteImageButton = UIButton(frame: photoImageView.bounds)
                    deleteImageButton.addTarget(self, action: #selector(AddCardsViewController.deleteImage(_:)), forControlEvents: .TouchUpInside)
                    deleteImageButton.setTitle("X", forState: .Normal)
                    deleteImageButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                    deleteImageButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                    deleteImageButton.titleLabel?.font = UIFont.boldSystemFontOfSize(50)
                    photoImageView.addSubview(deleteImageButton)
                }
            }
            
            qTextView.text = card?.question
            answerTextView.text = card?.answer
            questionTextView.placeholderLabel.hidden = true
            answerTextView.placeholderLabel.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func createViews() {
        photoImageView.frame = CGRect.zero
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        photoImageView.sizeToFit()

        self.view.addSubview(photoImageView)
        qTextView.frame = CGRect.zero
        qTextView.translatesAutoresizingMaskIntoConstraints = false
        qTextView.placeholderText = "Enter question here..."
        qTextView.font = UIFont.systemFontOfSize(22)
        qTextView.sizeToFit()
        
        qTextView.delegate = self
        self.view.addSubview(qTextView)
        qTextView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        qTextView.leftAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leftAnchor).active = true
        qTextView.rightAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.rightAnchor).active = true
        qTextView.heightAnchor.constraintGreaterThanOrEqualToConstant(100).active = true
        
        photoImageView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: -50).active = true
        photoImageView.topAnchor.constraintEqualToAnchor(qTextView.bottomAnchor).active = true
        photoImageView.leftAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leftAnchor).active = true
        photoImageView.rightAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.rightAnchor).active = true
        photoImageView.heightAnchor.constraintGreaterThanOrEqualToConstant(200).active = true
        self.updateViewConstraints()
        createKeyboardDoneButton(qTextView)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func doneWithKeyboard() {
        if isQuestionShowing {
//            questionTextView.resignFirstResponder()
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
            if !wasCardSaved {
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
            if !wasCardSaved {
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
            self.imageView.hidden = true
            self.imageAdded = false
            self.wasCardSaved = false
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        if let nfTextView = textView as? NFTextView {
            nfTextView.placeholderLabel.hidden = !nfTextView.text.isEmpty
        }
        wasCardSaved = false
    }
    
    func createFilePath(withFileName fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docs: String = paths[0]
        let fullPath = docs + "/" + fileName
        
        return fullPath
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
            imageView.hidden = true
            UIView.transitionFromView(questionTextView,
                toView: answerTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews],
                completion:nil)
            switchButton.setTitle("Switch to Question", forState: .Normal)
            photoButton.hidden = true
            createKeyboardDoneButton(answerTextView)

        } else {

            // hide Answer - show Question
            if imageAdded {
                imageView.hidden = false
            }
            UIView.transitionFromView(answerTextView,
                toView: questionTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews],
                completion: nil)
            switchButton.setTitle("Switch to Answer", forState: .Normal)
            photoButton.hidden = false
            createKeyboardDoneButton(questionTextView)
        }
        isQuestionShowing = !isQuestionShowing
    }
    
    func saveCard() {
        if mode == .AddCard {
            let imageURL = imageAdded ? ImportCards.saveImage(imageView.image) : nil
            let newCard = CardStruct(question: questionTextView.text, answer: answerTextView.text, hidden: false, cardviewed: false, iscorrect: false, wronganswers: 0, ordinal: ordinal, imageURL: imageURL, deck: deck)
            card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
            mode = .EditCard
        } else if mode == .EditCard {
            if var updateCard = self.card?.asStruct() {
                updateCard.imageURL = imageAdded ? ImportCards.saveImage(imageView.image) : nil
                updateCard.question = questionTextView.text
                updateCard.answer = answerTextView.text
                card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(updateCard, cardObj: self.card)
            }
        }
        wasCardSaved = true
    }
    
    func addTapped(sender: UIBarButtonItem) {
        if !wasCardSaved && doesCardContainText {
            saveCard()
        }
        mode = .AddCard
        card = nil
        questionTextView.text = ""
        answerTextView.text = ""
        questionTextView.placeholderLabel.hidden = false
        answerTextView.placeholderLabel.hidden = false
        imageView.hidden = true
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
//        imageView.image = image
//        imageView.hidden = false
        photoImageView.image = image
        imageAdded = true
        wasCardSaved = false
        self.updateViewConstraints()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showPhotoMenu() {
        var canUseCamera: Bool = false
        var canUsePhotoLibrary: Bool = false
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            switch cameraStatus {
            case .Authorized:
                canUseCamera = true
            default:
                break
            }
        }
        
        let plStatus = PHPhotoLibrary.authorizationStatus()
        switch plStatus {
        case .Authorized:
            canUsePhotoLibrary = true
        default:
            break
        }
        
        let alertController = UIAlertController(title: "Add Photo", message: "Import Photo", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        if canUseCamera {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera() })
            alertController.addAction(takePhotoAction)
        }
        if canUsePhotoLibrary {
            let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary() })
            alertController.addAction(chooseFromLibraryAction)
        }

        presentViewController(alertController, animated: true, completion: nil)
    }
}
