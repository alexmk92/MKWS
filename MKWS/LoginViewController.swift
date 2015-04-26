/*
|------------------------------------------------------------------------------
| Login and Sign-Up View Controllers
|------------------------------------------------------------------------------
| Acts as both the sign up and log-in view controllers for the application,
| its functionality extends Parse's PFLoginViewController and implements both
| the PFLoginViewController and PFSignUpViewController delegates.
|
| This allows us to build a quick and easy login/sign-up form which have been
| built and tested on multiple iOS devices.
|
| @copyright -
|            | You may download and use this code for your own educational
|            | purposes, do not try to claim this piece as your own work unless
|            | you modify at least 50% of the code, even then provide credit
|            | where necessary.
|            -
|
| @author    - Alexander Sims
| @contact   - alexander.sims92@gmail.com
|
|------------------------------------------------------------------------------
*/

import UIKit

class LoginViewController: PFLogInViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    override func viewDidLoad() {
        
        // Set delegates to this view.
        super.viewDidLoad()
        self.delegate = self
        self.signUpController!.delegate = self
        
        // Set up our logo ImageView to pass to the signUp and logIn view controller logos
        let logo = UIImageView(image: UIImage(named: "logo"))
        
        self.logInView!.logo = logo
        self.signUpController!.signUpView!.logo = logo
        
        // Center align the logos to ensure that we don't distort the MKWS logo
        self.logInView!.logo!.contentMode = .Center
        self.signUpController!.signUpView!.contentMode = .Center
        
        // Check if there is a user logged in, if so display their inbox, else we show the login/signup forms by default
        if PFUser.currentUser() != nil {
            showProfile()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    // If a user successfully logged in, present them with their inbox and register them
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        registerDevice()
        showProfile()
    }
    
    // Dismiss the signup view controller when the user has signed up, then present them with their
    // inbox - it makes sense that they should login directly from a signup window - less steps for the user = better UX!
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.registerDevice()
            self.showProfile()
        })
    }
    
    // Take the user to their profile page
    func showProfile()
    {
        let permission = UserPermission.sharedInstance
        
        if let permissionVal = PFUser.currentUser()?.valueForKey("permission") as? Int {
            permission.setPermission(permissionVal)
        }
        else {
            permission.setPermission(0)
        }
        
        // Check if this user has role a role set, if not set them one
        if let user = PFUser.currentUser() {
            // Assign permissions to the user
            let roleACL = PFACL()
            let role = PFRole(name: user.objectId!, acl: roleACL)
            role.users.addObject(user)
            
            // Query the users role
            let roleQuery = PFQuery(className: "_Role")
            roleQuery.whereKey("name", equalTo: user.objectId!)
            roleQuery.findObjectsInBackgroundWithBlock({ (results:[AnyObject]?, error:NSError?) -> Void in
                if error == nil
                {
                    if let res = results {
                        if res.count == 0 {
                            // Once the users role has been set, save them in system and log in
                            role.saveInBackgroundWithBlock(nil)
                        }
                    }
                }
            })
        }
        
        // Check if the user has set their permissions, if not set them to all subscribed
        if PFUser.currentUser()?.valueForKey("preferences") == nil {
            
            let getPreferenceList = PFQuery(className: "GameTypes")
            
            // Get all of the game types
            getPreferenceList.findObjectsInBackgroundWithBlock({ (data: [AnyObject]?, error: NSError?) -> Void in
                
                // Check there wasn't an error and we have results
                if error == nil
                {
                    if let results = data as [AnyObject]? {
                        var json : Array<Dictionary<String, AnyObject>> = []
                        
                        // Get each object id and start building the preference array
                        for gameType in results
                        {
                            if let objectId : String = gameType.objectId as String? {
                                let object : Dictionary<String, AnyObject> = ["__type" : "Pointer", "className" : "GameTypes", "objectId" : objectId]
                                json.append(object)
                            }
                        }
                        
                        // Ensure we have some preferences
                        if let jsonData = json as Array<Dictionary<String, AnyObject>>? {
                            let usr = PFUser.currentUser()
                            usr!.setValue(json, forKey: "preferences")
                            usr!.saveEventually({ (completed: Bool, error: NSError?) -> Void in
                                // this should never happen, but catch it for error logs if it does.
                                if error != nil {
                                    println(error!.localizedDescription)
                                }
                            })
                        }
                        
                    }
                }
            })
        }
        
        let usr = PFUser.currentUser()
        
        
        performSegueWithIdentifier("LoggedIn", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if PFUser.currentUser() != nil && segue?.identifier == "LoggedIn" {
            let vc:TimelineTableViewController = segue?.destinationViewController as! TimelineTableViewController
        }
    }
    
    // Registers the device with the logged in or signed up user
    func registerDevice()
    {
        // Assign the install ID to this user and save it to the installation table in Parse
        let installationID = PFInstallation.currentInstallation()
        installationID["user"] = PFUser.currentUser()
        installationID.saveEventually(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
