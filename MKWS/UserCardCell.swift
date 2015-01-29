//
//  UserCardCell.swift
//  MKWS
//
//  Created by Alex Sims on 27/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class UserCardCell: UITableViewCell {

    // Outlets - this cell has no actions
    @IBOutlet weak var imgAvatar   : UIImageView!
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var lblAbout    : UILabel!
    @IBOutlet weak var lblStatus   : UILabel!
    @IBOutlet weak var lblStats    : UILabel!
    @IBOutlet weak var viewStatus  : UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewStatus.frame              = CGRectMake(0,0,36,36)
        viewStatus.layer.cornerRadius = viewStatus.frame.size.height/2
        
        imgAvatar.frame               = CGRectMake(0,0,70,70)
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
