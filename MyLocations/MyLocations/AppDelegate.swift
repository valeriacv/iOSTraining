//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Vale Calderon  on 4/4/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    //Load the data model, conection with SQLite, is a container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    //Gets the context of the managed object
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext



    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey:Any]?) -> Bool {
            customizeAppearance()
            let tabBarController = window!.rootViewController
                as! UITabBarController
            if let tabBarViewControllers = tabBarController.viewControllers {
                let currentLocationViewController = tabBarViewControllers[0]
                    as! CurrentLocationViewController
                currentLocationViewController.managedObjectContext = managedObjectContext
                
                let navigationController = tabBarViewControllers[1] as! UINavigationController
                
                let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
                
                locationsViewController.managedObjectContext = managedObjectContext
                
                let mapViewController = tabBarViewControllers[2] as! MapViewController
                mapViewController.managedObjectContext = managedObjectContext
            }
            print(applicationDocumentsDirectory)
            listenForFatalCoreDataNotifications()
            return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func listenForFatalCoreDataNotifications() {
        // Tells the notification center that it wants to be notify when there is a notification of type MyManagedObjectContextSaveDidFailNotification
        NotificationCenter.default.addObserver(
            forName: MyManagedObjectContextSaveDidFailNotification,
            object: nil, queue: OperationQueue.main, using: { notification in
                //Closure that is executed when there is a notification of the specify type.
                //Shows an error message
                let alert = UIAlertController(
                    title: "Internal Error",
                    message:
                    "There was a fatal error in the app and it cannot continue.\n\n"
                        + "Press OK to terminate the app. Sorry for the inconvenience.",
                    preferredStyle: .alert)
                //Sets an action for the ok button
                //Actions terminates the app
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    let exception = NSException(
                        name: NSExceptionName.internalInconsistencyException,
                        reason: "Fatal Core Data error", userInfo: nil)
                    exception.raise()
                }
                alert.addAction(action)
                //Show the alert
                self.viewControllerForShowingAlert().present(alert, animated: true,completion: nil)
        })
    }
    
    //Gets the view contoller that is currently visible to show the alert
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white ]
        UITabBar.appearance().barTintColor = UIColor.black
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }

    
}

