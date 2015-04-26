//
//  VersusCardCell.swift
//  MKWS
//
//  Created by Alex Sims on 27/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class VersusCardCell: UITableViewCell {

    // Components for the versus card
    @IBOutlet weak var imgAvatarLeft  : UIImageView!
    @IBOutlet weak var imgAvatarRight : UIImageView!
    @IBOutlet weak var lblScoreRight  : UILabel!
    @IBOutlet weak var lblScoreLeft   : UILabel!
    @IBOutlet weak var lblMatchUp     : UILabel!
    @IBOutlet weak var lblDate        : UILabel!
    @IBOutlet weak var lblGameType    : UILabel!
    
    // Colors will be set based on
    let winningColor = UIColor(red: 2.0/255.0, green: 180.0/255.0, blue: 72.0/255.0, alpha: 1.0)
    let losingColor  = UIColor(red: 224.0/255.0, green: 96.0/255.0, blue: 96.0/255.0, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        imgAvatarLeft.frame               = CGRectMake(0,0,70,70)
        imgAvatarLeft.layer.cornerRadius  = imgAvatarLeft.frame.size.height/2
        imgAvatarLeft.layer.borderWidth   = CGFloat(2.0)
        imgAvatarLeft.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
        imgAvatarLeft.layer.masksToBounds = false
        imgAvatarLeft.clipsToBounds       = true
        
        imgAvatarRight.frame               = CGRectMake(0,0,70,70)
        imgAvatarRight.layer.cornerRadius  = imgAvatarRight.frame.size.height/2
        imgAvatarRight.layer.borderWidth   = CGFloat(2.0)
        imgAvatarRight.layer.borderColor   = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1).CGColor
        imgAvatarRight.layer.masksToBounds = false
        imgAvatarRight.clipsToBounds       = true
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSizeZero
    }
    
    func updateLabelColors(leftScore: Int!, rightScore: Int!) {
        if leftScore != nil && rightScore != nil {
            if leftScore > rightScore {
                lblScoreLeft.textColor  = winningColor
                lblScoreRight.textColor = losingColor
                
                imgAvatarLeft.layer.borderColor  = winningColor.CGColor
                imgAvatarRight.layer.borderColor = losingColor.CGColor
            } else {
                lblScoreLeft.textColor  = losingColor
                lblScoreRight.textColor = winningColor
                
                imgAvatarLeft.layer.borderColor  = losingColor.CGColor
                imgAvatarRight.layer.borderColor = winningColor.CGColor
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
