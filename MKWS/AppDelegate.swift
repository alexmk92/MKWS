//
//  AppDelegate.swift
//  MKWS
//
//  Created by Alex Sims on 16/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var requestObject: PFObject?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Connect to Parse and enable local datastore to persist objects (like core data)
        Parse.enableLocalDatastore()
        Parse.setApplicationId("nBfoO3x32mLzU6LBwtWYf64Aa4fBkNNItgJXNTXO", clientKey: "kkfQBfWtabKXxpMkO0EF3ZK3gjXzVUlT9AAavpiG")
        
        // Register for remote notifications
        let notificationTypes    = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        // Set up the tab bar controller
        let chatSB  = UIStoryboard(name: "Chat"    , bundle: nil)
        let mainSB  = UIStoryboard(name: "Main"    , bundle: nil)
        let settSB  = UIStoryboard(name: "Settings", bundle: nil)
        let gamesSB = UIStoryboard(name: "Game"    , bundle: nil)
        let eventSB = UIStoryboard(name: "Events"  , bundle: nil)
        
        let tabBarController = UITabBarController()
        
        let homeNC  = mainSB.instantiateViewControllerWithIdentifier("profileNC")    as! UINavigationController?
        let chatNC  = chatSB.instantiateViewControllerWithIdentifier("chatInboxNC")  as! UINavigationController?
        let settNC  = settSB.instantiateViewControllerWithIdentifier("settingsNC")   as! UINavigationController?
        let gamesNC = gamesSB.instantiateViewControllerWithIdentifier("gamesNC")     as! UINavigationController?
        let eventNC = eventSB.instantiateViewControllerWithIdentifier("eventsNC")    as! UINavigationController?
                
        // Configure tab details
        homeNC!.tabBarItem  = UITabBarItem(title: "Home"    ,  image: UIImage(named: "home")    , tag: 1)
        chatNC!.tabBarItem  = UITabBarItem(title: "Messages",  image: UIImage(named: "messages"), tag: 2)
        gamesNC!.tabBarItem = UITabBarItem(title: "Challenge", image: UIImage(named: "game")    , tag: 3)
        eventNC!.tabBarItem = UITabBarItem(title: "Calendar",  image: UIImage(named: "calendar"), tag: 4)
        settNC!.tabBarItem  = UITabBarItem(title: "More"    ,  image: UIImage(named: "menu")    , tag: 5)
        
        tabBarController.viewControllers = [homeNC!, chatNC!, gamesNC!, eventNC!, settNC!]
        window?.rootViewController       = tabBarController
        
        tabBarController.selectedIndex = 0
        
        // Set nav bar style
        var navigationAppearance          = UINavigationBar.appearance()
        navigationAppearance.barTintColor = UIColor(red: 64/255, green: 117/255, blue: 224/255, alpha: 1)
        navigationAppearance.tintColor    = UIColor.whiteColor()
        navigationAppearance.barStyle     = UIBarStyle.Black
        
        var tabBarAppearance             = UITabBar.appearance()
        tabBarAppearance.barTintColor    = UIColor(red: 22/255, green: 22/255, blue: 34/255, alpha: 1)
        tabBarAppearance.tintColor       = UIColor.whiteColor()
        tabBarAppearance.translucent     = false
        
        return true
    }
    
    // Callback for registering for notifications
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    // This should never happen - but catch it if it does (this will also be printed in the simulator as it is not supported)
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error.localizedDescription)
    }
    
    // Registers the device with parse so it  can be unique identified for push notification
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock(nil)
    }
    
    // Whenever we recieve a notification, post the reloadMessages command to the current VC.
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        AudioServicesPlayAlertSound(1110)
        
        // Notify the observer with the payload information - calls displayMessage in observer VC
        NSNotificationCenter.defaultCenter().postNotificationName("displayMessage", object: userInfo)
        
        // Call reloadMessages in the observer VC
        NSNotificationCenter.defaultCenter().postNotificationName("reloadMessages", object: nil)
        
        // Call reloadNotifications in the events VC
        NSNotificationCenter.defaultCenter().postNotificationName("reloadEvents", object: nil)
        
    }
    
 
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    // We can assume the user has seen all of their messages once opening the app - reset the notification badge to 0
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.simtech.MKWS" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("MKWS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("MKWS.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

