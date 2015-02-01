//
//  UpdateProfileTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 21/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

// Used to switch for Camera or Photo picker
enum Control:Int16 {
    case Camera
    case Photos
}

class UpdateProfileTableViewController: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate {
    
    // MARK: - Global variables and SB References
    @IBOutlet weak var btnChangeAvatar: UIButton!
    @IBOutlet weak var btnSaveChanges: UIBarButtonItem!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    @IBOutlet weak var txtForename: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtAbout: UITextView!
    
    @IBOutlet weak var lblCharCount: UILabel!
    
    // Current vars
    var currForename: String!
    var currSurname:  String!
    var currEmail:    String!
    var currAbout:    String!
    
    
    var hud: MBProgressHUD = MBProgressHUD()
    let usr: PFUser        = PFUser.currentUser()   // global access to the user object which will be saved eventually
    var imageFile: PFFile!
    var usrImg   : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initForm()
        
        // Set any delegates
        txtAbout.delegate = self
        
        // Set the navigation bar style - disable the save button until we have made a change
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToRoot")
        back.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = back
        
        self.navigationItem.rightBarButtonItem = btnSaveChanges
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        // Add responders to text fields - inherit from UIControl so need to be registered themselves
        txtForename.addTarget(self, action: "checkTextChanged", forControlEvents: UIControlEvents.EditingDidEnd)
        txtSurname.addTarget(self, action: "checkTextChanged", forControlEvents: UIControlEvents.EditingDidEnd)
        txtEmail.addTarget(self, action: "checkTextChanged", forControlEvents: UIControlEvents.EditingDidEnd)
        
        // Set the image with set photo, else resort to default photo
        if usr["avatar"] != nil {
            usrImg = UIImage(data: usr["avatar"].getData() as NSData)
        } else {
            usrImg = UIImage(named: "defaultAvatar")
        }
        
        imgAvatar.image = usrImg
    }
    
    func textViewDidChange(textView: UITextView) {
        checkTextView()
        checkTextChanged()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Edit Profile"
        
        // Set up form on a new thread
        //initForm()
        
        // Style the image view
        self.imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2;
        self.imgAvatar.clipsToBounds = true
        self.imgAvatar.layer.borderWidth = 3.0
        self.imgAvatar.layer.borderColor = UIColor(red: 124.0/255.0, green: 174.0/255.0, blue: 65.0/255.0, alpha: 1.0).CGColor
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
            
            // Fetch all details on this user.
            let query = PFQuery(className: "_User")
                query.whereKey("objectId", equalTo: user.objectId)
            
            // Populate the form
            query.getFirstObjectInBackgroundWithBlock({ (userObject: NSObject!, error: NSError!) -> Void in
                // Ensure we find a user, if we do get the user at the first index (should only ever expect 1
                if error == nil && userObject != nil {
                    
                    // We only expect one user as they are selected by their object id - get the last object from the array to ensure this
                    let data = userObject as PFObject
                    
                    // Check we have a valid string and then set the field
                    if data["forename"] != nil {
                        self.txtForename.text = data["forename"] as String
                    }
                    if data["surname"] != nil {
                        self.txtSurname.text  = data["surname"]  as String
                    }
                    if data["email"] != nil {
                        self.txtEmail.text  = data["email"]  as String
                    }
                    if data["about"] != nil {
                        self.txtAbout.text  = data["about"]  as String
                    }
                    
                    // Set text for current items
                    self.currForename = self.txtForename.text
                    self.currSurname  = self.txtSurname.text
                    self.currEmail    = self.txtEmail.text
                    self.currAbout    = self.txtAbout.text
                    
                    // Initialize the ABOUT view
                    self.checkTextView()
                    
                } else {
                    println("There was an error \(error.localizedDescription)")
                }
            })
            
            
        }
    }
    
    func popToRoot() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func checkTextView() {
        
        let maxLen = 100
        var len = countElements(txtAbout.text)
        
        // Set label color
        switch(len) {
        case 0...50:
            lblCharCount.textColor = UIColor(red: 124.0/255.0, green: 174.0/255.0, blue: 65.0/255.0, alpha: 1.0)
        case 51...80:
            lblCharCount.textColor = UIColor(red: 205.0/255.0, green: 150.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        case 81...100:
            lblCharCount.textColor = UIColor(red: 205.0/255.0, green: 60.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        default:
            lblCharCount.textColor = UIColor(red: 205.0/255.0, green: 60.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        }
        
        // Set the label and check we did not exceed the limit
        if len > maxLen {
            self.txtAbout.deleteBackward()
            len--
        } else {
            lblCharCount.text = "\(len)/100"
        }
    }
    
    // Checks whether the text box has changed, if it has we enable the editing option - this can be replaced later when 
    // core data stack is implemented
    func checkTextChanged() {
        if txtAbout.text != currAbout || txtEmail.text != currEmail || txtForename.text != currForename || txtSurname.text != currSurname || imageFile != nil {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func compressAndPrepareForUpload(image: UIImage!) {
        
        // Open a new image context and draw it to a new compressed rect
        UIGraphicsBeginImageContext(CGSizeMake(640, 960))
        image.drawInRect(CGRectMake(0, 0, 640, 960))
        
        // Get the image from the current open context and store it as our compressed image,
        // then close the current image context.
        let compressedImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Upload the image, severely reducing the image quality
        let finalImg = UIImageJPEGRepresentation(image, 0.05)
        imageFile = PFFile(name: "\(PFUser.currentUser().username) Avatar", data: finalImg)
        
        navigationItem.rightBarButtonItem?.enabled = true
        
        // Set the avatar in the view to this one.
        self.imgAvatar.image = UIImage(data: finalImg)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let img: UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
        
        // dismiss the controller
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        compressAndPrepareForUpload(img)
    }

    // MARK: - Methods pertaining to connections built in Settings.storyboard
    @IBAction func changeImage(sender: AnyObject) {
        
        // Create our image picker
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.Camera){
            self.promptForSource()
        } else {
            self.promptFor(Control.Photos)
        }
    
    }
    
    // Set up the action sheet from which the camera view will be presented
    func promptForSource() {
        let actionSheet = UIActionSheet(title: "Image Source", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "")
    }
    
    // Choose the destination source controller (gallery or camera)
    func promptFor(source: Control) {
        let controller = UIImagePickerController()
        
        switch source {
        case .Camera:
            controller.sourceType = UIImagePickerControllerSourceType.Camera
        case .Photos:
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        controller.delegate = self
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        // Check if the user hasnt canceled
        if buttonIndex != actionSheet.cancelButtonIndex {
            // User tapped camera
            if buttonIndex != actionSheet.firstOtherButtonIndex {
                self.promptFor(Control.Camera)
            } else {
                self.promptFor(Control.Photos)
            }
        }
    }
    
    
    // MARK: - Save Changes
    @IBAction func saveChanges(sender: AnyObject) {
        
        // Show the HUD
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar
        hud.labelText = "Updating..."
        
        // Check if an image file has been set (global image reference not nil)?  Have if/else block to
        // avoid us making multiple transactions...
        if self.imageFile != nil
        {
            
            // Valid image file found, save the new image
            self.imageFile.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                
                // Check there was no error and begin handling the file upload
                if error == nil {
                    
                    // Set the image file and save the user object in the background
                    self.usr.setObject(self.imageFile,       forKey: "avatar")
                    self.usr.setValue(self.txtForename.text, forKey: "forename")
                    self.usr.setValue(self.txtSurname.text,  forKey: "surname")
                    self.usr.setValue(self.txtEmail.text,    forKey: "email")
                    self.usr.setValue(self.txtAbout.text,    forKey: "about")
                    
                    self.usr.saveInBackgroundWithBlock({ (completed: Bool, error: NSError!) -> Void in
                        if completed && error == nil {
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            self.popToRoot()
                        } else {
                            println("\(error.localizedDescription)")
                        }
                    })
                    
                } else {
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.popToRoot()
                }
                
                }, progressBlock: { (amountDone: Int32) -> Void in
                    self.hud.progress = Float(amountDone/100)
            })
        } else {
            // Save changes to the rest of the user object
            usr.setValue(txtForename.text, forKey: "forename")
            usr.setValue(txtSurname.text,  forKey: "surname")
            usr.setValue(txtEmail.text,    forKey: "email")
            usr.setValue(txtAbout.text,    forKey: "about")
            
            // Update the user values
            usr.saveInBackgroundWithBlock({ (completed: Bool, error: NSError!) -> Void in
                if completed && error == nil {
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.popToRoot()
                }
            })
        }
        

    }
}
