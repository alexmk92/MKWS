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
    // BLUE BAR
    // ----------------------------------------------
    // Creates a blue navigation bar
    func blueBar()
    {
        self.barTintColor    = UIColor(red: 64/255, green: 117/255, blue: 224/255, alpha: 1)
        self.tintColor       = UIColor.whiteColor()
        self.barStyle        = UIBarStyle.Black
        self.backgroundColor = UIColor.blackColor()
        self.translucent     = false
    }
    // GRAY BAR
    // ----------------------------------------------
    // Creates a gray navigation bar
    func grayBar()
    {
        self.barTintColor    = UIColor(red: 27/255, green: 27/255, blue: 39/255, alpha: 1)
        self.tintColor       = UIColor.whiteColor()
        self.barStyle        = UIBarStyle.Black
        self.backgroundColor = UIColor.blackColor()
        self.translucent     = false
    }
    // CLEAR BLUE BAR
    // ----------------------------------------------
    // Creates a clear blue navigation bar for home
    func clearBlueBar()
    {
        self.barTintColor    = UIColor(red: 64/255, green: 117/255, blue: 224/255, alpha: 1)
        self.tintColor       = UIColor.whiteColor()
        self.barStyle        = UIBarStyle.Black
        self.backgroundColor = UIColor.blackColor()
        self.translucent     = true
    }
    // GRAY BAR
    // ----------------------------------------------
    // Creates a gray navigation bar
    func clearGrayBar()
    {
        self.barTintColor    = UIColor(red: 27/255, green: 27/255, blue: 39/255, alpha: 1)
        self.tintColor       = UIColor.whiteColor()
        self.barStyle        = UIBarStyle.Black
        self.backgroundColor = UIColor.blackColor()
        self.translucent     = true
    }
}