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
        
        layoutSubviews()
        
        imgAvatar.frame = CGRectMake(imgAvatar.frame.origin.x, imgAvatar.frame.origin.y, 40, 40)
        imgAvatar.circleMask(imageView: imgAvatar)
        imgAvatar.addBorder(2)
        imgAvatar.layer.borderColor = UIColor(red:50, green: 50, blue: 60, alpha: 1.0).CGColor!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.frame = CGRectMake(statusView.frame.origin.x, statusView.frame.origin.y, 10, 10)
        statusView.layer.cornerRadius = 5
        statusView.layer.masksToBounds = true
        statusView.layoutIfNeeded()
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
