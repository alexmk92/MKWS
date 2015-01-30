//
//  RecipientsController.swift
//  MKWS
//
//  Created by Alex Sims on 30/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class RecipientsController: UITableViewController {

    @IBOutlet weak var btnDismiss: UIBarButtonItem!
    @IBOutlet weak var btnDone   : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    @IBAction func DismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func updateRecipients(sender: AnyObject) {
        DismissView(self)
    }
}
