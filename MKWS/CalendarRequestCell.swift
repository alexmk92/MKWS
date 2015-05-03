//
//  CalendarRequestCell.swift
//  MKWS
//
//  Created by Alex Sims on 01/05/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class CalendarRequestCell: UITableViewCell {

    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblChallengerName: UILabel!
    @IBOutlet weak var lblGameType: UILabel!
    @IBOutlet weak var lblGameDate: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    var opponent:PFUser?
    var game:PFObject?
    weak var tableView:UITableView?
    
    var delegate:CalendarCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvatar.frame = CGRectMake(imgAvatar.frame.origin.x, imgAvatar.frame.origin.y, 65, 65)
        imgAvatar.circleMask(imageView: imgAvatar)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func acceptRequest(sender: AnyObject) {
        if let game = self.game
        {
            if let table = self.tableView
            {
                delegate?.acceptScheduledEvent(game, indexPath: table.indexPathForCell(self)!)
            }
        }
    }
    
    @IBAction func declineRequest(sender: AnyObject) {
        if let game = self.game
        {
            if let table = self.tableView
            {
                delegate?.declineScheduledEvent(game, indexPath: table.indexPathForCell(self)!)
            }
        }
    }
}
