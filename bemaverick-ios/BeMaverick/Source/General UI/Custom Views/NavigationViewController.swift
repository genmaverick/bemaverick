//
//  NavigationViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 4/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = UIColor.MaverickPrimaryColor
        navigationBar.barTintColor = .white
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
    }

    
    // MARK: - Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}
