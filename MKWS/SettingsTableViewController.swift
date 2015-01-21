//
//  SettingsTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 17/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    
    var settingItems:[(name: String, image: UIImage?, action: String)] = []
    var settingSections = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"

        // Create all of the settings items
        settingItems.append(name: "Update Profile", image: UIImage(named: "editPencil"), action: "edit")
        settingItems.append(name: "Logout", image: UIImage(named: "securityLock"), action: "logout")
        
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settingSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as SettingsTableViewCell
        
        let item = settingItems[indexPath.row]

        // Configure the cell...
        cell.settingLbl.text  = item.name
        cell.settingImg.image = item.image
        
        //cell.imageView?.image = item.image
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = settingItems[indexPath.row]
        
        // Check which action we need to perform
        switch(cell.action)
        {
        case "logout":
            logout()
            break
        case "edit":
            editProfile()
            break
        default: break
        }
    }
    
    // MARK: - Behavioural Functions
    
    // Log the user out
    func logout() {
        PFUser.logOut()
        let entry = UIStoryboard(name: "Main", bundle: nil)
        let home  = entry.instantiateViewControllerWithIdentifier("loginVC") as PFLogInViewController
        
        self.navigationController?.pushViewController(home, animated: true)
    }
    
    // Edit user details
    func editProfile() {
        let entry = UIStoryboard(name: "Settings", bundle: nil)
        let edit  = entry.instantiateViewControllerWithIdentifier("editVC") as UpdateProfileTableViewController
        
        self.navigationController?.pushViewController(edit, animated: true)
    }


}
