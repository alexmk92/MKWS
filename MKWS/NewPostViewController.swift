//
//  NewPostViewController.swift
//  MKWS
//
//  Created by Alex Sims on 29/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
     
        // Set up user avatar etc
        let user = User(newUser: PFUser.currentUser())
        
        // All values returned from the user class we can assume are safe (never return nil - instead return default string/image values)
        imgAvatar!.image = user.getAvatar()!
        lblEmail!.text   = user.getEmail()!
        lblName!.text    = user.getFullname()!
        
        // Set up images
        imgAvatar.frame               = CGRectMake(0,0,35,35)
        imgAvatar.layer.cornerRadius  = imgAvatar.frame.size.height/2
        imgAvatar.layer.borderWidth   = CGFloat(2.0)
        imgAvatar.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
        imgAvatar.layer.masksToBounds = false
        imgAvatar.clipsToBounds       = true
        
        imgPreview.frame               = CGRectMake(0,0,50,50)
        imgPreview.layer.cornerRadius  = imgAvatar.frame.size.height/2
        imgPreview.layer.borderWidth   = CGFloat(2.0)
        imgPreview.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
        imgPreview.layer.masksToBounds = false
        imgPreview.clipsToBounds       = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // We know that there will be no image when the window is first opened so hide it
        //imgPreview.hidden = true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        isKeyboardOpen = false
        
        if countElements(txtInput.text) < 1 {
            txtInput.text = "What's on your mind..."
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if txtInput.text == "What's on your mind..." {
            txtInput.text = ""
        }
        isKeyboardOpen = true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let maxLen = 100
        var len = countElements(txtInput.text)
        
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
    
    // Dismiss the view controller and un-bind any existing observers
    @IBAction func DismissModal(sender: AnyObject) {
        textViewShouldEndEditing(self.txtInput)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func PostStatus(sender: AnyObject) {
    }
    
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
        self.bottomSpaceToSuperview?.constant = 0
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType    = .PhotoLibrary
        imagePicker.modalPresentationStyle = .Popover
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func shootFromCamera() {
    
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.bottomSpaceToSuperview?.constant = 0
        
        let selectedImg = info[UIImagePickerControllerOriginalImage] as UIImage
        imgPreview.hidden = false
        imgPreview.contentMode = .ScaleAspectFill
        imgPreview.image = selectedImg
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
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
