//
//  UserStatsViewController.swift
//  MKWS
//
//  Created by Alex Sims on 01/05/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class UserStatsViewController: UIViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var statusColor: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblWins: UILabel!
    @IBOutlet weak var lblLosses: UILabel!
    @IBOutlet weak var lblPlayed: UILabel!
    
    var user:PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if user != nil
        {
            if let u = User(newUser:user!) as User?
            {
                imgAvatar.image = u.getAvatar()
                lblAbout.text = u.getAbout()!
                self.title = u.getFullname()!
                lblWins.text = "\(u.getWins()!)"
                lblLosses.text = "\(u.getLosses()!)"
                lblPlayed.text = "\(u.getWins()! + u.getLosses()!)"
                
                switch u.getPermission()! as Permission
                {
                case .GUEST: lblStatus.text = "Guest"
                    statusColor.backgroundColor = UIColor(red: 198/255, green: 58/255, blue: 0, alpha: 1.0)
                case .MEMBER: lblStatus.text = "Member"
                    statusColor.backgroundColor = UIColor(red: 2/255, green: 192/255, blue: 76/255, alpha: 1.0)
                case .ADMIN: lblStatus.text = "Admin"
                    statusColor.backgroundColor = UIColor(red: 64/255, green: 117/255, blue: 224/255, alpha: 1)
                case .SUPER_ADMIN: lblStatus.text = "Admin"
                    statusColor.backgroundColor = UIColor(red: 64/255, green: 117/255, blue: 224/255, alpha: 1)
                case .DEV: lblStatus.text = "Developer"
                    statusColor.backgroundColor = UIColor(red: 64/255, green: 117/255, blue: 224/255, alpha: 1)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imgAvatar.createCircleMask
        imgAvatar.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.clearBar()
        
        // Set the back button for the nav bar
        let back =  UIBarButtonItem(image: UIImage(named:"back"), style: UIBarButtonItemStyle.Plain, target: self, action: "pop")
        back.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = back
    }
    
    func pop()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Set the user and update the view
    func setUserForView(user: PFUser)
    {
        self.user = user
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
