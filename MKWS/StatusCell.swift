//
//  StatusCell.swift
//  MKWS
//
//  Created by Alex Sims on 30/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class StatusCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgAvatar.frame = CGRectMake(imgAvatar.frame.origin.x, imgAvatar.frame.origin.y, 50, 50)
        imgAvatar.circleMask(imageView: imgAvatar)
        
        statusView.layer.cornerRadius = statusView.frame.width/2
        statusView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
