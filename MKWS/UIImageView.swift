//
//  CircleMask.swift
//  MKWS
//
//  Created by Alex Sims on 16/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation


extension UIImageView
{
    // Provides an interface to create perfectly rounded images with some default customisation values
    func circleMask(#imageView:UIImageView) -> UIImageView
    {
        let square = frame.width < frame.height ? CGSize(width: frame.width, height: frame.width) : CGSize(width: frame.height, height: frame.height)
        imageView.frame = CGRect(origin:CGPoint(x:0, y:0), size: square)
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor(red: 124.0/255.0, green: 174.0/255.0, blue: 65.0/255.0, alpha: 1.0).CGColor
        
        return imageView
    }
}
