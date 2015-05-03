//
//  FindingMatchesViewController.swift
//  MKWS
//
//  Created by Alex Sims on 16/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

protocol FindingMatchesViewControllerDelegate
{
    func opponentListDidPopulate(matches:[User], game:PFObject)
}

class FindingMatchesViewController: UIViewController {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var imgFrame: UIImageView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var pulseA: UIImageView!
    @IBOutlet weak var pulseB: UIImageView!
    @IBOutlet weak var pulseC: UIImageView!
    
    private var spinCount = 0
    private var gameType   = ""
    private var gameId     = ""
    private var gameDate   = NSDate()
    var delegate:FindingMatchesViewControllerDelegate!
    
    let animator = UIDynamicAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Set up frames and start the rotation
    override func viewWillAppear(animated: Bool) {

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        if let user = User(newUser: PFUser.currentUser()!) as User?
        {
            imgAvatar.image = user.getAvatar().circleMask
        }
        var frame = imgAvatar.frame
        
        imgAvatar.layoutIfNeeded()
        pulseAnimation()
    }

    // Creates a pulsing rotate animation on the image frame, this is purely for aesthetics
    func pulseAnimation()
    {
        // Rotates 180* and then pulses the size
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.imgFrame.transform = CGAffineTransformMakeRotation((180*CGFloat(M_PI))/180.0)
        })
        UIView.animateWithDuration(1.1, animations: { () -> Void in
            self.imgFrame.transform = CGAffineTransformMakeScale(1.8, 1.8)
            self.imgAvatar.transform = CGAffineTransformMakeScale(1.8, 1.8)
            self.imgFrame.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.imgAvatar.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.pulseC.alpha = 0.2
            self.pulseB.alpha = 0.2
            self.pulseA.alpha = 0.2
        })
        UIView.animateWithDuration(1.4, animations: { () -> Void in
            self.pulseC.transform = CGAffineTransformMakeScale(1.4, 1.4)
            self.pulseC.alpha = 0.0
        })
        UIView.animateWithDuration(2.0, animations: { () -> Void in
            self.pulseB.transform = CGAffineTransformMakeScale(1.4, 1.4)
            self.pulseB.alpha = 0.0
        })
        UIView.animateWithDuration(2.6, animations: { () -> Void in
            self.pulseA.transform = CGAffineTransformMakeScale(1.4, 1.4)
            self.pulseA.alpha = 0.0
        }) { (completed:Bool) -> Void in
            if(completed)
            {
                // Reset the scale of the items
                self.pulseA.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.pulseB.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.pulseC.transform = CGAffineTransformMakeScale(1.0, 1.0)
                
                // Recursively call the animation
                self.pulseAnimation()
                self.spinCount++
                if self.spinCount == 1
                {
                    self.createTempGame()
                }
            }
        }
    }
    
    // Query stuff
    func setGameInfo(#gameId:String, gameType:String, date:NSDate)
    {
        // Set the private vars
        self.gameType = gameType
        self.gameDate = date
        self.gameId   = gameId
    }
    
    // Creates a temporary game in the calendar - retrieves the game from local storage first to save memory
    func createTempGame()
    {
        let tempGame = PFObject(className: "Game")
        
        // Fetch the object from the local datastore
        let query = PFQuery(className: "GameTypes")
        query.whereKey("objectId", equalTo: gameId)
        query.fromLocalDatastore().findObjectsInBackgroundWithBlock { (data:[AnyObject]?, error:NSError?) -> Void in
            if error == nil
            {
                // If we retrieve no results from the datastore - access server
                if data!.count == 0 && Reachability.isConnectedToNetwork()
                {
                    query.findObjectsInBackgroundWithBlock({ (data:[AnyObject]?, error:NSError?) -> Void in
                        if error == nil && data!.count > 0
                        {
                            // Ensure we can safely unwrap data and cast it to a PFObject
                            if let results = data as! [PFObject]!
                            {
                                // We only expect one results back
                                tempGame["challenger"] = PFUser.currentUser()
                                tempGame["gameType"]   = results[0] as PFObject!
                                tempGame["status"]     = 0
                                tempGame["gameDate"]   = self.gameDate
                                
                                tempGame.pin()
                                
                                // Pass the tempGame object to the delegate - we need this so that we can
                                // pass the game context to the sendRequest controller
                                tempGame.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                    self.getMatchingUsers(tempGame)
                                })
                            }
                        }
                    })
                }
                else
                {
                    // Ensure we can safely unwrap data and cast it to a PFObject
                    if let results = data as! [PFObject]!
                    {
                        // We only expect one results back
                        tempGame["challenger"] = PFUser.currentUser()
                        tempGame["gameType"]   = results[0] as PFObject!
                        tempGame["status"]     = 0
                        tempGame["gameDate"]   = self.gameDate
                        
                        tempGame.pin()
                        
                        // Pass the tempGame object to the delegate - we need this so that we can 
                        // pass the game context to the sendRequest controller
                        tempGame.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            self.getMatchingUsers(tempGame)
                        })
                    }
                }
            }
        }
    }
    
    // Returns a list of users that can be played, by checking if they have a game on the same 
    // day and checking their preferences
    func getMatchingUsers(game:PFObject)
    {
        var matches = [User]()
        
        // Run this query afterward to check for games
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("opponent", notEqualTo: PFUser.currentUser()!)
        gameQuery.whereKey("challenger", notEqualTo: PFUser.currentUser()!)

        // Create a new query on games, include the _User objects from challenger and opponent
        // to ensure that these opponents do not already have a game
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        
        
        // Fetch the request
        userQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            if error == nil
            {
                if results?.count > 0
                {
                    if let data = results as! [PFUser]!
                    {
                        for person in data
                        {
                            let u = User(newUser: person)
                            if let preferences = person.objectForKey("preferences") as! NSArray!
                            {
                                // Check if the preferences match
                                for var i = 0; i < preferences.count; i++
                                {
                                    let gameType = preferences[i].valueForKey("name") as! String!
                                    if gameType == self.gameType 
                                    {
                                        // Query the game database to ensure this person does not currently have a game
                                        matches.append(u)
                                    }
                                }
                            }
                        }
                        // Dismiss the controller and notify the delegate
                        self.dismissViewControllerAnimated(false, completion: { () -> Void in
                            self.delegate.opponentListDidPopulate(matches, game: game)
                        })
                    }
                }
            }
        }
    }

    // Stops the search and dismisses the view controller
    @IBAction func DismissController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
