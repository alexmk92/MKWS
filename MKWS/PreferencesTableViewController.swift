//
//  AccordionTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 23/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class PreferencesTableViewController: UITableViewController {

    private let user = PFUser.currentUser()!
    private var newPrefs: Array<AnyObject>?
    private var gameTypes : [GameType]!
    private var gameCategories : [String]!
    private var numRows = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Game Preferences"
        
        tableView.bounces = false
        // Determine if we need to fetch from datastore
        getPreferenceList(Reachability.isConnectedToNetwork())
    }
    
    // Callback to check whether the table section can be collapsed
    func tableView(tableView: UITableView, canCollapseSection section: Int) -> Bool {
        if section > 0 {
            return true
        }
        return false
    }

    // Retrieve the list of preferences from the back end, this does not set the preferences the user
    // has selected. This is done in the initPreferences method.
    func getPreferenceList(fetchFromNetwork: Bool)
    {
        // Create the query
        let gameTypeQuery = PFQuery(className: "GameTypes")
        gameTypeQuery.includeKey("Category")
        gameTypeQuery.orderByDescending("Category")
        
        // Retrieve from local data store 
        if !fetchFromNetwork {
            gameTypeQuery.fromLocalDatastore().findObjectsInBackgroundWithBlock({ (data:[AnyObject]?, error:NSError?) -> Void in
                
                if error == nil
                {
                    if data!.count == 0
                    {
                        self.newPrefs = PFUser.currentUser()!["preferences"] as! Array<AnyObject>?
                    }
                    else
                    {
                        // init the comments array - otherwise we will append to a nil object and crash
                        self.gameTypes = [GameType]()
                        
                        // Loop over each result generating the comment
                        for gType in data! {
                            let g = GameType()
                            let c = gType.objectForKey("Category") as! PFObject
                            
                            g.setName(gType["name"]           as! String?)
                            g.setAbbrev(gType["abbreviation"] as! String?)
                            g.setCategory(c["category"]       as! String?)
                            g.setGameCatId(c.objectId         as String?)
                            g.setGameId(gType.objectId        as String?)
                            
                            // Append to the game categories array
                            if let tempCats = self.gameCategories as [String]? {
                                // Ensure we have a valid category
                                if let category = c["category"] as! String? {
                                    if !contains(tempCats, category) {
                                        self.gameCategories.append(category)
                                    }
                                }
                            }
                            
                            self.gameTypes.append(g)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // Update the table if we found results
                            self.numRows = self.gameTypes.count
                            // Always reload the table data
                            self.newPrefs = self.user["preferences"] as! Array<AnyObject>?
                            self.tableView.reloadData()
                            self.tableView.layoutIfNeeded()
                        })
                    }
                }
               
                
                // Always reload the table data
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            })

        }
        
        // Retrieve from network
        if fetchFromNetwork {
            
            // Query the games
            gameTypeQuery.findObjectsInBackgroundWithBlock { (data: [AnyObject]?, error: NSError?) -> Void in
                if error == nil
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        if let results = data as [AnyObject]? {
                            if results.count > 0
                            {
                                // Synchronise the user
                                PFUser.currentUser()!.fetch()
                                
                                // init the comments array - otherwise we will append to a nil object and crash
                                self.gameTypes = [GameType]()
                                
                                // Loop over each result generating the comment
                                for gType in results {
                                    let g = GameType()
                                    let c = gType.objectForKey("Category") as! PFObject
                                    
                                    g.setName(gType["name"]           as! String?)
                                    g.setAbbrev(gType["abbreviation"] as! String?)
                                    g.setCategory(c["category"]       as! String?)
                                    g.setGameCatId(c.objectId         as String?)
                                    g.setGameId(gType.objectId        as String?)
                                    
                                    // Append to the game categories array
                                    if let tempCats = self.gameCategories as [String]? {
                                        // Ensure we have a valid category
                                        if let category = c["category"] as! String? {
                                            if !contains(tempCats, category) {
                                                self.gameCategories.append(category)
                                            }
                                        }
                                    }
                                    
                                    
                                    self.gameTypes.append(g)
                                    gType.pinWithName(gType.objectId as String!)
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    // Update the table if we found results
                                    self.numRows = self.gameTypes.count
                                    // Always reload the table data
                                    self.newPrefs = self.user["preferences"] as! Array<AnyObject>?
                                    self.tableView.reloadData()
                                    self.tableView.layoutIfNeeded()
                                })
                            }

                        }
                    })
                }
            }
        }
        

    }
    
    // MARK: - Table view delegate methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (numRows == 0) ? 0 : numRows
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    // Set the table cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell with current comment (create empty cell object to ensure we won't crash if thread does not complete)
        var cell = UITableViewCell()
        
        // Check we have a valid post object
        if gameTypes != nil {
            
            let game = gameTypes[indexPath.row]
            
            if game.getAbbrev() != nil && game.getCategory() != nil && game.getName() != nil {
                
                // Get the user and post objects to configure the cell
                let prefCell = tableView.dequeueReusableCellWithIdentifier("PreferenceCell", forIndexPath: indexPath) as! PreferenceCell
                let nameText = ("\(game.getName()!) (\(game.getAbbrev()!))")
            
                        
                // We know this will return the default image if an avatar isnt set
                prefCell.gameType?.text = nameText
                prefCell.subscribed.on = false; //  default state
                prefCell.objectId = game.getGameId()
                
                // Create listener for each switch
                prefCell.subscribed?.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
                
                // Check what state to set the switch
                if let userPreferences = newPrefs as Array<AnyObject>?
                {
                    for preference in userPreferences
                    {
                        // Check we got a string from the json object
                        if let strA = preference.objectId as String? {
                            let strB = game.getGameId()!
                            
                            if strA == strB
                            {
                                prefCell.subscribed.on = true;
                                break;
                            }
                        }
                    }
                    
                    // Update switch label
                    setSwitchState(prefCell, indexPath: indexPath)
                }
                
                cell = prefCell
            }
        }
        else
        {
            // Create a prompt for no comments
            if gameTypes == nil || gameTypes.count == 0
            {
                let alertCell = tableView.dequeueReusableCellWithIdentifier("AlertCell", forIndexPath: indexPath) as! AlertCell
                
                alertCell.lblTitle!.text   = "Sorry"
                alertCell.lblMessage!.text = "There are no game types in the system, contact the administrator"
                
                cell = alertCell
            }
        }
        
        return cell
    }
    
    // MARK: - Custom delegate conforms
    func switchChanged(flipSwitch: UISwitch) {
        let switchOriginInTable = flipSwitch.convertPoint(CGPointZero, toView: tableView)
        if let indexPath = tableView.indexPathForRowAtPoint(switchOriginInTable) {
            
            if let cell:PreferenceCell? = tableView.cellForRowAtIndexPath(indexPath) as? PreferenceCell? {
                setSwitchState(cell, indexPath: indexPath)
                
                // Save the new changes to the server
                if let prefs = newPrefs as Array<AnyObject>?
                {
                    var matchFound = false
                    var matchIndex = 0
                    
                    // Loop through the preference array and add/remove the item
                    for preference in prefs
                    {
                        // Check we got an object id
                        if let userPref:String = preference.objectId {
                            // Set the preference
                            if userPref == cell?.objectId!
                            {
                                newPrefs?.removeAtIndex(matchIndex)
                                matchFound = true
                                break;
                            }
                            matchIndex++
                        }
                    }
                    
                    if !matchFound
                    {
                        if let objectId = cell?.objectId! {
                            let object : Dictionary<String, AnyObject> = ["__type" : "Pointer", "className" : "GameTypes", "objectId" : objectId]
                            newPrefs?.append(object)
                        }
                    }
                    
                    user["preferences"] = newPrefs
                    user.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                    })
                }
            }
        }
    }
    
    // Separate set switch state logic as it can get called from cellForRowAtIndexPath
    func setSwitchState(cell: PreferenceCell?, indexPath: NSIndexPath)
    {
        if let types = gameTypes {
            let subscription = gameTypes[indexPath.row]
            if cell?.subscribed.on == true {
                cell?.subscribedInfo.text = "Subscribed for \(subscription.getAbbrev()!) updates"
            } else {
                cell?.subscribedInfo.text = "Not subscribed for \(subscription.getAbbrev()!) updates"
            }
        }
    }
    
    // Build the preferences array
    


}
