//
//  ChallengerCell.swift
//  MKWS
//
//  Created by Alex Sims on 26/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class ChallengerCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStats: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
