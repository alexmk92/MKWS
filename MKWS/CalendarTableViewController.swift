//
//  CalendarTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 30/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class CalendarTableViewController: UITableViewController, CalendarCellDelegate, EventDetailViewControllerDelegate {

    var events:[PFObject]!
    var selectedUser:PFUser?
    var currentPath:NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Events"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.bounces = false
        self.navigationController?.navigationBar.blueBar()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Load the data
        getEvents()
    }
    
    // Bind notifications
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getEvents", name: "reloadEvents", object: nil)
    }
    
    // Unbind notification listeners
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadEvents", object: nil)
    }
    
    // Fetch from local datastore if not connected to network
    func getEvents()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.events = [PFObject]()
            
            // Perform a subquery to see which recipients match the array of pointers stored in Parse
            let recieverQuery = PFQuery(className: "Request")
            recieverQuery.whereKey("recievers", equalTo: PFUser.currentUser()!)
            recieverQuery.whereKey("declined", notEqualTo: PFUser.currentUser()!)
            
            let senderQuery = PFQuery(className: "Request")
            senderQuery.whereKey("sender", equalTo: PFUser.currentUser()!)
            
            let eventQuery = PFQuery.orQueryWithSubqueries([recieverQuery, senderQuery])
            eventQuery.includeKey("game")
            eventQuery.includeKey("gameType")
            eventQuery.orderByDescending("gameDate")
            
            // Check what resource we need to query
            if Reachability.isConnectedToNetwork()
            {
                // Query from the network
                eventQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
                    if error == nil
                    {
                        if let data = results as? [PFObject]
                        {
                            for request in data
                            {
                                self.events.append(request)
                                request.pinWithName(request.objectId!)
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            else
            {
                // Query from the localdatstore
                eventQuery.fromLocalDatastore().findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
                    if error == nil
                    {
                        if let data = results as? [PFObject]
                        {
                            for request in data
                            {
                                self.events.append(request)
                                request.pinWithName(request.objectId!)
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let allEvents = events
        {
            return allEvents.count
        }
        
        return 0
    }

    // Build each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Get the request and build the cell
        if indexPath.row < events.count
        {
            if let request = events[indexPath.row] as PFObject!
            {
                // Retrieve all information from the objects
                let game     = request.objectForKey("game") as? PFObject
                let gameType = game!.objectForKey("gameType") as? PFObject
                let sender   = request.valueForKey("sender") as? PFUser
                let opponent = request.valueForKey("respondent") as? PFUser
                let type     = gameType!.valueForKey("name") as! String
                let date     = game!.valueForKey("gameDate") as! NSDate
                let dString  = date.stringWithFormat("dd-MMM-yyyy")
                let tString  = date.stringWithFormat("h:mma")
                
                // Check for a cell for you vs somebody
                if let respondent = opponent as PFUser?
                {
                    let gameCell = tableView.dequeueReusableCellWithIdentifier("gameRequest", forIndexPath: indexPath) as! GameCell
                    
                    gameCell.delegate = self
                    gameCell.game = request
                    gameCell.tableView = tableView
                    
                    let whoIsOppo = opponent == PFUser.currentUser() ? sender : opponent
                    let userSelf = User(newUser: PFUser.currentUser()!)
                    let userOppo = User(newUser: whoIsOppo!)
                    
                    gameCell.opponent = whoIsOppo
                    gameCell.imgSelf.image     = userSelf.getAvatar()
                    gameCell.imgOpponent.image = userOppo.getAvatar()
                    gameCell.lblGameType.text  = type
                    gameCell.lblDate.text      = "\(dString) at \(tString)"
                    gameCell.lblMatchup.text   = "You vs \(userOppo.getForename())"
                    gameCell.imgSelf.zeroBorder()
                    gameCell.imgOpponent.zeroBorder()
                    
                    return gameCell
                }
            
                // Check if we are the sender of this cell
                if sender == PFUser.currentUser()
                {
                    let senderCell = tableView.dequeueReusableCellWithIdentifier("userEvent", forIndexPath: indexPath) as! CalendarCell
                    
                    senderCell.delegate = self
                    senderCell.tableView = tableView
                    
                    // Process challenger cells
                    if let recipients = request.objectForKey("recievers") as? [PFUser]
                    {
                        var count  = 0
                        var images = [UIImage]()
                        let others:Int = recipients.count - 4
                        
                        senderCell.imgRecipientA.zeroBorder()
                        senderCell.imgRecipientB.zeroBorder()
                        senderCell.imgRecipientC.zeroBorder()
                        senderCell.imgRecipientD.zeroBorder()
            
                        senderCell.game = request
                        
                        // Build the images array
                        count = recipients.count
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                            for var i = 0; i < recipients.count; i++
                            {
                                if let user = recipients[i] as PFUser?
                                {
                                    if user.valueForKey("avatar") != nil
                                    {
                                        let image: UIImage = UIImage(data: (user.valueForKey("avatar")!.getData() as NSData?)!)!
                                        images.append(image)
                                    } else {
                                        let image: UIImage = UIImage(named: "defaultAvatar")!
                                        images.append(image)
                                    }
                                }
                                
                            }
                            dispatch_async(dispatch_get_main_queue())
                                {
                                    for var i = 0; i < images.count; i++
                                    {
                                        switch i
                                        {
                                        case 0: senderCell.imgRecipientA.image = images[i]
                                        case 1: senderCell.imgRecipientB.image = images[i]
                                        case 2: senderCell.imgRecipientC.image = images[i]
                                        case 3: senderCell.imgRecipientD.image = images[i]
                                        default: break
                                        }
                                    }
                            }
                        })
                        
                        // Set the cell
                        senderCell.game = request
                        senderCell.lblGameType!.text = type
                        senderCell.lblGameDate!.text = "\(dString) at \(tString)"
                        
                        if others > 0
                        {
                            let plural = others > 1 ? "s" : ""
                            senderCell.lblOthers!.text = "+\(others) other\(plural)..."
                        }
                    }
                    
                    return senderCell
                }
                else
                {
                    // We are dealing with an accept decline cell
                    if let theSender = User(newUser: sender!) as User?
                    {
                        let requestCell = tableView.dequeueReusableCellWithIdentifier("directRequest", forIndexPath: indexPath) as! CalendarRequestCell
                        
                        requestCell.delegate = self
                        requestCell.game = request
                        requestCell.tableView = tableView
                        requestCell.imgAvatar.zeroBorder()
                        
                        requestCell.imgAvatar?.image = theSender.getAvatar()
                        requestCell.lblChallengerName.text = "\(theSender.getForename()) challenged you"
                        requestCell.lblGameDate.text = "\(dString) at \(tString)"
                        requestCell.lblGameType.text = type
                        requestCell.opponent = sender

                        return requestCell
                    }

                }
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - Cell delegate methods
    func deleteScheduledEvent(game:PFObject, indexPath:NSIndexPath) {
        let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { alert in
            // Delete the game
            game.deleteInBackgroundWithBlock(nil)
            game.unpinInBackgroundWithBlock(nil)
            self.events.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func declineScheduledEvent(game:PFObject, indexPath:NSIndexPath) {
        // Sync with the server to ensure we have the latest decline list
        if(Reachability.isConnectedToNetwork())
        {
            // Fetch latest from server
            game.fetchInBackgroundWithBlock({ (syncedData:PFObject?, error:NSError?) -> Void in
                
                if let json = game.objectForKey("declined") as? [PFObject]
                {
                    let object : Dictionary<String, AnyObject> = ["__type" : "Pointer", "className" : "_User", "objectId" : PFUser.currentUser()!]
                } else {
                    let json : Array<Dictionary<String, AnyObject>> = [["__type" : "Pointer", "className" : "_User", "objectId" : PFUser.currentUser()!.objectId!]]
                    game.setValue(json, forKey: "declined")
                }
                game.saveEventually(nil)
                game.unpinWithName(game.objectId!)
                
                self.events.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            })
        }
        else
        {
            let alert = UIAlertController(title: "Whoops", message: "Sorry, you must be connected to the internet to decline a request, please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func acceptScheduledEvent(game:PFObject, indexPath:NSIndexPath) {
        game.setValue(PFUser.currentUser()!, forKey: "respondent")
        game.saveEventually(nil)
        game.pinWithName(game.objectId!)
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }

    // Refreshes the tableView at the given row
    func eventDidUpdate(event:PFObject) {
        if let path = currentPath as NSIndexPath?
        {
            // Set the new object
            events[path.row] = event
            
            self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func eventDidCancel() {
        if let path = currentPath as NSIndexPath?
        {
            self.events.removeAtIndex(path.row)
            self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = tableView.indexPathForSelectedRow()
        {
            // Set the current index path
            currentPath = indexPath
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? GameCell
            {
                selectedUser = cell.opponent
            }
            else if let cell = tableView.cellForRowAtIndexPath(indexPath) as? CalendarRequestCell
            {
                selectedUser = cell.opponent
            }
            
            // Prepare for segue
            if segue.identifier == "showChallengerProfile"
            {
                if let userToShow = selectedUser as PFUser?
                {
                    if let statVC = segue.destinationViewController as? UserStatsViewController
                    {
                        statVC.setUserForView(userToShow)
                    }
                }
            }
            // Prepar
            if segue.identifier == "showMatchDetail"
            {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? CalendarCell
                {
                    if let detailVC = segue.destinationViewController as? EventDetailViewController
                    {
                        detailVC.delegate = self
                        
                        if let recipients = cell.game!.objectForKey("recievers") as? [PFUser]
                        {
                            var users = [User]()
                            for user in recipients
                            {
                                users.append(User(newUser: user))
                            }
                            let row = indexPath.row

                            detailVC.game = self.events[row] as PFObject?
                            detailVC.users = users
                        }
                    }
                }
            }
        }
        

    }

}
