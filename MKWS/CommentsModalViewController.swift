//
//  CommentsModalView.swift
//  MKWS
//
//  Created by Alex Sims on 29/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

// Delegate from TableView so we can replicate the functionality of UITableViewControllers
class CommentsModalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Outlet connections
    @IBOutlet weak var btnCloseModal: UIButton!
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var lblCharactersLeft: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // Outlet actions
    @IBAction func DismissModal(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func PostComment(sender: AnyObject) {
    }
}
