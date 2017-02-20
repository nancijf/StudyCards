//
//  SettingsViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 9/13/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var fontSizeStepper: UIStepper!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var lockOrientation: UISwitch!
    @IBOutlet weak var autoSave: UISwitch!
    @IBOutlet weak var cardLines: UISwitch!
    @IBOutlet weak var shakeToShuffle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontSizeStepper.minimumValue = 10
        fontSizeStepper.autorepeat = true
    }
    
    override func viewWillAppear(animated: Bool) {
        var fontValue = 17
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            fontValue = defaults.integerForKey("fontsize") ?? 20
        } else {
            fontValue = defaults.integerForKey("fontsize") ?? 17
        }
        fontSizeLabel.text = String(fontValue)
        fontSizeStepper.value = Double(fontValue)

        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        let useLines = defaults.boolForKey("cardlines") ?? false
        let isLocked = defaults.boolForKey("locked") ?? false
        let isAutoSave = defaults.boolForKey("autosave") ?? false
        let isShuffleOn = defaults.boolForKey("shakeToShuffle") ?? false

        cardLines.setOn(useLines, animated: true)
        autoSave.setOn(isAutoSave, animated: true)
        lockOrientation.setOn(isLocked, animated: true)
        shakeToShuffle.setOn(isShuffleOn, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lockControl(sender: UISwitch) {
        defaults.setValue(lockOrientation.on, forKey: "locked")
    }
    
    @IBAction func autoSaveControl(sender: UISwitch) {
        defaults.setValue(autoSave.on, forKey: "autosave")
    }
    
    @IBAction func cardLinesOnOff(sender: UISwitch) {
        defaults.setValue(cardLines.on, forKey: "cardlines")
    }
    
    @IBAction func shuffleOnOff(sender: UISwitch) {
        defaults.setValue(shakeToShuffle.on, forKey: "shakeToShuffle")
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        fontSizeLabel.text = Int(fontSizeStepper.value).description
        fontSizeLabel.font = fontSizeLabel.font.fontWithSize(CGFloat(fontSizeStepper.value))
        defaults.setFloat(Float(fontSizeStepper.value), forKey: "fontsize")
    }
}
