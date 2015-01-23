//
//  AccordionTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 23/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class AccordionTableViewController: UITableViewController {

    var expandedSection = NSMutableIndexSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Callback to check whether the table section can be collapsed
    func tableView(tableView: UITableView, canCollapseSection section: Int) -> Bool {
        if section > 0 {
            return true
        }
        return false
    }

    // 
    
}
