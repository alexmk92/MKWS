//
//  UIView.swift
//  MKWS
//
//  Created by Alex Sims on 04/05/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

extension UIView
{
    var createCircleMask: UIView
        {
            let square = frame.width < frame.height ? CGSize(width: frame.width, height: frame.width) : CGSize(width: frame.height, height: frame.height)
            frame = CGRect(origin:CGPoint(x:frame.origin.x, y:frame.origin.y), size: square)
            
            layer.cornerRadius = 25
            layer.masksToBounds = true
            
            return self
    }
}