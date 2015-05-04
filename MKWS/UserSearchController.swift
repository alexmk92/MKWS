//
//  UserSearchController.swift
//  MKWS
//
//  Created by Alex Sims on 16/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.

// Use PFQuery table view controller, handles a lot of complex lifting for us, such as pull to refresh which is a really cool feature
//

import UIKit

protocol UserSearchControllerDelegate
{
    func usersWereAddedToResponseArray([PFUser])
}

class UserSearchController: PFQueryTableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    
    private var recipients = [PFUser]()
    private var isAdding = false
    private var currentThread:PFObject!
    private var indexPathSelected = NSIndexPath(forRow: 0, inSection: 0)
    var delegate:UserSearchControllerDelegate?
    
    var queryString = ""
    var searching   = false
    
    // PFQueryTableViewController requires this
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Query all users in the system (MKWS is small so pulling all users back by default makes sense...we could also sort users by their main
        self.parseClassName       = "User"
        self.textKey              = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled    = true
        self.objectsPerPage       = 50
        
        self.title = "Select Recipients"
    }
    
    func setThread(thread:PFObject)
    {
        currentThread = thread
        isAdding = true
    }
    
    // Query the database for the user
    override func queryForTable() -> PFQuery {
        
        let forenameQuery = PFQuery(className: "_User")
        let usernameQuery = PFQuery(className: "_User")
        let surnameQuery  = PFQuery(className: "_User")
        
        if searching && count(queryString) > 0 {
            forenameQuery.whereKey("forename", containsString: queryString)
            surnameQuery.whereKey("surname", containsString: queryString)
            usernameQuery.whereKey("username", containsString: queryString)
        }
        
        // Create the combined query
        let query = PFQuery.orQueryWithSubqueries([forenameQuery, surnameQuery, usernameQuery])
        
        // Dont include
        if currentThread != nil
        {
            if let currentRecipients = currentThread.objectForKey("recipients") as? [PFUser]
            {
                for currUser in currentRecipients
                {
                    query.whereKey("objectId", notEqualTo: currUser.objectId!)
                }
            }
        }
        
        // Whenever the table updates, do not show the logged in user (that would make little sense!)
        query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        query.orderByAscending("forename")
        
        // Should we query from datastore?
        if self.objects!.count > 0
        {
            query.fromLocalDatastore()
        }
    
        return query
    }
    
    // Override the Parse tableview cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserSearchCell
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let user = User(newUser: self.objects![indexPath.row] as! PFUser)
            user.downloadAvatar()
            if let obj = self.objects![indexPath.row] as? PFObject {
                obj.pinWithName(obj.objectId!)
            }
            dispatch_async(dispatch_get_main_queue()) {
                cell.lblUsername!.text = user.getFullname()
                cell.lblEmail!.text    = user.getEmail()
                cell.imgAvatar!.image  = user.getAvatar()
            }
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.navigationItem.rightBarButtonItem = btnDone
        self.navigationItem.rightBarButtonItem!.enabled = false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        updateAtRow(indexPath)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        updateAtRow(indexPath)
    }
    
    func updateAtRow(indexPath:NSIndexPath)
    {
        indexPathSelected = indexPath
        if let cell = tableView.cellForRowAtIndexPath(indexPath)
        {
            // Ensure we got a user, if so set the cells accessory view and add them to the list
            if let user = self.objects![indexPath.row] as? PFUser
            {
                if cell.accessoryType == UITableViewCellAccessoryType.Checkmark
                {
                    // Remove player from send list and update cell accessory
                    removeRecipientWithName(user)
                    cell.accessoryType = UITableViewCellAccessoryType.None
                    cell.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 42/255, alpha: 1.0)
                    
                }
                else
                {
                    // Add player to send list and update cell accessory
                    recipients.append(user)
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    cell.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 61/255, alpha: 1.0)
                }
                // Toggles the send button
                updateSendButton()
            }
        }
    }
    
    func updateSendButton()
    {
        if recipients.count == 0
        {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
        else
        {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
    }
    
    // Checks if the user at the row is the user, if not we loop through and delete the right one
    func removeRecipientWithName(user:PFUser)
    {
        var i = 0
        for currUser in self.recipients
        {
            if user.objectId == currUser.objectId
            {
                if i < recipients.count
                {
                    self.recipients.removeAtIndex(i)
                }
            }
            i++
        }
    }
    
    // Checks if this user already exists in the array
    func doesNotContain(users:[PFUser], user:PFUser) -> Bool
    {
        for recipient in users
        {
            if user.objectId! == recipient.objectId!
            {
                return true
            }
        }
        return true
    }
    
    // Create a new chat log in the system
    @IBAction func startConvo(sender: AnyObject) {
        
        let newRecipients = recipients
        
        // build the new recipient list
        if isAdding && currentThread != nil
        {
            if let currRecipients = currentThread.objectForKey("recipients") as? [PFUser]
            {
                for recipient in currRecipients
                {
                    if doesNotContain(recipients, user: recipient)
                    {
                        recipients.append(recipient)
                    }
                }
            }
        }
        
        // Check user is logged in and go to message view, else head to login
        if PFUser.currentUser() != nil {
            
            // Check we have a recipient
            if recipients.count > 0
            {
                // Build a storyboard reference to push the user to the correct screen
                let messagesVC:MessageThreadViewController? = UIStoryboard.messageThreadViewController()
                
                // Objects is an array of objects returned by the query (array of users) - expand this to allow for multiple users per chat*
                let deviceOwner = PFUser.currentUser()
                
                // Build the recipients array
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
                
                // Ensure our json object is poplated
                if json.count > 0
                {
                    // Create the classname in Parse if it doesn't exist, else access the MessageThread table
                    var messageThread = PFObject(className: "MessageThread")
                    
                    // Check if the chat-room between these users already exist %@ is a string placeholder - use a predicate to construct a stronger query
                    let ownerQuery = PFQuery(className:"MessageThread")
                    ownerQuery.whereKey("deviceOwner", notEqualTo: deviceOwner!)
                    ownerQuery.whereKey("recipients", containsAllObjectsInArray: json)
                    ownerQuery.whereKey("recipients", equalTo: deviceOwner!)
                    
                    let recipientQuery = PFQuery(className:"MessageThread")
                    recipientQuery.whereKey("recipients", containsAllObjectsInArray: json)
                    recipientQuery.whereKey("deviceOwner", equalTo: deviceOwner!)
                    
                    let query = PFQuery.orQueryWithSubqueries([ownerQuery, recipientQuery])
                    
                    // Do the query on a background thread - if we have a result then don't make this MessageThread, instead point user to the open MessageThread
                    query.findObjectsInBackgroundWithBlock({ (mThreads:[AnyObject]?, error:NSError?) -> Void in
                        
                        // We found an existing object, forward the user to the MessageThread view controller
                        if error == nil && mThreads!.count > 0 {

                        var exists = false
                        
                        for thread in mThreads!
                        {
                            if var threadRecipients = thread.objectForKey("recipients") as? [PFUser]
                            {
                                if let threadOwner = thread.objectForKey("deviceOwner") as? PFUser
                                {
                                    if threadOwner == PFUser.currentUser()
                                    {
                                        if threadRecipients == self.recipients
                                        {
                                            messageThread = thread as! PFObject
                                            exists = true
                                        }
                                    }
                                    else
                                    {
                                        var i = 0
                                        for recipient in threadRecipients
                                        {
                                            if recipient == threadOwner
                                            {
                                                threadRecipients.removeAtIndex(i)
                                                break
                                            }
                                            
                                            i++
                                        }
                                        if threadRecipients == self.recipients && threadOwner != PFUser.currentUser()
                                        {
                                            messageThread = thread as! PFObject
                                            exists = true
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !exists
                        {
                            messageThread["deviceOwner"] = deviceOwner
                            messageThread["recipients"] = json
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                                messageThread.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                    // The new message thread was created - push the user to the MessageThread view controller
                                    if error == nil {
                                        messagesVC!.currThread   = messageThread
                                        messagesVC!.recipients = self.recipients
                                        
                                        if !self.isAdding
                                        {
                                            self.navigationController?.pushViewController(messagesVC!, animated: true)
                                        }
                                        else
                                        {
                                            if self.delegate != nil
                                            {
                                                self.delegate?.usersWereAddedToResponseArray(newRecipients)
                                            }
                                            self.navigationController?.popViewControllerAnimated(true)
                                        }
                                    }
                                })
                            })
                        }
                            else
                            {
                                messagesVC!.currThread   = messageThread
                                messagesVC!.recipients   = self.recipients
                                
                                if !self.isAdding
                                {
                                    self.navigationController?.pushViewController(messagesVC!, animated: true)
                                }
                                else
                                {
                                    if self.delegate != nil
                                    {
                                        self.delegate?.usersWereAddedToResponseArray(newRecipients)
                                    }
                                    self.navigationController?.popViewControllerAnimated(true)
                                }
                            }
                        }
                        // A message thread between these users does not exist, create a new MessageThread in Parse and push user to that view controller.
                        else if error == nil {
                            messageThread["deviceOwner"] = deviceOwner
                            messageThread["recipients"] = json
                            
                            if self.isAdding
                            {
                                if self.delegate != nil
                                {
                                    self.delegate?.usersWereAddedToResponseArray(newRecipients)
                                }
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                            else
                            {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                                    messageThread.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                        // The new message thread was created - push the user to the MessageThread view controller
                                        if error == nil {
                                            messagesVC!.currThread   = messageThread
                                            messagesVC!.recipients = self.recipients
                                            self.navigationController?.pushViewController(messagesVC!, animated: true)
                                        }
                                    })
                                })
                            }
                        }
                        
                    })
                }
            }
        }
    }
    
    // When the text changes in the search bar, perform a search and then reload the table
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        queryString = searchText
        searching = true
        self.loadObjects()
        searching = false
    }
    
    
    
    
}
