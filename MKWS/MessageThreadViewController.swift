//
//  MessageThreadViewController.swift
//  MKWS
//
//  Created by Alex Sims on 16/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class MessageThreadViewController: JSQMessagesViewController, UserSearchControllerDelegate {
    
    // These are set by the segue link
    var currThread:PFObject!
    var incomingUser:PFUser!
    var recipients = [PFUser]()
    var messages = [JSQMessage]()
    var msgObjects = [PFObject]()
    var colors = [UIColor]()
    var user:User?
    
    var selfBubbleColor:UIColor!
    var userBubbleColor:UIColor!
    
    var sendBubbleImage:JSQMessagesBubbleImage!
    var recieveBubbleImage:JSQMessagesBubbleImage!
    var selfAvatar:JSQMessagesAvatarImage!
    var recieveAvatar:JSQMessagesAvatarImage!
    
    var backgroundView:UIImageView!
    
    
    // Set up the avatars and bubbles with their default color
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.translucent = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Set the background
        backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        backgroundView.image = UIImage(named: "background")
        self.view.insertSubview(backgroundView, belowSubview: self.collectionView)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self.user = User(newUser: PFUser.currentUser()!)
            self.user?.downloadAvatar()
            self.setColors()
            self.setTitle()
        }
        
        // Set navigation bar items
        let addPerson =  UIBarButtonItem(image: UIImage(named:"addPeople"), style: UIBarButtonItemStyle.Plain, target: self, action: "addPeople")
        addPerson.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = addPerson
        
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToRoot")
        back.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = back

        // Load the messages
        self.loadMessages()
        
        // Configure collection view and hide the tab bar
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.tabBarController?.tabBar.hidden = true
        
        // Configure the message bubbles and avaars
        self.senderId = PFUser.currentUser()!.objectId
        self.senderDisplayName = PFUser.currentUser()!.username
        self.inputToolbar.contentView.leftBarButtonItem = nil       // Hide media upload - not using atm
        //self.inputToolbar.barStyle = UIBarStyle.BlackTranslucent
        self.inputToolbar.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        
        // Set the send icon
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", forState: UIControlState.Normal)
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), forState: UIControlState.Normal)
        self.inputToolbar.contentView.rightBarButtonItem.imageView?.tintColor = UIColor.whiteColor()
        
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 38.0, height: 38.0);
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 38.0, height: 38.0);
    }
    
    // Segue to the add people
    func addPeople()
    {
        // Create the link to the user search controller
        if let searchController = UIStoryboard.chatSearchUserController()
        {
            searchController.setThread(currThread)
            searchController.delegate = self
            self.navigationController?.pushViewController(searchController, animated: true)
        }
    }
    
    func setTitle()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if self.recipients.count == 1
            {
                let user = self.recipients[0]
                user.fetchIfNeeded()
                // Set the name for the user we are about to talk with
                if let forename = self.recipients[0].valueForKey("forename") as? String
                {
                    if let surname  = self.recipients[0].valueForKey("surname") as? String
                    {
                        var displayName: String!
                        
                        // Ensure the names are set
                        if count(forename) > 0 && count(surname) > 0 {
                            
                            displayName = forename + " " + surname
                            
                            if count(displayName) <= 2
                            {
                                displayName = self.recipients[0].username!
                            }
                            
                        } else {
                            displayName = self.recipients[0].username!
                        }
                        
                        self.title = displayName
                    }
                }
            }
            else
            {
                var displayString = ""
                
                for var i = 0; i < self.recipients.count; i++
                {
                    if let user = self.recipients[i] as PFUser?
                    {
                        user.fetchIfNeeded()
                        if i < 3
                        {
                            if let forename = user.valueForKey("forename") as? String
                            {
                                if count(forename) > 1
                                {
                                    displayString = displayString + "\(forename)"
                                }
                                else
                                {
                                    displayString = displayString + "\(user.username!)"
                                }
                            }
                            else if let username = user.username
                            {
                                displayString = displayString + "\(username)"
                            }
                            
                            if self.recipients.count - i != 1
                            {
                                displayString = displayString + ", "
                            }
                        }
                        else
                        {
                            displayString = displayString + "+\(self.recipients.count - 2) others."
                            break
                        }
                    }
                }
                
                self.title = displayString
            }
        }
    }
    
    // MARK: - LOAD MESSAGES
    func loadMessages()
    {
        var lastMessage:JSQMessage? = nil
        
        // If there is atleast one message in this chat, then set the last message variable
        if messages.last != nil {
            lastMessage = messages.last
        }
        
        // Ensure this thread is active
        if self.currThread != nil {
            
            let query = PFQuery(className: "Message")
            query.whereKey("MessageThread", equalTo: self.currThread)
            query.orderByAscending("createdAt")
            query.limit = 250
            query.includeKey("sender")
            
            // Only load the newest message - saves network bandwidth, otherwise we load cached messages
            if lastMessage != nil {
                query.whereKey("createdAt", greaterThan: lastMessage!.date)
            }
            
            query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    let messages = results as! [PFObject]
                    
                    for message in messages {
                        self.msgObjects.append(message)
                        
                        if let user = message["sender"] as? PFUser
                        {
                            self.recipients.append(user)
                            
                            // Build the message
                            let msg = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: message.createdAt, text: message["text"] as! String)
                            self.messages.append(msg)
                        }
                        // This is a system message
                        else
                        {
                            // Build the message
                            let msg = JSQMessage(senderId: "SYSTEM", senderDisplayName: "System", date: message.createdAt, text: message["text"] as! String)
                            self.messages.append(msg)
                        }
                    }
                    
                    // If there were results then tell JSQ we have finished recieving all of our messages through its callback
                    if results!.count != 0 {
                        self.finishReceivingMessage()
                    }
                }
            }
        }
    }
    
    func popToRoot() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - INITIALISE OBSERVERS
    // Use the NSNotificationCenter to call our loadMessages function - then use JSQ's reloadMessages delegate method to refresh on a new notification callback
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadMessages", name: "reloadMessages", object: nil)
    }
    
    // Destroy the observer as we don't want to load messages whilst not in the view (bad for memory bandwidth
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadMessages", object: nil)
    }
    
    // MARK: - SEND THE MESSAGE
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        // Set up the message and push it to Parse
        let message = PFObject(className: "Message")
        message["text"] = text
        message["MessageThread"] = currThread
        message["sender"] = PFUser.currentUser()
        
        // Set the permissions for this message - this will ensure other users who aren't in this convo
        // cannot read the contents of this message
        let messageACL = PFACL()
        messageACL.setReadAccess(true, forRoleWithName: PFUser.currentUser()!.objectId!)
        messageACL.setWriteAccess(true, forRoleWithName: PFUser.currentUser()!.objectId!)
        
        for user in recipients
        {
            messageACL.setReadAccess(true, forRoleWithName: user.objectId!)
        }
        
        // Assign the control list to this message objects ACL
        message.ACL = messageACL
        
        // Save the message to the server
        message.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if error == nil {
                self.loadMessages()
                
                // Query installations and push to the correct device(s)
                let recipientQuery = PFInstallation.query()
                recipientQuery!.whereKey("user", containedIn: self.recipients)
                recipientQuery!.whereKey("user", notEqualTo: PFUser.currentUser()!)
               
                
                let pushQuery = PFQuery.orQueryWithSubqueries([recipientQuery!])
                
                let push = PFPush()
                push.setQuery(pushQuery)
                
                // Set the alert, badge and sound for the Notification Payload
                let pushDictionary = ["alert":text, "badge":"increment", "sound":""]
                
                push.setData(pushDictionary)
                push.sendPushInBackgroundWithBlock(nil)
                
                // Save the room as we have made changes to it (save its last updated field) - don't need a block here as we are doing no completion handle
                self.currThread["lastUpdate"] = NSDate()
                self.currThread.saveInBackgroundWithBlock(nil)
                
                // Build the recipients array
                var json : Array<Dictionary<String, AnyObject>> = []
                for recipient in self.recipients
                {
                    // build the new object
                    if let objectId : String = recipient.objectId as String?
                    {
                        if objectId != PFUser.currentUser()?.objectId!
                        {
                            let object : Dictionary<String, AnyObject> = ["__type":"Pointer", "className":"_User", "objectId" : objectId]
                            json.append(object)
                        }
                    }
                }
                
                if json.count > 0
                {
                    let unread = PFObject(className:"UnreadMessage")
                    unread["users"] = json
                    unread["room"] = self.currThread
                    
                    unread.saveEventually(nil)
                }
            } else {
                println("Error sending message to the server\(error)")
            }
        }
        
        // Use JSQ's finishSendingMessage handler
        self.finishSendingMessageAnimated(true)
    }
    
    // MARK: - JSQ DELEGATE METHODS
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        
        // Random color bubble
        var bubbleImage:JSQMessagesBubbleImage?
        
        var color = UIColor(red: 54/255.0, green: 69/255.0, blue: 221/255.0,  alpha: 1.0)
        
        if message.senderId == self.senderId
        {
            color = UIColor(red: 32.0/255.0, green: 200.0/255.0, blue: 95.0/255.0,  alpha: 1.0)
        }
        else
        {
            if recipients.count > 0
            {
                var i = 0
                for user in recipients
                {
                    if user.objectId == message.senderId
                    {
                        // Set the color
                        if i < colors.count
                        {
                            color = colors[i]
                        }
                        else
                        {
                            color = UIColor(red: 33.0/255.0, green: 178.0/255.0, blue: 219.0/255.0, alpha: 1.0)
                        }
                        break
                    }
                    i++
                }
            }
        }
        
        bubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(color)
        return bubbleImage

    }
    
    // Sets an array of colors for bubbles
    func setColors()
    {
        let redColor = UIColor(red: 209/255.0, green: 52/255.0, blue: 81/255.0, alpha: 1.0)
        let blueColor = UIColor(red: 33/255.0, green: 178/255.0, blue: 219/255.0,  alpha: 1.0)
        let yellowColor = UIColor(red: 220/255.0, green: 200/255.0, blue: 27/255.0, alpha: 1.0)
        let purpleColor = UIColor(red: 172/255.0, green: 27/255.0, blue: 220/255.0, alpha: 1.0)
        let orangeColor = UIColor(red: 214/255.0, green: 133/255.0, blue: 38/255.0, alpha: 1.0)
        let grayColor = UIColor(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1.0)
        
        colors.append(blueColor)
        colors.append(orangeColor)
        colors.append(yellowColor)
        colors.append(purpleColor)
        colors.append(redColor)
        colors.append(grayColor)
    }
    
    // Notifies this controller that we recieved new users
    func usersWereAddedToResponseArray(newUsers:[PFUser]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            // Create new message objects and notify current participants
            var message = ""
            var i = 0
            for user in newUsers
            {
                if let u = User(newUser: user) as User?
                {
                    message = message + "\(u.getFullname())"
                    
                    if newUsers.count - i != 1
                    {
                        message = message + ", "
                    }
                }
                i++
            }
            if newUsers.count == 1
            {
                message = message + " has joined the room."
            }
            else
            {
                message = message + " have joined the room."
            }
            
            // Update the thread
            var json : Array<Dictionary<String, AnyObject>> = []
            for recipient in self.recipients
            {
                // build the new object
                if let objectId : String = recipient.objectId as String?
                {
                    let object : Dictionary<String, AnyObject> = ["__type":"Pointer", "className":"_User", "objectId" : objectId]
                    json.append(object)
                }
            }
            for recipient in newUsers
            {
                // build the new object
                if let objectId : String = recipient.objectId as String?
                {
                    let object : Dictionary<String, AnyObject> = ["__type":"Pointer", "className":"_User", "objectId" : objectId]
                    json.append(object)
                }
                self.recipients.append(recipient)
            }
            
            self.currThread.setObject(json, forKey: "recipients")
            self.currThread.saveEventually { (saved:Bool, error:NSError?) -> Void in
                if error == nil
                {
                    if saved
                    {
                        // Send a new message to the chat room
                        let msg = PFObject(className: "Message")
                        msg["text"] = message
                        msg["MessageThread"] = self.currThread
                        msg.saveEventually { (saved:Bool, error:NSError?) -> Void in
                            if saved && error == nil
                            {
                                // Update the view
                                self.loadMessages()
                                self.setTitle()
                                
                                // Query installations and push to the correct device(s)
                                let recipientQuery = PFInstallation.query()
                                recipientQuery!.whereKey("user", containedIn: self.recipients)
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
                        }
                    }
                }
            }
   
        }
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20.0
    }
    
    // 
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        
        var avatar:UIImage?
        if message.senderId == self.senderId
        {
            avatar = user?.getAvatar()
        }
        else
        {
            if recipients.count > 0
            {
                for user in recipients
                {
                    if user.objectId == message.senderId
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            let u = User(newUser: user)
                            u.downloadAvatar()
                            avatar = u.getAvatar()
                        }
                    }
                }
            }
        }
        
        if avatar == nil
        {
            avatar = UIImage(named:"defaultAvatar")
        }
        
        return JSQMessagesAvatarImageFactory.avatarImageWithImage(avatar!, diameter: 38)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.row]
        
        cell.textView.textColor           = UIColor.whiteColor()
        cell.textView.backgroundColor     = UIColor.clearColor()
        cell.backgroundColor              = UIColor.clearColor()
        cell.textView.linkTextAttributes  = [NSForegroundColorAttributeName:cell.textView.textColor]
        
        cell.avatarImageView.circleMask(imageView: cell.avatarImageView)
        cell.avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.avatarImageView.layer.borderColor = UIColor.clearColor().CGColor
        
        if message.senderId == "SYSTEM"
        {
            cell.avatarImageView.alpha = 0
        }
        else
        {
            cell.avatarImageView.alpha = 1
        }
        
        return cell
    }
    
    // Next two methods handle which label the date will be set above, here we do it every 6 messages
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.item % 6 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0
    }
    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        // We only want to return the date occasionally
        if indexPath.item % 6 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    // MARK: - DATA SOURCE
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}