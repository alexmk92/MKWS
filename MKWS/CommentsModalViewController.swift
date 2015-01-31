//
//  CommentsModalView.swift
//  MKWS
//
//  Created by Alex Sims on 29/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

// Delegate from TableView so we can replicate the functionality of UITableViewControllers
class CommentsModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlet connections
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var btnCloseModal     : UIButton!
    @IBOutlet weak var txtComment        : UITextField!
    @IBOutlet weak var btnComment        : UIButton!
    @IBOutlet weak var lblPostTitle      : UILabel!
    @IBOutlet weak var lblCharactersLeft : UILabel!
    @IBOutlet weak var viewTxtInput      : UIView!
    
    @IBOutlet weak var bottomSpaceToSuperView: NSLayoutConstraint?
    
    
    private var comments: [Comment]!
    private var numRows  = 1
    var post: Post!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the data - Post should be set by segue but check it isnt nil here and then unwrap it safely
        if post != nil {
            getComments()
        }
        
        // Register notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardChanged:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func getComments()
    {
        // Create the query
        let postQuery = PFQuery(className: "Posts")
        postQuery.whereKey("objectId", equalTo: post.getPostID())
        let commentsQuery = PFQuery(className: "Comments")
        commentsQuery.whereKey("post", matchesKey: "objectId", inQuery: postQuery)
        commentsQuery.includeKey("post")
        commentsQuery.includeKey("author")
        commentsQuery.orderByDescending("createdAt")
        commentsQuery.findObjectsInBackgroundWithBlock { (results: [AnyObject]!, error: NSError!) -> Void in
            if error == nil
            {
                if results.count > 0
                {
                    // init the comments array - otherwise we will append to a nil object and crash
                    self.comments = [Comment]()
                    
                    // Loop over each result generating the comment
                    for comment in results {
                        let c = Comment()
                        c.setComment(comment["comment"] as String!)
                        c.setDate(comment.createdAt     as NSDate!)
                        c.setUser(comment["author"]     as PFUser!)
                        
                        self.comments.append(c)
                    }
                    
                    // Update the table if we found results
                    self.numRows = self.comments.count
                    self.tableView.reloadData()
                }
                

            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell with this comment
        var cell:UITableViewCell!
        
        // Check we have a valid post object
        if comments != nil {
            let comment = comments[indexPath.row]
            
            if comment.getUser() != nil {
                let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as CommentCell
                
                // Get the user and post objects to configure the cell
                let user = comment.getUser()!
                
                // We know this will return the default image if an avatar isnt set
                commentCell.imgAvatar.image  = user.getAvatar()!
                commentCell.lblEmail!.text   = user.getEmail()!
                commentCell.lblName!.text    = user.getFullname()!
                commentCell.lblDate!.text    = comment.getDateAsString()
                commentCell.txtComment!.text = comment.getComment()
                
                commentCell.imgAvatar.frame = CGRectMake(0, 0, 35, 35)
                commentCell.imgAvatar.layer.borderWidth  = 2.0
                commentCell.imgAvatar.layer.borderColor  = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1).CGColor
                commentCell.imgAvatar.layer.cornerRadius = commentCell.imgAvatar.frame.size.width/2
                commentCell.imgAvatar.layer.masksToBounds = false
                commentCell.imgAvatar.clipsToBounds = true
                
                cell = commentCell
            }
        }
        else
        {
            // Create a prompt for no comments
            if comments == nil || comments.count == 0
            {
                let alertCell = tableView.dequeueReusableCellWithIdentifier("AlertCell", forIndexPath: indexPath) as AlertCell
                
                alertCell.lblTitle!.text   = "Sorry"
                alertCell.lblMessage!.text = "It looks like there are no comments in this thread yet.  Why don't you add one?"
                
                cell = alertCell
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numRows
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
    
    // MARK: - Notification methods
    func keyboardChanged(notification: NSNotification) {
        
        // Ensure we are safely unwrapping the user info var
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomSpaceToSuperView?.constant = endFrame?.size.height ?? 0.0
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.viewTxtInput.layoutIfNeeded() },
                completion: nil)
        }
    }
    
}
