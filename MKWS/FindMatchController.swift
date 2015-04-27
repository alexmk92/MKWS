//
//  FindMatchController.swift
//  MKWS
//
//  Created by Alex Sims on 05/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class FindMatchController: UIViewController, UIPopoverPresentationControllerDelegate, BasePanelDelegate, FindingMatchesViewControllerDelegate {

    @IBOutlet weak var btnFindMatch: UIButton!
    @IBOutlet weak var btnGameType: UIButton!
    @IBOutlet weak var btnGameCategory: UIButton!
    @IBOutlet weak var btnGameDate: UIButton!
    
    
    var gameTypes:[[String:[String:String]]]?
    var gameCategories:[[String:String]]?
    var filteredTypes:[[String:[String:String]]]?
    var gameDate:NSDate?
    var selectedButton:Int = 0
    var currentCategory = "All"
    var currentType = ""
    var currentTypeId = ""
    var initialLoad = true
    var matches = [User]()
    
    var basePane:BasePanel = BasePanel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Find Match"
        basePane = BasePanel(sourceView: self.view)
        basePane.delegate = self
    }
    
    // Execute the code in ViewWillAppear as this will ensure that everything is
    // drawn once viewDidLoad is called
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.clearBar()
        
        // Query the gameType and category data - this will default to query
        // from the local datastore if we have no internet connection
        if initialLoad {
            setGameData(fetchDataFromServer: Reachability.isConnectedToNetwork())
        }
    }
    
    // Retrieves all information from the database or the local datastore based
    // on the boolean value passed, allowing requests to be made online
    // This will present the user with a list of all game types and categories available
    // in the system.  Preferences do not count here, for the occasion that users want to
    // play something else, preferences only take effect for when the request is sent.
    func setGameData(#fetchDataFromServer: Bool)
    {
        // Query the categories from the game types
        let categoryQuery = PFQuery(className: "Categories")
        let typeQuery     = PFQuery(className: "GameTypes")
        typeQuery.includeKey("Category")
        
        // Reinitialise the dictionaries
        gameTypes      = [[String:[String:String]]]()
        gameCategories = [[String:String]]()
        
        // Check if we need to fetch from the datastore
        if(!fetchDataFromServer)
        {
            // Get the game types
            categoryQuery.fromLocalDatastore().findObjectsInBackgroundWithBlock({ (data:[AnyObject]?, error:NSError?) -> Void in
                if error == nil
                {
                    if let results = data as? [PFObject]
                    {
                        for type in results
                        {
                            let thisId = type.valueForKey("Category") as! PFObject
                            self.gameTypes?.append([thisId.objectId!:[type.objectId!:type.valueForKey("name") as! String]])
                        }
                    }
                    self.setDefaultLabels()
                }
            })
            // Get the categories
            categoryQuery.fromLocalDatastore().findObjectsInBackgroundWithBlock({ (data:[AnyObject]?, error:NSError?) -> Void in
                if error == nil
                {
                    if let results = data as? [PFObject]
                    {
                        self.gameCategories?.append(["All":"All"])
                        for category in results
                        {
                            self.gameCategories?.append([category.objectId!:category.valueForKey("category") as! String])
                        }
                    }
                }
            })
            
        }
        // We are connected to the internet - pull results down.
        else
        {
            // Get the game types
            typeQuery.findObjectsInBackgroundWithBlock({ (data:[AnyObject]?, error:NSError?) -> Void in
                if error == nil
                {
                    if let results = data as? [PFObject]
                    {
                        for type in results
                        {
                            type.pinInBackgroundWithBlock(nil)
                            let thisId = type.valueForKey("Category") as! PFObject
                            self.gameTypes?.append([thisId.objectId!:[type.objectId!:type.valueForKey("name") as! String]])
                        }
                    }
                    self.setDefaultLabels()
                }
            })
            // Get the categories
            categoryQuery.findObjectsInBackgroundWithBlock({ (data:[AnyObject]?, error:NSError?) -> Void in
                if error == nil
                {
                    if let results = data as? [PFObject]
                    {
                        self.gameCategories?.append(["All":"All"])
                        for category in results
                        {
                            category.pinInBackgroundWithBlock(nil)
                            self.gameCategories?.append([category.objectId!:category.valueForKey("category") as! String])
                        }
                    }
                }
            })
            
        }
    }
    
    // Set the default labels for the system
    func setDefaultLabels()
    {
        if initialLoad
        {
            gameDate = NSDate()
            let dateStr = gameDate!.stringWithFormat("dd-MMMM-yyyy  :  h:mm:a")
            
            if gameTypes!.count > 0
            {
                if let type = gameTypes?[0].values.array[0].values.first as! String? {
                    btnGameCategory.setTitle("All", forState: .Normal)
                    btnGameType.setTitle(type, forState: .Normal)
                    btnGameDate.setTitle(dateStr, forState: .Normal)
                    
                    currentType = btnGameType!.titleLabel!.text!
                    currentCategory = "All"
                    currentTypeId = gameTypes?[0].values.array[0].keys.array.first as String!
                }
            }
            
            initialLoad = false
        }
    }
    
    // The delegate is notified of a new date that has been specified by the controller
    func basePanelDidConfirmDate(date: NSDate) {
        if let newDate = date as NSDate!
        {
            gameDate = newDate
            basePane.showBasePanel(false)
            
            let dateString = newDate.stringWithFormat("dd-MMMM-yyyy  :  h:mm:a")
            
            btnGameDate.setTitle(dateString, forState: UIControlState.Normal)
        }
    }
    
    // Implemented delegate method for when a row has been selected on the tableView in the slide
    // up menu
    func basePanelDidSelectRowAtIndex(index: Int) {
        basePane.showBasePanel(false)
        
        // Update the correct field - uses the selectedButton parameters
        // to check which field to update.  0 = Category, 1 = Game Type, 2 = Date
        switch(selectedButton)
        {
        case 0:
            if let str = gameCategories?[index].values.first {
                
                // Set the current category, current category is the objectID used for comparison
                // on gametype filtering
                if str == "All" {
                    currentCategory = "All"
                }
                // Reset the categories
                else {
                    if let objectID:String = gameCategories?[index].keys.first {
                        currentCategory = objectID
                    }
                }
                
                // Update the button label
                btnGameCategory.setTitle(str, forState: UIControlState.Normal)
                refreshGameTypes()
                
                if let item:String = filteredTypes?[0].values.array[0].values.first
                {
                    btnGameType.setTitle(item, forState: UIControlState.Normal)
                    if let typeID:String = filteredTypes?[0].values.array[0].keys.array.first as String! {
                        currentTypeId = typeID
                        currentType = item
                    }
                }
            }
        case 1:
            if let str = filteredTypes?[index].values.array[0].values.first {
                btnGameType.setTitle(str, forState: UIControlState.Normal)
                if let typeID:String = filteredTypes?[index].values.array[0].keys.array.first as String! {
                    currentTypeId = typeID
                    currentType = str
                }
            }
        default:
            break
        }
    }
    
    @IBAction func showCategories(sender: AnyObject) {
        var items = [String]()
        selectedButton = 0
        
        // Loop through the game type to set the items
        for var i = 0; i < gameCategories?.count; i++
        {
            let str = gameCategories?[i].values.array
            items.append(str?.first as String!)
        }
        
        // Set the items
        basePane.setItems(items)
        basePane.setTitle("Select a Category")
        basePane.tabBarHeight = tabBarController?.tabBar.frame.size.height
        basePane.isPickerView = false
        basePane.showBasePanel(true)

    }
    
    // Show the base panel and set its information with all
    // game types
    @IBAction func showGameTypes(sender: AnyObject)
    {
        selectedButton = 1
        var items = refreshGameTypes()
        
        basePane.setItems(items)
        basePane.setTitle("Select a Game Type")
        basePane.tabBarHeight = tabBarController?.tabBar.frame.size.height
        basePane.isPickerView = false
        basePane.showBasePanel(true)
    }
    
    
    @IBAction func showDatePicker(sender: AnyObject) {
        selectedButton = 2
        basePane.setTitle("Choose a Game Date")
        basePane.isPickerView = true
        basePane.tabBarHeight = tabBarController?.tabBar.frame.size.height
        basePane.showBasePanel(true)
    }
    
    
    // Refreshes the filtered game type array
    private func refreshGameTypes() -> [String]
    {
        var items = [String]()
        filteredTypes  = [[String:[String:String]]]()
        
        // Loop through the game type to set the items
        for var i = 0; i < gameTypes?.count; i++
        {
            // Ensure this is safe
            if let str = gameTypes?[i].values.array[0].values.first as String! {
                if let objId = gameTypes?[i].keys.array.first as String! {
                    if let typeId = gameTypes?[i].values.array[0].keys.first as String!
                    {
                        if currentCategory == "All"
                        {
                            items.append(str)
                            filteredTypes?.append([objId:[typeId:str]])
                        } else {
                            if currentCategory == objId {
                                items.append(str)
                                filteredTypes?.append([objId:[typeId:str]])
                            }
                        }
                    }
                }
            }
        }
        
        return items
    }
    
    // Retrieves the information from the delegate and then displays the resulting controller to send
    // requests
    func opponentListDidPopulate(matches:[User]) {
        self.matches = matches
        
        // Ensure we have matches and then display the controller
        if self.matches.count > 0
        {
            self.performSegueWithIdentifier("matchResults", sender: self)
        }
        else
        {
            let alert = UIAlertController(title: "Dang", message: "There are no other users at the club who play \(self.currentType), try a different category.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Prepare for segue checks here - this will intercept the storyboard transition request if the request is not valid
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if !isValidRequest()
        {
            let alert = UIAlertController(title: "Whoops!", message: "The request you have sent is invalid, please ensure that the date specified has not passed.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            // Check for a searc segue
            if segue.identifier == "findMatches"
            {
                if let searchVC:FindingMatchesViewController? = UIStoryboard.findingResultsViewController()
                {
                    searchVC?.setGameInfo(gameId: currentTypeId, gameType: currentType, date: gameDate!)
                    searchVC?.delegate = self
                    presentViewController(searchVC!, animated: true, completion: nil)
                }
            }
            // Check for a results segue
            if segue.identifier == "matchResults"
            {
                if let resultsVC:MatchResultTableViewController? = UIStoryboard.matchResultTableViewController()
                {
                    resultsVC?.setOpponentData(self.matches)
                    presentViewController(resultsVC!, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Determines if the request is valid
    private func isValidRequest() -> Bool
    {
        // This is not safe, return false
        if currentCategory != "All"
        {
            if currentType == "" || filteredTypes == nil || filteredTypes!.count == 0
            {
                return false
            }
        }
        // Check the date is valid
        if gameDate!.timeIntervalSinceNow.isSignMinus
        {
            return false
        }
        
        // Last point it could fail, return val of typecheck
        return true
    }
    
}
