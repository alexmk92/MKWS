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
        self.signUpController.delegate = self
        
        // Set up our logo ImageView to pass to the signUp and logIn view controller logos
        let logo = UIImageView(image: UIImage(named: "logo"))
        
        self.logInView.logo = logo
        self.signUpController.signUpView.logo = logo
        
        // Center align the logos to ensure that we don't distort the MKWS logo
        self.logInView.logo.contentMode = .Center
        self.signUpController.signUpView.contentMode = .Center
        
        // Check if there is a user logged in, if so display their inbox, else we show the login/signup forms
        // by default
        if PFUser.currentUser() != nil {
            showProfile()        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    // If a user successfully logged in, present them with their inbox and register them
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        registerDevice()
        showProfile()
    }
    
    // Dismiss the signup view controller when the user has signed up, then present them with their
    // inbox - it makes sense that they should login directly from a signup window - less steps for the user = better UX!
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        signUpController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.registerDevice()
            self.showProfile()
        })
    }
    
    // Take the user to their profile page
    func showProfile()
    {
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let userProfile = storyboard.instantiateViewControllerWithIdentifier("profileVC") as TimelineTableViewController
        
        self.navigationController?.pushViewController(userProfile, animated: true)
    }
    
    // Registers the device with the logged in or signed up user
    func registerDevice()
    {
        // Assign the install ID to this user and save it to the installation table in Parse
        let installationID = PFInstallation.currentInstallation()
            installationID["user"] = PFUser.currentUser()
            installationID.saveInBackgroundWithBlock(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
