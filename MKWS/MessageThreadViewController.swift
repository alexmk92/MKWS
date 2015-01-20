//
//  MessageThreadViewController.swift
//  MKWS
//
//  Created by Alex Sims on 16/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class MessageThreadViewController: JSQMessagesViewController {

    // These are set by the segue link
    var currThread:PFObject!
    var incomingUser:PFUser!
    var users = [PFUser]()
    var messages = [JSQMessage]()
    var msgObjects = [PFObject]()

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
        
        // Set navigation bar items
        self.title = incomingUser.username
        let addPerson =  UIBarButtonItem(image: UIImage(named:"addPeople"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
            addPerson.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = addPerson
        
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToRoot")
            back.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = back
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Set the background
        backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        backgroundView.image = UIImage(named: "background")
        self.view.insertSubview(backgroundView, atIndex: 0)
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
        
        // Configure collection view and hide the tab bar
        self.collectionView.backgroundColor = UIColor.clearColor()
        tabBarController?.tabBar.hidden = true
        
        // Configure the message bubbles and avaars
        self.senderId = PFUser.currentUser().objectId
        self.senderDisplayName = PFUser.currentUser().username
        self.inputToolbar.contentView.leftBarButtonItem = nil       // Hide media upload - not using atm
        //self.inputToolbar.barStyle = UIBarStyle.BlackTranslucent
        self.inputToolbar.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        
        // Set the send icon
        self.inputToolbar.contentView.rightBarButtonItem.titleLabel?.text = nil
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), forState: UIControlState.Normal)
        self.inputToolbar.contentView.rightBarButtonItem.imageView?.tintColor = UIColor.whiteColor()
        
        // Set avatar to our initials - could move this to its own method
        let selfUsername    = PFUser.currentUser().username as NSString
        let inboundUsername = incomingUser.username         as NSString
        
        // set avatar with initials
        recieveAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "defaultAvatar")!, diameter: 50)
        selfAvatar    = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "defaultAvatar")!, diameter: 50)
        
        // Use the JSQ image factory to make chat bubbles
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        selfBubbleColor = UIColor(red: 32.0/255.0, green: 200.0/255.0, blue: 95.0/255.0,  alpha: 1.0)
        userBubbleColor = UIColor(red: 33.0/255.0, green: 178.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        
        sendBubbleImage    = bubbleFactory.outgoingMessagesBubbleImageWithColor(selfBubbleColor!)
        recieveBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(userBubbleColor)

        // Load the messages
        loadMessages()
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
        
            query.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
                if error == nil {
                    let messages = results as [PFObject]
                
                    for message in messages {
                        self.msgObjects.append(message)
                    
                        let user = message["sender"] as PFUser
                        self.users.append(user)
                    
                        // Build the message
                        let msg = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: message.createdAt, text: message["text"] as String)
                        self.messages.append(msg)
                    }
                
                    // If there were results then tell JSQ we have finished recieving all of our messages through its callback
                    if results.count != 0 {
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
        
        // Save the message to the server
        message.saveInBackgroundWithBlock { (success:Bool!, error:NSError!) -> Void in
            if error == nil {
                self.loadMessages()
                
                // Query installations and push to the correct device(s)
                let pushQuery = PFInstallation.query()
                    pushQuery.whereKey("user", equalTo: self.incomingUser)
                
                let push = PFPush()
                    push.setQuery(pushQuery)
                
                // Set the alert, badge and sound for the Notification Payload
                let pushDictionary = ["alert":text, "badge":"increment", "sound":""]
                
                push.setData(pushDictionary)
                push.sendPushInBackgroundWithBlock(nil)
                
                // Save the room as we have made changes to it (save its last updated field) - don't need a block here as we are doing no completion handle
                self.currThread["lastUpdate"] = NSDate()
                self.currThread.saveInBackgroundWithBlock(nil)
            } else {
                println("Error sending message to the server\(error)")
            }
        }
        
        // Use JSQ's finishSendingMessage handler
        self.finishSendingMessage()
    }
   
    // MARK: - JSQ DELEGATE METHODS
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        
        // Determines whether this is a chat bubble from the sender or the recipient
        if message.senderId == self.senderId {
            return sendBubbleImage
        } else {
            return recieveBubbleImage
        }
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        
        // Determines whos avatar to display
        if message.senderId == self.senderId {
            return selfAvatar
        } else {
            return recieveAvatar
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.row]
        
        cell.textView.textColor       = UIColor.whiteColor()
        cell.textView.backgroundColor = UIColor.clearColor()
        cell.backgroundColor          = UIColor.clearColor()
        
        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName:cell.textView.textColor]
        
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
