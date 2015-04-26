//
//  SettingsTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 17/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "More"
        tableView.bounces = false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell! = tableView.cellForRowAtIndexPath(indexPath)
    
        if cell != nil {

            var cellID: AnyObject! = cell.reuseIdentifier
            
            // The values are hardcoded so we can switch with confidence
            switch cellID as! String {
            case "LogoutCell":
                logout()
            default:
                println("un-managed action \(cellID.localizedDescription)")
            }
        }
    }
    
    // For segues which need to modify the window they are calling
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let id = segue.identifier! as String
        
    }
    
    // MARK: - Behavioural Functions
    
    // Log the user out
    func logout() {
        PFUser.logOut()
        let entry = UIStoryboard(name: "Main", bundle: nil)
        let home  = entry.instantiateViewControllerWithIdentifier("loginVC") as! PFLogInViewController
        
        self.navigationController?.pushViewController(home, animated: true)
    }

    
}
