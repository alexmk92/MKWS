//
//  ChatInboxViewController.swift
//  MKWS
//
//  Created by Alex Sims on 16/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class InboxViewController: UITableViewController {
    
    @IBOutlet weak var addFriendButton: UIBarButtonItem!
    
    var messageThreads = [PFObject]()
    var users          = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Inbox"
        self.navigationItem.setRightBarButtonItem(addFriendButton, animated: false)
        self.tableView.bounces = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageThreads.count
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = false
        if PFUser.currentUser() != nil {
            loadData()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "reloadMessages", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadMessages", object: nil)
    }
    
    
    // Populates the messageThreads and users array
    func loadData()
    {
        // Re-initialize global arrays to avoid duplicate posts
        messageThreads = [PFObject]()
        users          = [PFUser]()
        
        let pred = NSPredicate(format: "deviceOwner = %@ OR recipient = %@", PFUser.currentUser()!, PFUser.currentUser()!)
        
        // Create a query fetching the latest active chats first
        let query = PFQuery(className: "MessageThread", predicate: pred)
        query.orderByDescending("lastUpdate")
        
        // Allows us to access the key relation
        query.includeKey("deviceOwner")
        query.includeKey("recipient")
        
        // Modify this for group conversations
        query.findObjectsInBackgroundWithBlock { (threads:[AnyObject]?, error:NSError?) -> Void in
            if error == nil && PFUser.currentUser() != nil {
                self.messageThreads = threads as! [PFObject]
                
                for thread in self.messageThreads {
                    if thread.objectForKey("deviceOwner") != nil {
                        let user1 = thread.objectForKey("deviceOwner") as! PFUser
                        let user2 = thread.objectForKey("recipient") as! PFUser
                        
                        // Defines which user we wish to talk to
                        if user1.objectId != PFUser.currentUser()!.objectId {
                            self.users.append(user1)
                        }
                        if user2.objectId != PFUser.currentUser()!.objectId {
                            self.users.append(user2)
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! InboxViewCell
        cell.newMessageIndicator.hidden = true
        
        // Get the recipients and sender for the chatroom
        let deviceOwner = PFUser.currentUser()
        let recipient   = users[indexPath.row]
        
        // Set the name for the user we are about to talk with
        let forename: AnyObject! = recipient["forename"]
        let surname : AnyObject! = recipient["surname"]
        var displayName: String!
        
        // Ensure the names are set
        if forename != nil && surname != nil {
            let s = surname  as! String
            let f = forename as! String
            
            displayName = f + " " + s
        } else {
            displayName = recipient.username
        }
        
        cell.lblName.text = displayName
        
        // Query the database to check this chatroom doesnt already exist
        let pred  = NSPredicate(format: "deviceOwner = %@ AND recipient = %@ OR deviceOwner = %@ AND recipient = %@", deviceOwner!, recipient, recipient, deviceOwner!)
        let query = PFQuery(className: "MessageThread", predicate: pred)
        
        // Find existing chatrooms
        query.findObjectsInBackgroundWithBlock { (data:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                if let results = data {
                    if results.count > 0 {
                        
                        // Set profile pictures
                        if recipient["avatar"] != nil {
                            cell.imgAvatar.image = UIImage(data: (recipient["avatar"]!.getData() as NSData?)!)
                        } else {
                            cell.imgAvatar.image = UIImage(named: "defaultAvatar")
                        }
                        
                        // Get the messages
                        let query = PFQuery(className: "Message")
                        let mThread = results.last as! PFObject
                        
                        // Check for new messages
                        let unreadQuery = PFQuery(className: "UnreadMessage")
                        let user:PFUser = PFUser.currentUser()!
                        unreadQuery.whereKey("user", equalTo: PFUser.currentUser()!)
                        unreadQuery.whereKey("room", equalTo: mThread)
                        
                        unreadQuery.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error:NSError?) -> Void in
                            if error == nil
                            {
                                if results!.count > 0
                                {
                                    cell.newMessageIndicator.hidden = false
                                }
                            }
                        })
                        
                        query.whereKey("MessageThread", equalTo: mThread)
                        query.limit = 1
                        query.orderByDescending("createdAt")
                        query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]?, error:NSError?) -> Void in
                            if error == nil {
                                if results!.count > 0 {
                                    let message = results!.last as! PFObject
                                    
                                    cell.lblLastMessage.text = message["text"] as? String
                                    
                                    let date = message.createdAt
                                    let interval = NSDate().daysAfterDate(date)
                                    let df = NSDateFormatter();
                                    let tf = NSDateFormatter();
                                    
                                    tf.dateFormat = "hh:mm"
                                    df.dateFormat = "dd/mm/yyyy"
                                    
                                    var displayDate = "";
                                    
                                    switch(interval) {
                                    case 0:
                                        displayDate = "\(tf.stringFromDate(message.createdAt!))"
                                    case 1:
                                        displayDate = "YESTERDAY"
                                    default:
                                        displayDate = "\(df.stringFromDate(message.createdAt!))"
                                    }
                                    
                                    cell.lblDate.text = displayDate as String
                                    
                                } else {
                                    cell.lblLastMessage.text = "No messages yet, say Hi!"
                                }
                            }
                        })
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Delete the chat log
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // Get reference to message thread
            let thread = self.messageThreads[indexPath.row]
            
            let query = PFObject(className: "MessageThread")
            query.removeObjectForKey(thread.objectId!)
            query.deleteInBackgroundWithBlock(nil)
            
            // Update the table view and local model
            self.tableView.beginUpdates()
            self.messageThreads.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            self.tableView.endUpdates()
        }
    }
    
    // Send the user to the message VC
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard  = UIStoryboard(name: "Chat", bundle: nil)
        let messagesVC  = storyboard.instantiateViewControllerWithIdentifier("MessageThreadVC") as! MessageThreadViewController
        
        // Check if the message thread already exists (it should because we can see it in table view) - we then go to that message thread
        let deviceOwner = PFUser.currentUser()
        if let recipient = users[indexPath.row] as? PFUser {
            let pred = NSPredicate(format: "deviceOwner = %@ AND recipient = %@ OR deviceOwner = %@ AND recipient = %@", deviceOwner!, recipient, recipient, deviceOwner!)
            
            let threadQuery = PFQuery(className: "MessageThread", predicate: pred)
            
            // We know only one room will be returned for this query, therefore check for results and use the "last" accessor
            threadQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
                if error == nil {
                    let messageThread = results!.last as! PFObject
                    messagesVC.currThread = messageThread
                    messagesVC.incomingUser = recipient
                    
                    // Delete from read messages
                    let deleteUnreadMessages = PFQuery(className: "UnreadMessage")
                    deleteUnreadMessages.whereKey("user", equalTo: PFUser.currentUser()!)
                    deleteUnreadMessages.whereKey("room", equalTo: messageThread)
                    // Delete unread messages asynchronosuly
                    deleteUnreadMessages.findObjectsInBackgroundWithBlock({ (results:[AnyObject]?, error:NSError?) -> Void in
                        if error == nil
                        {
                            if let unreadMessages = results as? [PFObject]
                            {
                                for message in unreadMessages
                                {
                                    message.deleteInBackgroundWithBlock(nil)
                                }
                            }
                        }
                    })
                    
                    self.navigationController?.pushViewController(messagesVC, animated: true)
                }
            }
        }
    }
    
    @IBAction func addFriendClicked(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let addFriendVC = storyboard.instantiateViewControllerWithIdentifier("chatUserSearchVC") as! UserSearchController
        self.navigationController?.pushViewController(addFriendVC, animated: true)
    }
}
