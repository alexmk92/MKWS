//
//  NewPostViewController.swift
//  MKWS
//
//  Created by Alex Sims on 29/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {

    // Outlet connections
    @IBOutlet weak var btnDimissModal: UIButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtInput: UITextView!
    @IBOutlet weak var lblCharactersRemaining: UILabel!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var btnPickImage: UIButton!
    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var btnAddRecipients: UIButton!
    @IBOutlet weak var lblRecipients: UILabel!
    @IBOutlet weak var viewMediaBar: UIView!
    
    // Default placeholder text for txtInput - this is needed so each field can be set to same default text field and be checked against that
    let defaultTxtMessage = "What's on your mind..."
    var imageFile: PFFile!
    var hud: MBProgressHUD = MBProgressHUD()
    var firstLoad = true
    
    // Used for sliding the keyboard up
    @IBOutlet weak var bottomSpaceToSuperview: NSLayoutConstraint!
    
    // Other vars
    private var isKeyboardOpen = false
    private let imagePicker    = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set any delegates
        self.txtInput.delegate    = self
        self.imagePicker.delegate = self
        
        // Keyboard show and hide notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardChanged:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        // Gesture Recognisers
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            // Set up user avatar etc - ensure this is safe by testing the user was set
            let user : User = User(newUser: PFUser.currentUser()!)

                user.downloadAvatar()
            
                // All values returned from the user class we can assume are safe (never return nil - instead return default string/image values)
                self.imgAvatar!.image = user.getAvatar()!
                self.lblEmail!.text   = user.getEmail()!
                self.lblName!.text    = user.getFullname()!
                
                // Set up images
                self.imgAvatar.frame               = CGRectMake(0,0,35,35)
                self.imgAvatar.layer.cornerRadius  = self.imgAvatar.frame.size.height/2
                self.imgAvatar.layer.borderWidth   = CGFloat(2.0)
                self.imgAvatar.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
                self.imgAvatar.layer.masksToBounds = false
                self.imgAvatar.clipsToBounds       = true
                
                self.imgPreview.frame               = CGRectMake(0,0,100,100)
                self.imgPreview.layer.cornerRadius  = self.imgPreview.frame.size.height/2 + 10
                self.imgPreview.layer.borderWidth   = CGFloat(2.0)
                self.imgPreview.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
                self.imgPreview.layer.masksToBounds = false
                self.imgPreview.clipsToBounds       = true
            
                // Hide the image only if this is our first time loading
                self.imgPreview.hidden = (self.firstLoad) ? true : false
                self.firstLoad = false
            
        })
        
        // We know that there will be no image when the window is first opened so hide it
        self.bottomSpaceToSuperview?.constant = 0
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        isKeyboardOpen = false
        
        if count(txtInput.text) < 1 {
            txtInput.text = defaultTxtMessage
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if txtInput.text == defaultTxtMessage {
            txtInput.text = ""
        }
        isKeyboardOpen = true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let maxLen = 100
        var len = count(txtInput.text)
        
        // Set label color
        switch(len) {
        case 0...50:
            lblCharactersRemaining.textColor = UIColor(red: 124.0/255.0, green: 174.0/255.0, blue: 65.0/255.0, alpha: 1.0)
        case 51...80:
            lblCharactersRemaining.textColor = UIColor(red: 205.0/255.0, green: 150.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        case 81...100:
            lblCharactersRemaining.textColor = UIColor(red: 205.0/255.0, green: 60.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        default:
            lblCharactersRemaining.textColor = UIColor(red: 205.0/255.0, green: 60.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        }
        
        // Set the label and check we did not exceed the limit
        if len > maxLen {
            self.txtInput.deleteBackward()
            len--
        } else {
            lblCharactersRemaining.text = "\(100-len)"
        }
    }
    
    func getPostContent()-> String! {
        if txtInput.text == defaultTxtMessage || count(txtInput.text) == 0 {
            return ""
        }
        
        return txtInput.text!
    }
    
    // Dismiss the view controller and un-bind any existing observers
    @IBAction func DismissModal(sender: AnyObject) {
        textViewShouldEndEditing(self.txtInput)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func PostStatus(sender: AnyObject) {
        
        let post: Post     = Post()
        let save: PFObject = PFObject(className: "Posts")
        
        // Check for a media post
        if self.imageFile != nil
        {
            // Show the HUD
            hud           = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode      = MBProgressHUDModeDeterminateHorizontalBar
            hud.labelText = "Posting Status with Image..."
            
            // Valid image file found, save the new image
            self.imageFile.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                
                let typeAsInt = post.getTypeAsInt(PostType.MEDIA)
                post.setType(typeAsInt)
                
                // Check there was no error and begin handling the file upload
                if error == nil {
                    
                    // Check that the upload succeeded
                    save.setObject(self.imageFile,        forKey: "image")
                    save.setObject(PFUser.currentUser()!, forKey: "author")
                    save.setValue(self.getPostContent(),  forKey: "content")
                    save.setValue(typeAsInt,              forKey: "type")
                    
                    save.pinInBackgroundWithBlock(nil)
                    
                    save.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
                        if completed && error == nil {
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            self.DismissModal(self)
                        } else {
                            println("\(error!.localizedDescription)")
                        }
                    })
                    
                } else {
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    
                    // Processing finished - dismiss controller
                    self.DismissModal(self)
                }
                
                }, progressBlock: { (amountDone: Int32) -> Void in
                    self.hud.progress = Float(amountDone/100)
            })
        // Check for a text post
        } else if getPostContent() != "" {
            // Show the HUD
            hud           = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode      = MBProgressHUDModeDeterminateHorizontalBar
            hud.labelText = "Posting Status..."
            
            let typeAsInt = post.getTypeAsInt(PostType.TEXT)
            post.setType(typeAsInt)
            
            // Save changes to the rest of the post object
            save.setObject(PFUser.currentUser()!, forKey: "author")
            save.setValue(self.getPostContent(), forKey: "content")
            save.setValue(typeAsInt,             forKey: "type")
            
            // Update the user values
            save.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
                if completed && error == nil {
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    
                    // Processing finished - dismiss controller
                    self.DismissModal(self)
                }
            })
        }
        
        
    }
    
    // MARK: - Image Picking and Processing Methods
    @IBAction func PresentImagePicker(sender: AnyObject) {
        
        var alert = UIAlertController(title: "Choose an Option", message: "Would you like to upload an image from your camera roll, or take a new one now?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Existing Image", style: .Default, handler: { action in
            self.pickFromGallery()
        }))
        alert.addAction(UIAlertAction(title: "Camera Image", style: .Default, handler: { action in
            self.shootFromCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            // Open a new image context and draw it to a new compressed rect
            let selectedImg = info[UIImagePickerControllerOriginalImage] as! UIImage
            UIGraphicsBeginImageContext(CGSizeMake(640, 960))
            selectedImg.drawInRect(CGRectMake(0, 0, 640, 960))
            
            // Get the image from the current open context and store it as our compressed image,
            // then close the current image context.
            let compressedImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Upload the image, severely reducing the image quality
            let finalImg   = UIImageJPEGRepresentation(compressedImg, 0.5)
            self.imageFile = PFFile(data: finalImg)
            
            self.navigationItem.rightBarButtonItem?.enabled = true
            
            // Update the GUI
            dispatch_async(dispatch_get_main_queue()) {
                self.imgPreview.hidden      = false
                self.imgPreview.contentMode = .ScaleAspectFill
                self.imgPreview.image       = selectedImg
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Notification methods
    func keyboardChanged(notification: NSNotification) {
        
        // Ensure we are safely unwrapping the user info var
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomSpaceToSuperview?.constant = endFrame?.size.height ?? 0.0
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.viewMediaBar.layoutIfNeeded() },
                completion: nil)
        }
        
        // Only show the preview image when keyboard is not up
        if self.bottomSpaceToSuperview.constant == 0 {
            self.imgPreview.hidden = false
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
    
        // Can we unwrap safely?
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
        
            switch swipeGesture.direction
            {
            // We are swiping down - check that the keyboard is open to perform the dismissal
            case UISwipeGestureRecognizerDirection.Down:
                if isKeyboardOpen {
                    textViewShouldEndEditing(self.txtInput)
                    self.bottomSpaceToSuperview?.constant = 0
                }
            case UISwipeGestureRecognizerDirection.Up:
                break
            case UISwipeGestureRecognizerDirection.Left:
                break
            case UISwipeGestureRecognizerDirection.Right:
                break
            default:
                break
            }
        }
    }
    

}
