//
//  CommentsModalView.swift
//  MKWS
//
//  Created by Alex Sims on 29/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

// Delegate from TableView so we can replicate the functionality of UITableViewControllers
class CommentsModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    // Outlet connections
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var btnCloseModal     : UIButton!
    @IBOutlet weak var txtComment        : UITextView!
    @IBOutlet weak var btnComment        : UIButton!
    @IBOutlet weak var lblPostTitle      : UILabel!
    @IBOutlet weak var lblCharactersLeft : UILabel!
    @IBOutlet weak var viewTxtInput      : UIView!
    
    @IBOutlet weak var bottomSpaceToSuperView: NSLayoutConstraint?
    @IBOutlet weak var inputContainerHeight: NSLayoutConstraint!
    
    private let defaultMessage = "Enter your message..."
    private var isKeyboardOpen = false
    
    private var refreshing = false
    private var limit = 25  // Can increment this when we hit bottom of page to load more comments
    private var comments: [Comment]!
    private var numRows  = 1
    var post   : Post!
    var author : User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keyboard show and hide notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardChanged:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        txtComment.delegate = self
        
        // Gesture Recognisers
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the data - Post should be set by segue but check it isnt nil here and then unwrap it safely
        if post != nil {
            getComments(false)
        }
        
        if author != nil {
            lblPostTitle.text = "\(author.getForename())'s Post"
        }
        
        viewTxtInput.layer.borderWidth = 1
        viewTxtInput.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnComment.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnComment.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
    }
    
    func getComments(fetchFromNetwork: Bool)
    {
        // Create the query
        let postQuery = PFQuery(className: "Posts")
        postQuery.whereKey("objectId", equalTo: post.getPostID())
        let commentsQuery = PFQuery(className: "Comments")
        commentsQuery.whereKey("post", matchesKey: "objectId", inQuery: postQuery)
        commentsQuery.includeKey("post")
        commentsQuery.includeKey("author")
        commentsQuery.orderByDescending("createdAt")
        commentsQuery.limit = limit
        
        // Retrieve from local data store first
        if !fetchFromNetwork {
            postQuery.fromLocalDatastore()
            commentsQuery.fromLocalDatastore()
            
            commentsQuery.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error: NSError!) -> Void in
                if results.count > 0 {
                    println(results.count)
                } else {
                    self.getComments(true)
                }
            })
        }
        
        // Retrieve from network
        if fetchFromNetwork {
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
                            comment.pinWithName("comment")
                        }
                        
                        // Update the table if we found results
                        self.numRows = self.comments.count
                        self.tableView.reloadData()
                        self.tableView.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    // MARK: - Text view controls
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        bottomSpaceToSuperView?.constant = 0
        isKeyboardOpen = false
        
        if countElements(txtComment.text) < 1 {
            txtComment.text = defaultMessage
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if txtComment.text == defaultMessage {
            txtComment.text = ""
        }
        isKeyboardOpen = true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let maxLen = 100
        var len = countElements(txtComment.text)
        
        // Set label color
        switch(len) {
        case 0...50:
            lblCharactersLeft.textColor = UIColor(red: 124.0/255.0, green: 174.0/255.0, blue: 65.0/255.0, alpha: 1.0)
            inputContainerHeight?.constant = 50
        case 51...80:
            lblCharactersLeft.textColor = UIColor(red: 205.0/255.0, green: 150.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            inputContainerHeight?.constant = 75
        case 81...100:
            lblCharactersLeft.textColor = UIColor(red: 205.0/255.0, green: 60.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        default:
            lblCharactersLeft.textColor = UIColor(red: 205.0/255.0, green: 60.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        }
        
        // Set the label and check we did not exceed the limit
        if len > maxLen {
            self.txtComment.deleteBackward()
            len--
        } else {
            lblCharactersLeft.text = "\(100-len)"
        }
    }
    
    func getCommentContent()-> String! {
        if txtComment.text == defaultMessage || countElements(txtComment.text) == 0 || txtComment == nil {
            return ""
        }
        
        return txtComment.text!
    }

    
    // MARK: - Table delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell with current comment (create empty cell object to ensure we won't crash if thread does not complete)
        var cell = UITableViewCell()
        var imgAvatar: UIImage!
        
        // Check we have a valid post object
        if comments != nil {
            
            let comment = comments[indexPath.row]
            
            if comment.getUser() != nil {
                
                // Get the user and post objects to configure the cell
                let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as CommentCell
                let user = comment.getUser()!
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    
                    // This is intensive and eats the main thrad - move to separate and then callback to reload table data when done.
                    imgAvatar = user.getAvatar()!
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // We know this will return the default image if an avatar isnt set
                        commentCell.imgAvatar.image  = imgAvatar
                        commentCell.lblEmail!.text   = user.getEmail()!
                        commentCell.lblName!.text    = user.getFullname()!
                        commentCell.lblDate!.text    = comment.getDateAsString()
                        commentCell.txtComment!.text = comment.getComment()
                        
                        let x = commentCell.imgAvatar.frame.origin.x
                        let y = commentCell.imgAvatar.frame.origin.y
                        
                        commentCell.imgAvatar.frame = CGRectMake(x, y, 35, 35)
                        commentCell.imgAvatar.layer.borderWidth  = 2.0
                        commentCell.imgAvatar.layer.borderColor  = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1).CGColor
                        commentCell.imgAvatar.layer.cornerRadius = commentCell.imgAvatar.frame.size.width/2
                        commentCell.imgAvatar.layer.masksToBounds = false
                        commentCell.imgAvatar.clipsToBounds = true
                        
                        cell = commentCell
                    }
                }
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
    
    // Outlet actions
    @IBAction func DismissModal(sender: AnyObject) {
        textViewShouldEndEditing(txtComment)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func PostComment(sender: AnyObject) {
        
        let c = Comment()
        var comment  : String!
        var authorID : PFUser!
        var postID   : PFObject!
        
        // Check we have a message set
        if getCommentContent() != "" {
            comment  = getCommentContent()!
            authorID = PFUser.currentUser()!
            postID   = post.getRawPost()!
            
            // Save the comment to the db
            if comment != nil && authorID != nil && postID != nil
            {
                let newComment = PFObject(className: "Comments")
                
                newComment.setValue(comment,  forKey: "comment")
                newComment.setValue(authorID, forKey: "author")
                newComment.setValue(postID,   forKey: "post")
                
                // Save the object
                newComment.saveEventually({ (completed: Bool, error: NSError!) -> Void in
                    self.getComments(true)
                    self.textViewShouldEndEditing(self.txtComment)
                    self.txtComment.text = self.defaultMessage
                    newComment.pin()
                })
            }
            // Error - close the modal
            else {
                textViewShouldEndEditing(self.txtComment)
                DismissModal(self)
            }
        }
        

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
    
    // MARK: - Swipe gesutres
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        // Can we unwrap safely?
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction
            {
                // We are swiping down - check that the keyboard is open to perform the dismissal
            case UISwipeGestureRecognizerDirection.Down:
                if isKeyboardOpen {
                    textViewShouldEndEditing(self.txtComment)
                    self.bottomSpaceToSuperView?.constant = 0
                }
            case UISwipeGestureRecognizerDirection.Up:
                break
            case UISwipeGestureRecognizerDirection.Left:
                break
            case UISwipeGestureRecognizerDirection.Right:
                break
            default:
                break
            }
        }
    }
    
}
