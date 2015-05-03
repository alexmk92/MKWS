//
//  MatchResultTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 27/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

protocol MatchResultControllerDelegate
{
    func requestWasSentToRecipients(success:Bool)
}

class MatchResultTableViewController: UITableViewController {

    var opponents  = [User]()
    var recipients = [User]()
    var game : PFObject!
    
    var delegate : MatchResultControllerDelegate?
    
    var send:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Change nav bar here, because this will happen before subviews are layed out
    // put
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.blueBar()
        
        // Back button
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToRoot")
        back.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = back
        
        send = UIBarButtonItem(image: UIImage(named:"tickCircle"), style: UIBarButtonItemStyle.Plain, target: self, action: "sendRequest")
        send.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = send
        send.enabled = false
        
        self.title = "Results"
    }
    
    func popToRoot()
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setOpponentData(opponents:[User], game: PFObject)
    {
        // Sort the array alphabetically
        opponents.sorted{ $0.getFullname() < $1.getFullname() }
        self.opponents = opponents
        self.game = game
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if opponents.count == 0
        {
            return 0
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if opponents.count == 0
        {
            return 0
        }
        
        return opponents.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("opponentCell", forIndexPath: indexPath) as! MatchResultCell

        // Configure the cell...
        if let user = opponents[indexPath.row] as User!
        {
            cell.imgAvatar.image = user.getAvatar()
            cell.lblName.text    = user.getFullname()
            cell.lblStats.text   = "\(user.getWins()) Wins, \(user.getLosses()) Losses"
        }

        return cell
    }
    
    // Add the user to the list of users we wish to send a request to
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MatchResultCell
        {
            // Ensure we got a user, if so set the cells accessory view and add them to the list
            if let user:User = opponents[indexPath.row] as User?
            {
                if cell.accessoryType == UITableViewCellAccessoryType.Checkmark
                {
                    // Remove player from send list and update cell accessory
                    removeRecipientWithName(user)
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
                else
                {
                    // Add player to send list and update cell accessory
                    recipients.append(user)
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
                // Toggles the send button
                updateSendButton()
            }
        }
    }
    
    // Updates the send button in the navigation bar
    func updateSendButton()
    {
        if recipients.count > 0
        {
            send.enabled = true
        }
        else
        {
            send.enabled = false
        }
    }
    
    // Send the request
    func sendRequest() -> Bool
    {
        if recipients.count > 0
        {
            // Transform the recipient array into a PFObject pointer array
            var json : Array<Dictionary<String, AnyObject>> = []
            for user in recipients
            {
                // build the new object
                if let objectId : String = user.getUserID() as String?
                {
                    let object : Dictionary<String, AnyObject> = ["__type":"Pointer", "className":"_User", "objectId" : objectId]
                    json.append(object)
                }
            }
            
            // Ensure that the array has items
            if json.count > 0
            {
                let newRequest = PFObject(className: "Request")
                newRequest.setObject(PFUser.currentUser()!, forKey: "sender")
                newRequest.setObject(json, forKey: "recievers")
                newRequest.setObject(game!, forKey: "game")
                
                // Eventually commit the changes to the server
                newRequest.saveEventually({ (success:Bool, error:NSError?) -> Void in
                    if let gameType = self.game!.objectForKey("gameType")!.valueForKey("name") as? String
                    {
                        if let gameDate = self.game!.valueForKey("gameDate") as? NSDate
                        {
                           
                                let pushQuery = PFInstallation.query()
                                pushQuery!.whereKey("user", containedIn: json)
                                
                                let push = PFPush()
                                //push.setChannel("events")
                                push.setQuery(pushQuery)
                                
                                // Set the alert, badge and sound for the Notification Payload
                                let user = User(newUser: PFUser.currentUser()!)
                                let payload:Dictionary = ["alert":"\(user.getFullname()) has challenged you to play \(gameType) on \(gameDate.setDateAtTimeFormat)", "badge":"increment", "content-available":"1", "sound":""]
                                
                                push.setData(payload)
                                push.sendPushInBackgroundWithBlock(nil)
                            
                            
                            self.delegate?.requestWasSentToRecipients(success)
                        }
                    }
                })
                
                popToRoot()
            }
            
            return true
        }
        else
        {
            return false
        }
    }
    
    // Remove the user from the array, the boolean return type is only used here for debugging purposes
    func removeRecipientWithName(user:User) -> Bool
    {
        if recipients.count > 0
        {
            var i = 0
            for compareUser in recipients
            {
                if user.getUserID() == compareUser.getUserID()
                {
                    recipients.removeAtIndex(i)
                    return true
                }
                i++
            }
        
            return true
        }
        
        return false
    }


}
