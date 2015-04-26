//
//  UserSearchController.swift
//  MKWS
//
//  Created by Alex Sims on 16/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.

// Use PFQuery table view controller, handles a lot of complex lifting for us, such as pull to refresh which is a really cool feature
//

import UIKit

class UserSearchController: PFQueryTableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    
    private let recipients = [PFUser]()
    private var indexPathSelected = NSIndexPath(forRow: 0, inSection: 0)
    
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
        self.objectsPerPage       = 25
    }
    
    // Query the database for the user
    override func queryForTable() -> PFQuery {
        let query = PFUser.query()
        
        // Whenever the table updates, do not show the logged in user (that would make little sense!)
        query!.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        
        if searching {
            query!.whereKey("username", containsString: queryString)
        }
        
        // Get previously cached results for the query string if the query returns no results (this could be due to the network being down.)
        if self.objects!.count == 0 {
            //query.cachePolicy = kPFCachePolicyCacheThenNetwork
        }
        
        query!.orderByAscending("username")
        
        return query!
    }
    
    // Override the Parse tableview cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserSearchCell
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let user = User(newUser: self.objects![indexPath.row] as! PFUser)
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
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        indexPathSelected = indexPath
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // Remove user from the save array
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    // Create a new chat log in the system
    @IBAction func startConvo(sender: AnyObject) {
        // Check user is logged in and go to message view, else head to login
        if PFUser.currentUser() != nil {
            
            // Build a storyboard reference to push the user to the correct screen
            let messagesVC:MessageThreadViewController? = UIStoryboard.messageThreadViewController()
            
            // Objects is an array of objects returned by the query (array of users) - expand this to allow for multiple users per chat*
            let deviceOwner = PFUser.currentUser()
            
            let recipient = self.objects![self.indexPathSelected.row] as! PFUser
            
            // Create the classname in Parse if it doesn't exist, else access the MessageThread table
            var messageThread = PFObject(className: "MessageThread")
            
            // Check if the chat-room between these users already exist %@ is a string placeholder - use a predicate to construct a stronger query
            let pred = NSPredicate(format: "deviceOwner = %@ AND recipient = %@ OR deviceOwner = %@ AND recipient = %@", deviceOwner!, recipient, recipient, deviceOwner!)
            let query = PFQuery(className: "MessageThread", predicate: pred)
            
            // Do the query on a background thread - if we have a result then don't make this MessageThread, instead point user to the open MessageThread
            query.findObjectsInBackgroundWithBlock({ (mThreads:[AnyObject]?, error:NSError?) -> Void in
                
                // We found an existing object, forward the user to the MessageThread view controller
                if error == nil && mThreads!.count > 0 {
                    messageThread = mThreads!.last as! PFObject
                    
                    // Create segue
                    messagesVC!.currThread   = messageThread
                    messagesVC!.incomingUser = recipient
                    self.navigationController?.pushViewController(messagesVC!, animated: true)
                }
                    // A message thread between these users does not exist, create a new MessageThread in Parse and push user to that view controller.
                else if error == nil {
                    messageThread["deviceOwner"] = deviceOwner
                    messageThread["recipient"]   = recipient
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        messageThread.saveEventually({ (success:Bool, error:NSError?) -> Void in
                            // The new message thread was created - push the user to the MessageThread view controller
                            if error == nil {
                                messagesVC!.currThread   = messageThread
                                messagesVC!.incomingUser = recipient
                                self.navigationController?.pushViewController(messagesVC!, animated: true)
                            }
                        })
                    })
                }
                
            })
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
