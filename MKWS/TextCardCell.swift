//
//  TextCardCell.swift
//  MKWS
//
//  Created by Alex Sims on 27/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class TextCardCell: UITableViewCell {

    // Global vars - to be set from controller
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var lblComments: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvatar.frame               = CGRectMake(0,0,35,35)
        imgAvatar.layer.cornerRadius  = imgAvatar.frame.size.height/2
        imgAvatar.layer.borderWidth   = CGFloat(2.0)
        imgAvatar.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
        imgAvatar.layer.masksToBounds = false
        imgAvatar.clipsToBounds       = true
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSizeZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
