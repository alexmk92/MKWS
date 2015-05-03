//
//  GameCell.swift
//  MKWS
//
//  Created by Alex Sims on 01/05/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {

    @IBOutlet weak var imgOpponent: UIImageView!
    @IBOutlet weak var imgSelf: UIImageView!
    @IBOutlet weak var lblMatchup: UILabel!
    @IBOutlet weak var lblGameType: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
    var opponent:PFUser?
    var game:PFObject?
    weak var tableView:UITableView?
    
    var delegate:CalendarCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgOpponent.frame = CGRectMake(imgOpponent.frame.origin.x, imgOpponent.frame.origin.y, 65, 65)
        imgSelf.frame = CGRectMake(imgSelf.frame.origin.x, imgSelf.frame.origin.y, 65, 65)
        
        imgSelf.circleMask(imageView: imgSelf)
        imgOpponent.circleMask(imageView: imgOpponent)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func cancelGame(sender: AnyObject) {
        if let game = self.game
        {
            if let table = self.tableView
            {
                delegate?.deleteScheduledEvent(game, indexPath: table.indexPathForCell(self)!)
            }
        }
    }
    


}
