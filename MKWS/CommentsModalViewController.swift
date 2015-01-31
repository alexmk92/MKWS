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
    @IBOutlet weak var btnCloseModal     : UIButton!
    @IBOutlet weak var txtComment        : UITextField!
    @IBOutlet weak var btnComment        : UIButton!
    @IBOutlet weak var lblPostTitle      : UILabel!
    @IBOutlet weak var lblCharactersLeft : UILabel!
    
    private var comments = [Comment]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell with this comment
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as CommentCell
        let comment = comments[indexPath.row]
        
        // Check we have a valid post object
        if comment.getPost() != nil && comment.getUser() != nil {
            
            // Get the user and post objects to configure the cell
            let user    = comment.getUser()!
            let post    = comment.getPost()!
        
            // We know this will return the default image if an avatar isnt set
            cell.imgAvatar.image = user.getAvatar()!
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // Safe return for the comment field
    func getCommentContent()-> String! {
        if txtComment.text != nil || countElements(txtComment.text) > 0 || txtComment.text != "" {
            return txtComment.text!
        }
        return ""
    }
    
    // Outlet actions
    @IBAction func DismissModal(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func PostComment(sender: AnyObject) {
        
    }
}
