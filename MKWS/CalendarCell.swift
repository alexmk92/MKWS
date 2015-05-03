//
//  CalendarCell.swift
//  MKWS
//
//  Created by Alex Sims on 30/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

protocol CalendarCellDelegate
{
    func deleteScheduledEvent(game:PFObject, indexPath:NSIndexPath)
    func declineScheduledEvent(game:PFObject, indexPath:NSIndexPath)
    func acceptScheduledEvent(game:PFObject, indexPath:NSIndexPath)
}

class CalendarCell: UITableViewCell {

    var game:PFObject?
    weak var tableView:UITableView?
    
    @IBOutlet weak var lblGameType: UILabel!
    @IBOutlet weak var lblGameDate: UILabel!
    @IBOutlet weak var lblOthers: UILabel!
    @IBOutlet weak var imgRecipientA: UIImageView!
    @IBOutlet weak var imgRecipientB: UIImageView!
    @IBOutlet weak var imgRecipientC: UIImageView!
    @IBOutlet weak var imgRecipientD: UIImageView!
    
    @IBOutlet weak var viewStatusColour: UIView!
    
    var delegate:CalendarCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgRecipientA.frame = CGRectMake(imgRecipientA.frame.origin.x,imgRecipientA.frame.origin.y,30,30)
        imgRecipientB.frame = CGRectMake(imgRecipientB.frame.origin.x,imgRecipientB.frame.origin.y,30,30)
        imgRecipientC.frame = CGRectMake(imgRecipientC.frame.origin.x,imgRecipientC.frame.origin.y,30,30)
        imgRecipientD.frame = CGRectMake(imgRecipientD.frame.origin.x,imgRecipientD.frame.origin.y,30,30)
        
        imgRecipientA.circleMask(imageView: imgRecipientA)
        imgRecipientB.circleMask(imageView: imgRecipientB)
        imgRecipientC.circleMask(imageView: imgRecipientC)
        imgRecipientD.circleMask(imageView: imgRecipientD)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnCancelEvent(sender: AnyObject)
    {
        if let thisGame = game
        {
            if let table = self.tableView
            {
                delegate?.deleteScheduledEvent(self.game!, indexPath: table.indexPathForCell(self)!)
            }
        }
    }

}
