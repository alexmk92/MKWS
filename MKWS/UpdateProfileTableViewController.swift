//
//  UpdateProfileTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 21/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class UpdateProfileTableViewController: UITableViewController {

    // MARK: - Global variables and SB References
    @IBOutlet weak var btnChangeAvatar: UIButton!
    @IBOutlet weak var btnSaveChanges: UIBarButtonItem!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    @IBOutlet weak var txtForename: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtAbout: UITextView!
    
    @IBOutlet weak var lblCharCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the navigation bar style - disable the save button until we have made a change
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToRoot")
        back.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = back
        
        self.navigationItem.rightBarButtonItem = btnSaveChanges
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        //initForm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source
    
    
    // MARK: - Initialization methods
    func initForm() {
        
        // Populate the forename, surname and email fields from the logged in user
        let user = PFUser.currentUser()
        
        if user != nil {
            
            // Establish the PFQuery to pull back all data
            //let pred  = NSPredicate(format: <#String#>, <#args: CVarArgType#>...)
            //let query = PFQuery(className: "User", predicate: pred)
            
            // Fetch all details on this user.
            let query = PFQuery(className: "User")
                query.whereKey("objectId", equalTo: user.objectId)
                query.includeKey("username")
                query.includeKey("email")
                query.includeKey("forename")
                query.includeKey("surname")
                query.includeKey("about")
                query.includeKey("avatar")
                query.includeKey("permission")
            
            // Populate the form
            query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error:NSError!) -> Void in
                
                // Ensure we find a user, if we do get the user at the first index (should only ever expect 1
                if error == nil && results.count > 0 {
                
                    // We only expect one user as they are selected by their object id - get the last object from the array to ensure this
                    let data = results.last as PFObject
                    
                    self.txtForename.text = data["forename"] as String
                    self.txtSurname.text  = data["surname"]  as String
                    
                } else {
                    println("There was an error \(error.localizedDescription)")
                }
            })
            
            
        }
    }
    
    func popToRoot() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }


    // MARK: - Methods pertaining to connections built in Settings.storyboard
    @IBAction func changeImage(sender: AnyObject) {
    }
    
    @IBAction func saveChanges(sender: AnyObject) {
    }
}
