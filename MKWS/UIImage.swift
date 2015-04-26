//
//  CircleMask.swift
//  MKWS
//
//  Created by Alex Sims on 16/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation


extension UIImage
{
    // Provides an interface to create perfectly rounded images with some default customisation values
    var circleMask: UIImage
    {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin:CGPoint(x:0, y:0), size: square))
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 7
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}
