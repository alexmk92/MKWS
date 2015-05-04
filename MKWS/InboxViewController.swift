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
    var users          = [[PFUser]]()
    var currentUser:User!
    
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
        self.navigationController?.navigationBar.grayBar()
        tabBarController?.tabBar.hidden = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if PFUser.currentUser() != nil {
                self.currentUser = User(newUser:PFUser.currentUser()!)
                self.loadData(Reachability.isConnectedToNetwork())
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recievedNotification", name: "reloadMessages", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadMessages", object: nil)
    }
    
    // Reload data from server, not cache
    func recievedNotification()
    {
        loadData(true)
    }
    
    // Populates the messageThreads and users array
    func loadData(fetchFromNetwork:Bool)
    {
        // Re-initialize global arrays to avoid duplicate posts
        messageThreads = [PFObject]()
        users          = [[PFUser]]()
        
        // Create a query fetching the latest active chats first
        let ownerQuery = PFQuery(className:"MessageThread")
        ownerQuery.whereKey("deviceOwner", equalTo: PFUser.currentUser()!)
        let recipientQuery = PFQuery(className:"MessageThread")
        recipientQuery.whereKey("recipients", equalTo: PFUser.currentUser()!)
        
        // Combine the queries to get the OR
        let query = PFQuery.orQueryWithSubqueries([ownerQuery, recipientQuery])
        query.orderByDescending("lastUpdate")
        
        // Allows us to access the key relation
        query.includeKey("deviceOwner")
        
        if !fetchFromNetwork
        {
            // Modify this for group conversations
            query.fromLocalDatastore().findObjectsInBackgroundWithBlock { (threads:[AnyObject]?, error:NSError?) -> Void in
                if error == nil && PFUser.currentUser() != nil {
                    self.messageThreads = threads as! [PFObject]
                    
                    if threads!.count == 0
                    {
                        self.loadData(false)
                    }
                    
                    for thread in self.messageThreads {

                        if let threadUsers = thread.objectForKey("recipients") as? [PFUser]
                        {
                            // Append the array of users
                            self.users.append(threadUsers)
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        else
        {
            // Modify this for group conversations
            query.findObjectsInBackgroundWithBlock { (threads:[AnyObject]?, error:NSError?) -> Void in
                if error == nil && PFUser.currentUser() != nil {
                    self.messageThreads = threads as! [PFObject]
                    
                    for thread in self.messageThreads {
                        if thread.objectForKey("deviceOwner") != nil {
                            thread.pinInBackgroundWithBlock(nil)
                            if let threadUsers = thread.objectForKey("recipients") as? [PFUser]
                            {
                                // Append the array of users
                                self.users.append(threadUsers)
                            }
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // Load each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! InboxViewCell
        cell.newMessageIndicator.hidden = true
        
        if indexPath.row < users.count
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                
                // Get the recipients and sender for the chatroom
                let deviceOwner = PFUser.currentUser()
                let recipients  = self.users[indexPath.row]
                
                if recipients.count == 1
                {
                    let user = User(newUser: recipients[0])
                    user.getPFUser().fetchIfNeeded()
                    user.downloadAvatar()
                    // Set the name for the user we are about to talk with
                    let forename = user.getForename()
                    let surname  = user.getSurname()
                    var displayName: String!
                    
                    // Ensure the names are set
                    if count(forename) > 0 && count(surname) > 0 {
                        
                        displayName = forename + " " + surname
                        
                        if count(displayName) <= 2
                        {
                            displayName = recipients[0].username!
                        }
                        
                    } else {
                        displayName = recipients[0].username!
                    }
                    
                    cell.lblName.text = user.getFullname()
                    cell.imgAvatar.image = user.getAvatar()
                }
                else
                {
                    var displayString = ""
                    
                    for var i = 0; i < recipients.count; i++
                    {
                        if let user = User(newUser: recipients[i]) as User?
                        {
                            if i < 3
                            {
                                if let forename = user.getForename()
                                {
                                    if count(forename) > 1
                                    {
                                        displayString = displayString + "\(forename)"
                                    }
                                    else
                                    {
                                        displayString = displayString + "\(user.getUsername()!)"
                                    }
                                }
                                else if let username = user.getUsername()
                                {
                                    displayString = displayString + "\(username)"
                                }
                                
                                if recipients.count - i != 1
                                {
                                    displayString = displayString + ", "
                                }
                            }
                            else
                            {
                                displayString = displayString + "+\(recipients.count - 2) others."
                                break
                            }
                        }
                    }
                    
                    let user = User(newUser: recipients.last!)
                    user.downloadAvatar()
                    
                    cell.imgAvatar.image = user.getAvatar()
                    cell.lblName.text = displayString
                }
                
                // Get the messages
                let query = PFQuery(className: "Message")
                let mThread = self.messageThreads[indexPath.row]
                
                // Check for new messages
                let unreadQuery = PFQuery(className: "UnreadMessage")
                unreadQuery.whereKey("users", equalTo: PFUser.currentUser()!)
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
                dispatch_async(dispatch_get_main_queue()) {
                    return cell
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
            if let recipients = thread.objectForKey("recipients") as? [PFUser]
            {
                var json : Array<Dictionary<String, AnyObject>> = []
                for recipient in recipients
                {
                    // build the new object
                    if let objectId : String = recipient.objectId as String?
                    {
                        if objectId != PFUser.currentUser()!.objectId
                        {
                            let object : Dictionary<String, AnyObject> = ["__type":"Pointer", "className":"_User", "objectId" : objectId]
                            json.append(object)
                        }
                    }
                }
                
                // Chat between two people - just delete it
                if recipients.count <= 2
                {
                    thread.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if error == nil
                        {
                            if success
                            {
                                thread.fetchFromLocalDatastoreInBackgroundWithBlock({ (theThread:PFObject?, error:NSError?) -> Void in
                                    if error == nil
                                    {
                                        theThread!.deleteInBackgroundWithBlock(nil)
                                    }
                                })
                                
                            }
                        }
                    })
                }
                // Group chat - remove self from the chat
                else
                {
                    if let deviceOwner = thread.objectForKey("deviceOwner") as? PFUser
                    {
                        if deviceOwner == PFUser.currentUser()!
                        {
                            thread.removeObjectForKey("deviceOwner")
                        }
                    }
                    
                    // Set the updated json for this object
                    thread.setObject(json, forKey: "recipients")
                    
                    // Save the updated thread
                    thread.saveEventually({ (success:Bool, error:NSError?) -> Void in
                        if error == nil
                        {
                            let update = "\(self.currentUser.getFullname()!) has left the room."
                            
                            // Send a message to say X has left the chat
                            let message = PFObject(className: "Message")
                            message.setObject(thread, forKey: "MessageThread")
                            message.setValue(update, forKey: "text")
                            
                            message.saveEventually({ (saved:Bool, error:NSError?) -> Void in
                                if error == nil && saved
                                {
                                    // Send a push notification to the users in this thread
                                    // Query installations and push to the correct device(s)
                                    let recipientQuery = PFInstallation.query()
                                    recipientQuery!.whereKey("user", containedIn: json)
                                    let ownerQuery = PFInstallation.query()
                                    ownerQuery!.whereKey("user", equalTo: PFUser.currentUser()!)
                                    
                                    let pushQuery = PFQuery.orQueryWithSubqueries([recipientQuery!, ownerQuery!])
                                    
                                    let push = PFPush()
                                    push.setQuery(pushQuery)
                                    
                                    // Set the alert, badge and sound for the Notification Payload
                                    let pushDictionary = ["alert":message, "badge":"increment", "sound":""]
                                    
                                    push.setData(pushDictionary)
                                    push.sendPushInBackgroundWithBlock(nil)
                                }
                            })
                            
                            
                        }
                    })
                }
            }
            
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
        if indexPath.row < users.count
        {
            if let recipients = users[indexPath.row] as? [PFUser]
            {
                
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                
                cell?.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 61/255, alpha: 1.0)
                
                //let pred = NSPredicate(format: "deviceOwner = %@ AND recipient = %@ OR deviceOwner = %@ AND recipient = %@", deviceOwner!, recipient, recipient, deviceOwner!)
                // Build a JSON object do do a fair comparison for all objects in the array, without including the
                // device owner
                var json : Array<Dictionary<String, AnyObject>> = []
                for recipient in recipients
                {
                    // build the new object
                    if let objectId : String = recipient.objectId as String?
                    {
                        if objectId != PFUser.currentUser()!.objectId
                        {
                            let object : Dictionary<String, AnyObject> = ["__type":"Pointer", "className":"_User", "objectId" : objectId]
                            json.append(object)
                        }
                    }
                }
                
                let messageThread = messageThreads[indexPath.row]
                messagesVC.currThread = messageThread
                messagesVC.incomingUser = deviceOwner!
                messagesVC.recipients = recipients
                
                // Delete from read messages
                let deleteUnreadMessages = PFQuery(className: "UnreadMessage")
                deleteUnreadMessages.whereKey("users", equalTo: PFUser.currentUser()!)
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
                
                cell?.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 42/255, alpha: 1.0)
                self.navigationController?.pushViewController(messagesVC, animated: true)
                
            
            }
        }
    }
    
    @IBAction func addFriendClicked(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let addFriendVC = storyboard.instantiateViewControllerWithIdentifier("chatUserSearchVC") as! UserSearchController
        self.navigationController?.pushViewController(addFriendVC, animated: true)
    }
}