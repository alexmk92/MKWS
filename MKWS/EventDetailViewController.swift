//
//  EventDetailViewController.swift
//  MKWS
//
//  Created by Alex Sims on 01/05/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

protocol EventDetailViewControllerDelegate
{
    func eventDidUpdate(newGame:PFObject)
    func eventDidCancel()
}

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BasePanelDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblGameType: UILabel!
    @IBOutlet weak var lblGameDate: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    var users:[User]?
    var game:PFObject?
    var basePanel:BasePanel?
    var delegate:EventDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        basePanel = BasePanel(sourceView: self.view!, items: [""], aboveView: self.tableView)
        basePanel?.delegate = self
        
        if let gameDate = game?.objectForKey("game")!.valueForKey("gameDate") as? NSDate
        {
            basePanel?.picker?.date = gameDate
        }
        
        // Bind notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDataSource", name: "reloadEvents", object: nil)
    }
    
    // Unbind notification listeners
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadEvents", object: nil)
    }
    
    func refreshDataSource()
    {
        if Reachability.isConnectedToNetwork()
        {
            if game != nil
            {
                game?.fetchInBackgroundWithBlock({ (results:PFObject?, error:NSError?) -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.grayBar()
        let user = User(newUser:PFUser.currentUser()!)
        user.downloadAvatar()
        imgAvatar.image = user.getAvatar().circleMask
        
        tabBarController?.tabBar.translucent = true
        
        self.title = "Pending Event"
        
        if game != nil && game?.objectForKey("game")!.objectForKey("gameType") != nil
        {
            if let gameName = game?.objectForKey("game")!.objectForKey("gameType")!.valueForKey("name") as? String
            {
                if let gameDate = game?.objectForKey("game")!.valueForKey("gameDate") as? NSDate
                {
                    lblGameType.text = gameName
                    lblGameDate.text = getFormattedDate(gameDate)
                }
            }
        }
        
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToRoot")
        back.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = back
    }
    
    func popToRoot() {
        delegate?.eventDidUpdate(game!)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users != nil
        {
            return users!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Create the cell
        if let cell = tableView.dequeueReusableCellWithIdentifier("statusCell", forIndexPath: indexPath) as? StatusCell
        {
            if users != nil
            {
                let user = users![indexPath.row]
                user.downloadAvatar()
                cell.imgAvatar.image = user.getAvatar()
                cell.imgAvatar.layer.borderColor = UIColor.whiteColor().CGColor
                cell.lblName.text = user.getFullname()
                
                
                if game != nil
                {
                    if let declined = game?.objectForKey("declined") as? [PFUser]
                    {
                        let declinedUser = User(newUser: declined.first!)

                        if declinedUser.getUserID() == users![indexPath.row].getUserID()
                        {
                            cell.lblStatus.text = "Declined"
                            cell.statusView.backgroundColor = UIColor.redColor()
                        }
                        else
                        {
                            cell.lblStatus.text = "Pending"
                            cell.statusView.backgroundColor = UIColor.yellowColor()
                        }
                    }
                    else
                    {
                        cell.lblStatus.text = "Pending"
                        cell.statusView.backgroundColor = UIColor.yellowColor()
                    }
                }
                
                
                
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        if let userToShow = users![indexPath.row].getPFUser()
        {
            if let statVC = UIStoryboard.userStatsViewController()
            {
                statVC.setUserForView(userToShow)
                navigationController?.pushViewController(statVC, animated: true)
            }
        }
    }
    
    func getFormattedDate(date: NSDate) -> String
    {
        let dString  = date.stringWithFormat("dd-MMM-yyyy")
        let tString  = date.stringWithFormat("h:mma")
        return "\(dString) at \(tString)"
    }

    // Conform to the base panel delegate
    func basePanelDidConfirmDate(date: NSDate)
    {
        if !date.timeIntervalSinceNow.isSignMinus
        {
            lblGameDate.text = getFormattedDate(date)
            
            // Update the game object on the server
            if let g = game
            {
                if let gameDetails = game!.objectForKey("game") as? PFObject
                {
                    gameDetails.setValue(date, forKey: "gameDate")
                    game!.setObject(gameDetails, forKey: "game")
                    game!.saveEventually(nil)
                    game!.pinWithName(game!.objectId!)
                }
            }
            
            basePanel?.showBasePanel(false)
        }
        else
        {
            let alert = UIAlertController(title: "Dang", message: "Please ensure the new date for this event is not in the future.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Not sure for the context of this
    func basePanelDidSelectRowAtIndex(index: Int) {
        
    }
        
    // Button functions on this form
    @IBAction func cancelEvent(sender: AnyObject) {
        let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { alert in
            // Delete the game
            self.game!.deleteInBackgroundWithBlock(nil)
            self.game!.unpinInBackgroundWithBlock(nil)
            self.popToRoot()
            self.delegate?.eventDidCancel()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateEventDate(sender: AnyObject) {
        basePanel?.isPickerView = true
        basePanel?.title.text = "Change Match Date"
        basePanel?.showBasePanel(true)
    }
}
