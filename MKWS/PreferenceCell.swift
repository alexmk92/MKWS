//
//  PreferenceCell.swift
//  MKWS
//
//  Created by Alex Sims on 24/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class PreferenceCell: UITableViewCell {

    @IBOutlet weak var subscribed: UISwitch!
    @IBOutlet weak var gameType: UILabel!
    @IBOutlet weak var subscribedInfo: UILabel!
                   var objectId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    



}
