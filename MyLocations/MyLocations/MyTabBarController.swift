//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Vale Calderon  on 4/17/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//


import UIKit
class MyTabBarController: UITabBarController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
