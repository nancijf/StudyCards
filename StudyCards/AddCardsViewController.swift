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


let imageExtra: CGFloat = 70.0
let topInsetForLandscape: CGFloat = 60.0
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let boundingRightLeftInset: CGFloat = 50.0

protocol AddCardsViewControllerDelegate: class {
    func addCardsViewControllerDidFinishAddingCards(_ viewController: AddCardsViewController, addedCards: NSMutableOrderedSet?)
}

enum AddCardViewControllerMode: Int {
    case addCard = 0
    case editCard
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
    let defaults = UserDefaults.standard
    
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
        imageView.contentMode = UIViewContentMode.scaleAspectFit

        return imageView
    }()
    lazy var qTextView: NFTextView = {
        let textView = NFTextView()
        textView.frame = CGRect.zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 100
        textView.textContainer.lineBreakMode = .byWordWrapping

        return textView
    }()
    lazy var deleteImageButton: UIButton = {
        let imageButton = UIButton()
        imageButton.addTarget(self, action: #selector(AddCardsViewController.deleteImage(_:)), for: .touchUpInside)
        imageButton.setTitle("X", for: UIControlState())
        imageButton.setTitleColor(UIColor.red, for: UIControlState())
        imageButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        
        return imageButton
    }()
    var fontSize: CGFloat {
        let fontSize = defaults.float(forKey: "fontsize") ?? 17.0
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
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        autoSave = defaults.bool(forKey: "autosave") ?? false
        
        createViews()
        
        answerTextView.font = UIFont.systemFont(ofSize: fontSize)
        qTextView.font = UIFont.systemFont(ofSize: fontSize)

        answerTextView.placeholderText = "Enter answer here..."
        answerTextView.delegate = self
        answerTextView.isHidden = true

        qTextView.placeholderText = "Enter question here..."
        qTextView.delegate = self
        qTextView.isHidden = false
        
        switchButton.setTitle("Switch to Answer", for: UIControlState())
        
        subscribeToKeyboardNotifications()
        
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        if mode == .editCard {
            qTextView.text = card?.question ?? ""
            qTextView.placeholderLabel.isHidden = (qTextView.text == "") ? false : true
            
            answerTextView.text = card?.answer
            answerTextView.placeholderLabel.isHidden = true
            
            if let imageURL = card?.imageURL {
                let imagePath = imageURL.createFilePath()
                if let data = try? Data(contentsOf: URL(string: imagePath)!) {
                    imageAdded = true
                    photoImageView.image = UIImage(data: data)
                    photoImageView.isUserInteractionEnabled = true
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }

    func updateViews() {
        let topInset = self.traitCollection.verticalSizeClass == .compact ? topInsetForLandscape : self.topInset
        textTopAnchor?.constant = topInset
        
        if photoImageView.image != nil {
            let textViewHeight = qTextView.boundingHeight(inView: view, withPadding: fontSize)
            let imageH = view.frame.size.height - (topInset + textViewHeight + imageExtra)

            textHeightAnchor?.constant = textViewHeight
            textHeightAnchor?.isActive = true
            imageHeightConstraint?.constant = imageH
            imageHeightConstraint?.isActive = true
            textHeightAnchor?.isActive = true
            textBottomAnchor?.isActive = false
        } else {
            imageHeightConstraint?.isActive = false
            textBottomAnchor?.isActive = true
            textHeightAnchor?.isActive = false
        }

        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
    }
    
    func createViews() {
        
        view.addSubview(qTextView)
        view.addSubview(photoImageView)
        let topInset = self.traitCollection.verticalSizeClass == .compact ? topInsetForLandscape : self.topInset
        textTopAnchor = qTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset)
        textTopAnchor?.isActive = true
        
        qTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftRightInset).isActive = true
        qTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -leftRightInset).isActive = true
        
        textBottomAnchor = qTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomInset)
        textHeightAnchor = qTextView.heightAnchor.constraint(equalToConstant: qTextView.contentSize.height + (fontSize + 10))
        
        imageHeightConstraint = photoImageView.heightAnchor.constraint(equalToConstant: 0)
        
        photoImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftRightInset).isActive = true
        photoImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -leftRightInset).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomInset).isActive = true
        
        createKeyboardDoneButton(qTextView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let boundingSize = CGSize(width: size.width - boundingRightLeftInset, height: CGFloat.greatestFiniteMagnitude)
        let textViewHeight = qTextView.boundingHeight(boundingSize: boundingSize, withPadding: fontSize)
        let topInset = (size.width > size.height && self.traitCollection.userInterfaceIdiom != .pad) ? topInsetForLandscape : self.topInset
        let imageH = size.height - (topInset + textViewHeight + imageExtra)
        self.imageHeightConstraint?.constant = imageH
        self.textHeightAnchor?.constant = textViewHeight
        self.textTopAnchor?.constant = topInset

        coordinator.animate(alongsideTransition: { (coordinator) in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func doneWithKeyboard() {
        if isQuestionShowing {
            qTextView.resignFirstResponder()
        } else {
            answerTextView.resignFirstResponder()
        }
    }
    
    func createKeyboardDoneButton(_ currentView: NFTextView) {
        let doneButtonView = UINavigationBar()
        doneButtonView.sizeToFit()
        doneButtonView.barTintColor = UIColor.lightGray
        doneButtonView.tintColor = UIColor.black
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneWithKeyboard))
        doneButtonView.pushItem(navItem, animated: true)
        currentView.inputAccessoryView = doneButtonView
        currentView.becomeFirstResponder()
    }
    
    func keyboardWillShow() {
        toolBar.isHidden = true
    }
    
    func keyboardWillHide() {
        toolBar.isHidden = false
    }
    
    func backButtonTapped(_ sender: UIBarButtonItem) {
        if autoSave {
            if !wasCardSaved && doesCardContainText {
                saveCard()
            }
            self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            self.navigationController?.popViewController(animated: true)
        } else {
            if !wasCardSaved && doesCardContainText {
                let alert = UIAlertController(title: "Caution", message: "Changes were made to your card. Do you want to save it?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action) -> Void in
                    self.navigationController?.popViewController(animated: true)
                }
                let saveAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                    self.saveCard()
                    self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            } else {
                self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func deleteImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Do you want to permanently delete this image from the card?", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action) -> Void in}
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.photoImageView.isHidden = true
            self.photoImageView.image = nil
            self.imageAdded = false
            self.wasCardSaved = false
            self.updateViews()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func textViewDidChange(_ textView: UITextView) {
        if let nfTextView = textView as? NFTextView {
            nfTextView.placeholderLabel.isHidden = !nfTextView.text.isEmpty
            self.view.layoutIfNeeded()
            if imageHeightConstraint?.isActive ?? false {
                updateViews()
            }
        }
        wasCardSaved = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func deleteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Do you want to delete this card?", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action) -> Void in }
        let saveAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            let delCard = self.card
            StudyCardsDataStack.sharedInstance.deleteCardObject(delCard, deckObj: self.deck)
            self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        saveCard()
        let alert = UIAlertController(title: "Alert", message: "Your card has been saved.", preferredStyle: UIAlertControllerStyle.alert)
        present(alert, animated: true, completion: { () -> Void in
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                alert.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        showPhotoMenu()
    }
    
    @IBAction func counterView(_ sender: AnyObject) {
        if (isQuestionShowing) {

            // hide Question - show Answer
            UIView.transition(from: qTextView,
                to: answerTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.transitionFlipFromLeft, UIViewAnimationOptions.showHideTransitionViews],
                completion:nil)
            switchButton.setTitle("Switch to Question", for: UIControlState())
            photoImageView.isHidden = true
            photoButton.isHidden = true
            answerTextView.placeholderLabel.isHidden = (answerTextView.text == "") ? false : true
            createKeyboardDoneButton(answerTextView)

        } else {

            // hide Answer - show Question
            UIView.transition(from: answerTextView,
                to: qTextView,
                duration: 1.0,
                options: [UIViewAnimationOptions.transitionFlipFromRight, UIViewAnimationOptions.showHideTransitionViews],
                completion: nil)
            switchButton.setTitle("Switch to Answer", for: UIControlState())
            photoImageView.isHidden = photoImageView.image != nil ? false : true
            photoButton.isHidden = false
            createKeyboardDoneButton(qTextView)
        }
        isQuestionShowing = !isQuestionShowing
    }
    
    func saveCard() {
        if mode == .addCard {
            let imageURL = imageAdded ? ImportCards.saveImage(photoImageView.image) : nil
            let newCard = CardStruct(question: qTextView.text, answer: answerTextView.text, hidden: false, cardviewed: false, iscorrect: false, wronganswers: 0, ordinal: ordinal, imageURL: imageURL, deck: deck)
            card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(newCard)
            mode = .editCard
        } else if mode == .editCard {
            if var updateCard = self.card?.asStruct() {
                updateCard.imageURL = imageAdded ? ImportCards.saveImage(photoImageView.image) : nil
                updateCard.question = qTextView.text
                updateCard.answer = answerTextView.text
                card = StudyCardsDataStack.sharedInstance.addOrEditCardObject(updateCard, cardObj: self.card)
            }
        }
        wasCardSaved = true
    }
    
    func addTapped(_ sender: UIBarButtonItem) {
        if !wasCardSaved && doesCardContainText {
            saveCard()
            if self.splitViewController?.viewControllers.count > 1 {
                self.delegate?.addCardsViewControllerDidFinishAddingCards(self, addedCards: self.addedCards)
            }
        }
        mode = .addCard
        card = nil
        qTextView.text = ""
        answerTextView.text = ""
        qTextView.placeholderLabel.isHidden = false
        answerTextView.placeholderLabel.isHidden = false
        photoImageView.isHidden = true
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
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = self.view
        imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        imagePicker.popoverPresentationController?.barButtonItem = self.photoBarButtonItem
        present(imagePicker, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoImageView.image = image
        photoImageView.isHidden = false
        imageAdded = true
        wasCardSaved = false
        picker.dismiss(animated: true, completion: {(done) in
            self.updateViews()
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showPhotoMenu() {
        
        let alertController = UIAlertController(title: "Add Photo", message: "Import Photo", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if appDelegate.isCameraAvailable {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
            alertController.addAction(takePhotoAction)
        }
        if appDelegate.isPhotoLibAvailable {
            let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
            alertController.addAction(chooseFromLibraryAction)
        }

        present(alertController, animated: true, completion: nil)
    }
}

extension UITextView {
    func boundingHeight(inView view: UIView, withPadding padding: CGFloat = 0) -> CGFloat {
        let string = self.text
        let boundingSize = CGSize(width: view.frame.width - 40, height: CGFloat.greatestFiniteMagnitude)
        let textRect = string?.boundingRect(with: boundingSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: self.font!], context: nil)

        return (textRect?.height ?? self.font!.pointSize) + padding
    }

    func boundingHeight(boundingSize: CGSize, withPadding padding: CGFloat = 0) -> CGFloat {
        let string = self.text
        let textRect = string?.boundingRect(with: boundingSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: self.font!], context: nil)

        return (textRect?.height ?? self.font!.pointSize) + padding
    }

}
