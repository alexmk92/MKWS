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
        imgAvatar.createCircleMask
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
