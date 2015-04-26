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
    
    let imagePicker        = UIImagePickerController()
    var hud: MBProgressHUD = MBProgressHUD()
    let usr: PFUser        = PFUser.currentUser()!   // global access to the user object which will be saved eventually
    var imageFile : PFFile!
    var usrImg    : UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initForm()
        
        // Set any delegates
        txtAbout.delegate = self
        
        // Set the navigation bar style - disable the save button until we have made a change
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popToRoot")
        back.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = back
        
        self.tableView.bounces = false
        self.navigationItem.rightBarButtonItem = btnSaveChanges
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.imagePicker.delegate = self
        
        // Add responders to text fields - inherit from UIControl so need to be registered themselves
        txtForename.addTarget(self, action: "checkTextChanged", forControlEvents: UIControlEvents.EditingDidEnd)
        txtSurname.addTarget(self, action: "checkTextChanged", forControlEvents: UIControlEvents.EditingDidEnd)
        txtEmail.addTarget(self, action: "checkTextChanged", forControlEvents: UIControlEvents.EditingDidEnd)
        
        // Set the image with set photo, else resort to default photo
        if let avatar = usr["avatar"] as? NSData {
            usrImg = UIImage(data: avatar)
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
            
            // Check we have a valid string and then set the field
            if let forename = user?.valueForKey("forename") as? String {
                self.txtForename.text = forename
            }
            
            if let surname = user?.valueForKey("surname") as? String {
                self.txtSurname.text = surname
            }
            if let email = user?.email {
                self.txtEmail.text  = email
            }
            if let about = user?.valueForKey("about") as? String {
                self.txtAbout.text  = about
            }
            
            // Set text for current items
            self.currForename = self.txtForename.text
            self.currSurname  = self.txtSurname.text
            self.currEmail    = self.txtEmail.text
            self.currAbout    = self.txtAbout.text
            
            // Initialize the ABOUT view
            self.checkTextView()
        }
    }
    
    // Pop user to root controller
    func popToRoot() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Update the GUI to show chracter count
    func checkTextView() {
        
        let maxLen = 100
        var len = count(txtAbout.text)
        
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
    
    // MARK - Image picker controls
    @IBAction func PresentImagePicker(sender: AnyObject) {
        
        var alert = UIAlertController(title: "Choose an Option", message: "Would you like to upload an image from your camera roll, or take a new one now?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Existing Image", style: .Default, handler: { action in
            self.pickFromGallery()
        }))
        alert.addAction(UIAlertAction(title: "Camera Image", style: .Default, handler: { action in
            self.shootFromCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
       
    }
    
    func pickFromGallery() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType    = .PhotoLibrary
        imagePicker.modalPresentationStyle = .Popover
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func shootFromCamera() {
        // Check we have a valid camera to shoot from - if there is no available device, take user to gallery
        if UIImagePickerController.availableCaptureModesForCameraDevice(UIImagePickerControllerCameraDevice.Rear) != nil ||  UIImagePickerController.availableCaptureModesForCameraDevice(UIImagePickerControllerCameraDevice.Front) != nil {
            imagePicker.allowsEditing          = false
            imagePicker.sourceType             = .Camera
            imagePicker.cameraCaptureMode      = .Photo
            presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            pickFromGallery()
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            // Open a new image context and draw it to a new compressed rect
            let selectedImg = info[UIImagePickerControllerOriginalImage] as! UIImage
            let width = selectedImg.size.width / 2
            let height = selectedImg.size.height / 2
            
            // the new context is relative to the w/h of the original
            UIGraphicsBeginImageContext(CGSizeMake(width, height))
            selectedImg.drawInRect(CGRectMake(0, 0, width, height))
            
            // Get the image from the current open context and store it as our compressed image,
            // then close the current image context.
            let compressedImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Upload the image, severely reducing the image quality
            let finalImg   = UIImageJPEGRepresentation(compressedImg, 0.5)
            
            self.imageFile = PFFile(data: finalImg)
            
            // Update the GUI
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.imgAvatar.contentMode = .ScaleAspectFill
                self.imgAvatar.image = compressedImg
                self.dismissViewControllerAnimated(true, completion: nil)
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
            self.imageFile.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                
                // Check there was no error and begin handling the file upload
                if error == nil {
                    
                    // Set the image file and save the user object in the background
                    self.usr.setObject(self.imageFile,       forKey: "avatar")
                    self.usr.setValue(self.txtForename.text, forKey: "forename")
                    self.usr.setValue(self.txtSurname.text,  forKey: "surname")
                    self.usr.setValue(self.txtEmail.text,    forKey: "email")
                    self.usr.setValue(self.txtAbout.text,    forKey: "about")
                    
                    self.usr.saveEventually({ (completed: Bool, error: NSError?) -> Void in
                        if completed && error == nil {
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            self.popToRoot()
                        } else {
                            println("\(error!.localizedDescription)")
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
            usr.saveEventually({ (completed: Bool, error: NSError?) -> Void in
                if completed && error == nil {
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.popToRoot()
                }
            })
        }
        

    }
}
