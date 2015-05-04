//
//  BasePanelTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 15/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

protocol BasePanelTableViewControllerDelegate {
    func basePanelDidSelectRow(indexPath:NSIndexPath)
}

class BasePanelTableViewController: UITableViewController {

    var delegate:BasePanelTableViewControllerDelegate?
    var tableData:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell

        // This will only be done once per row.
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            
            // Configure cell
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.whiteColor()
            
            // Set the selected effect
            let selectedView:UIView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
            
            cell!.selectedBackgroundView = selectedView
        }
        
        
        cell!.textLabel!.text = tableData[indexPath.row]

        return cell!
    }
    
    // Set the delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.basePanelDidSelectRow(indexPath)
    }

}
