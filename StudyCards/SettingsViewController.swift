//
//  SettingsViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 9/13/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let defaults = UserDefaults.standard

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
    
    override func viewWillAppear(_ animated: Bool) {
        var fontValue = 17
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontValue = defaults.integer(forKey: "fontsize") ?? 20
        } else {
            fontValue = defaults.integer(forKey: "fontsize") ?? 17
        }
        fontSizeLabel.text = String(fontValue)
        fontSizeStepper.value = Double(fontValue)

        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        let useLines = defaults.bool(forKey: "cardlines") ?? false
        let isLocked = defaults.bool(forKey: "locked") ?? false
        let isAutoSave = defaults.bool(forKey: "autosave") ?? false
        let isShuffleOn = defaults.bool(forKey: "shakeToShuffle") ?? false

        cardLines.setOn(useLines, animated: true)
        autoSave.setOn(isAutoSave, animated: true)
        lockOrientation.setOn(isLocked, animated: true)
        shakeToShuffle.setOn(isShuffleOn, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lockControl(_ sender: UISwitch) {
        defaults.setValue(lockOrientation.isOn, forKey: "locked")
    }
    
    @IBAction func autoSaveControl(_ sender: UISwitch) {
        defaults.setValue(autoSave.isOn, forKey: "autosave")
    }
    
    @IBAction func cardLinesOnOff(_ sender: UISwitch) {
        defaults.setValue(cardLines.isOn, forKey: "cardlines")
    }
    
    @IBAction func shuffleOnOff(_ sender: UISwitch) {
        defaults.setValue(shakeToShuffle.isOn, forKey: "shakeToShuffle")
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        fontSizeLabel.text = Int(fontSizeStepper.value).description
        fontSizeLabel.font = fontSizeLabel.font.withSize(CGFloat(fontSizeStepper.value))
        defaults.set(Float(fontSizeStepper.value), forKey: "fontsize")
    }
}
