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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
