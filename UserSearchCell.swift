//
//  UserSearchCell.swift
//  MKWS
//
//  Created by Alex Sims on 02/02/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class UserSearchCell: PFTableViewCell {
   
    @IBOutlet weak var lblEmail    : UILabel!
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var imgAvatar   : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvatar.frame               = CGRectMake(0,0,50,50)
        imgAvatar.layer.cornerRadius  = imgAvatar.frame.size.height/2
        imgAvatar.layer.borderWidth   = CGFloat(2.0)
        imgAvatar.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
        imgAvatar.layer.masksToBounds = false
        imgAvatar.clipsToBounds       = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
