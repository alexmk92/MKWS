//
//  AlertCell.Swift
//  MKWS
//
//  Created by Alex Sims on 29/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {
    
    // Outlet connections
    @IBOutlet weak var lblTitle   : UILabel!
    @IBOutlet weak var lblMessage : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}