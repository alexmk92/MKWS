//
//  CellAnimator.swift
//  MKWS
//
//  Created by Alex Sims on 26/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit
import QuartzCore

class CellAnimator
{

    // Swift does not support class properties, therefore all class properties will be set as static members
    // of the AnimatorProperties struct - this struct is encapsulated within the class.
    private struct AnimatorProperties {
        
        // Set the transformation of the cell only once, this will improve performance as each cell will use this
        // constant
        static let CardBeginTransform: CATransform3D = {
            
            // Define the properties that the matrix will be transformed by
            let rotationDeg: CGFloat = -15.0
            let rotationRad: CGFloat = rotationDeg * (CGFloat(M_PI)/180.0)
            let cardOffset : CGPoint = CGPointMake(-20, -20)
            
            // Create the identity matrix for the card (default/start position)
            var cardAngle = CATransform3DIdentity
            
            // Alter the matrix for this card by rotating the identity matrix around the z axis and then translate it
            // to give the drop in effect
            cardAngle = CATransform3DRotate(CATransform3DIdentity, rotationRad, 0.0, 0.0, 1.0)
            cardAngle = CATransform3DTranslate(cardAngle, cardOffset.x, cardOffset.y, 0.0)
            
            return cardAngle
        }()
        
    }
    
    class func animateCardIn(cell:UITableViewCell) {
        
        let view = cell.contentView
        
        view.layer.transform = AnimatorProperties.CardBeginTransform    // Set initial transformation to the params we just set
        view.layer.opacity   = 0.8                                      // Decrease the opacity
        
        UIView.animateWithDuration(0.4) {
            view.layer.opacity = 1                                      // Animate back to full opacity and the original identity matrix for this card
            view.layer.transform = CATransform3DIdentity                // over 0.4 seconds
        }
    }
}
