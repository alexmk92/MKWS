//
//  TimelineTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 17/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController {

    // Dictionary to determine whether or not the cell has been animated into view
    var didAnimateCell:[NSIndexPath : Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        
        let p = UserPermission.sharedInstance.getPermission()
        if p == Permission.GUEST {
            println("Yep")
        } else {
            println("hi")
        }
    }
    
    // Reset the settings which are applied on a logout
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        self.navigationItem.setHidesBackButton(false, animated: false)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CardCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = "testCell"
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if didAnimateCell[indexPath] == nil || didAnimateCell[indexPath] == false {
            didAnimateCell[indexPath] = true
            CellAnimator.animateCardIn(cell)
        }
    }
    




}
