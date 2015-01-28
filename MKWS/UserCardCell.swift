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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
