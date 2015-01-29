//
//  NewPostViewController.swift
//  MKWS
//
//  Created by Alex Sims on 29/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func DismissModal(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func PostStatus(sender: AnyObject) {
    }
    
    @IBAction func PresentImagePicker(sender: AnyObject) {
    }
    
}
