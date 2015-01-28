//
//  MediaCardCell.swift
//  MKWS
//
//  Created by Alex Sims on 27/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class MediaCardCell: UITableViewCell {

    // Global vars
    @IBOutlet weak var imgMedia   : UIImageView!
    @IBOutlet weak var imgAvatar  : UIImageView!
    @IBOutlet weak var lblAuthor  : UILabel!
    @IBOutlet weak var lblDate    : UILabel!
    @IBOutlet weak var lblContent : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
