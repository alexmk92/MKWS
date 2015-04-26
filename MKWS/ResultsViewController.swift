//
//  ResultsViewController.swift
//  MKWS
//
//  Created by Alex Sims on 26/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class ResultsViewController: UITableViewController {

    var opponents = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return opponents.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("challengerCell", forIndexPath: indexPath) as? ChallengerCell
        {
            // Configure the cell...
            
            if let user = opponents[indexPath.row] as User!
            {
                // Set the cell information
                cell.lblName.text    = user.getFullname()
                cell.imgAvatar.image = user.getAvatar()
                cell.lblStats.text   = "\(user.getWins()) Wins, \(user.getLosses()) Losses"
            }
            
            return cell
        }

        return UITableViewCell()
    }
}
