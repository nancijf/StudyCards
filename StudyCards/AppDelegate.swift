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
    let defaults = UserDefaults.standard
    var isCameraAvailable: Bool = false
    var isPhotoLibAvailable: Bool = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if defaults.value(forKey: "locked") == nil {
            defaults.set(false, forKey: "locked")
        }
        if defaults.value(forKey: "autosave") == nil {
            defaults.set(false, forKey: "autosave")
        }
        if defaults.value(forKey: "cardlines") == nil {
            defaults.set(false, forKey: "cardlines")
        }
        if defaults.value(forKey: "fontsize") == nil {
            if UIDevice.current.userInterfaceIdiom == .pad {
                defaults.set(20.0, forKey: "fontsize")
            } else {
                defaults.set(17.0, forKey: "fontsize")
            }
        }
        if defaults.value(forKey: "shakeToShuffle") == nil {
            defaults.setValue(false, forKey: "shakeToShuffle")
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            switch cameraStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                    if granted {
                        self.isCameraAvailable = true
                    }
                }
            case .authorized:
                self.isCameraAvailable = true
            default:
                break
            }
        }
        
        let plStatus = PHPhotoLibrary.authorizationStatus()
        switch plStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    self.isPhotoLibAvailable = true
                default:
                    break
                }
            })
        case .authorized:
            self.isPhotoLibAvailable = true
        default:
            break
        }

        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        // pass managedObjectContext to StudyCardsDataStack CoreData abstraction layer
        StudyCardsDataStack.sharedInstance.managedObjectContext = self.managedObjectContext

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topDetail1 = secondaryAsNavController.topViewController as? CardPageViewController else { return false }
//        guard let topDetail2 = secondaryAsNavController.topViewController as? CardListTableViewController else { return false }
        if topDetail1.deck == nil && topDetail1.tempCards == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
        
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.nancifrank.studydex" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: "StudyCards", withExtension: "momd") else {
            fatalError("Could not find data model in app bunlde")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        return model
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("StudyCards.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

