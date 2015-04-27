//
//  MatchResultCell.swift
//  MKWS
//
//  Created by Alex Sims on 27/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class MatchResultCell: UITableViewCell {

    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStats: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgAvatar.frame               = CGRectMake(0,0,60,60)
        imgAvatar.layer.cornerRadius  = imgAvatar.frame.size.height/2
        imgAvatar.layer.borderWidth   = CGFloat(2.0)
        imgAvatar.layer.borderColor   = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1).CGColor
        imgAvatar.layer.masksToBounds = false
        imgAvatar.clipsToBounds       = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
