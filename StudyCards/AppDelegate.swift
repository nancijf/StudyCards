//
//  AppDelegate.swift
//  StudyCards
//
//  Created by Nanci Frank on 2/20/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit
import CoreData
import Photos
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()
    var isCameraAvailable: Bool = false
    var isPhotoLibAvailable: Bool = false


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if defaults.valueForKey("locked") == nil {
            defaults.setBool(false, forKey: "locked")
        }
        if defaults.valueForKey("autosave") == nil {
            defaults.setBool(false, forKey: "autosave")
        }
        if defaults.valueForKey("cardlines") == nil {
            defaults.setBool(true, forKey: "cardlines")
        }
        if defaults.valueForKey("fontsize") == nil {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                defaults.setFloat(20.0, forKey: "fontsize")
            } else {
                defaults.setFloat(17.0, forKey: "fontsize")
            }
        }
        if defaults.valueForKey("shakeToShuffle") == nil {
            defaults.setValue(false, forKey: "shakeToShuffle")
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            switch cameraStatus {
            case .NotDetermined:
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                    if granted {
                        self.isCameraAvailable = true
                    }
                }
            case .Authorized:
                self.isCameraAvailable = true
            default:
                break
            }
        }
        
        let plStatus = PHPhotoLibrary.authorizationStatus()
        switch plStatus {
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .Authorized:
                    self.isPhotoLibAvailable = true
                default:
                    break
                }
            })
        case .Authorized:
            self.isPhotoLibAvailable = true
        default:
            break
        }

        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        // pass managedObjectContext to StudyCardsDataStack CoreData abstraction layer
        StudyCardsDataStack.sharedInstance.managedObjectContext = self.managedObjectContext

        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        self.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? CardPageViewController else { return false }
        if topAsDetailController.deck == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
        
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.nancifrank.studydex" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = NSBundle.mainBundle().URLForResource("StudyCards", withExtension: "momd") else {
            fatalError("Could not find data model in app bunlde")
        }
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        return model
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("StudyCards.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

