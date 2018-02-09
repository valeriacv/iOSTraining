//
//  Functions.swift
//  MyLocations
//
//  Created by Vale Calderon  on 4/10/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds,execute: closure)
}

let applicationDocumentsDirectory: URL = {
    //How the book says it is
    //let paths = FileManager.default.urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
    
    //Correct way
    //path for the documents that has the data for my locations app.
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(
    rawValue: "MyManagedObjectContextSaveDidFailNotification")

//Error with core data saving an object
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    //Post a notification of type 'MyManagedObjectContextSaveDidFailNotification'
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}
