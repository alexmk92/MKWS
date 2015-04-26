//
//  UINavigationBar.swift
//  MKWS
//
//  Created by Alex Sims on 21/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

extension UINavigationBar
{
    // CLEAR BAR
    // ----------------------------------------------
    // Sets the navigation bar to be completely clear
    func clearBar()
    {
        self.barTintColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
        self.translucent = true
        self.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.shadowImage = UIImage()
    }
}