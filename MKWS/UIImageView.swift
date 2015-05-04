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
        
        imageView.layer.cornerRadius = square.width / 2;
        imageView.clipsToBounds = true
        
        return imageView
    }
    
    override var createCircleMask: UIImageView
    {
        let square = frame.width < frame.height ? CGSize(width: frame.width, height: frame.width) : CGSize(width: frame.height, height: frame.height)
        frame = CGRect(origin:CGPoint(x:frame.origin.x, y:frame.origin.y), size: square)
        
        contentMode = UIViewContentMode.ScaleAspectFill
        layer.cornerRadius = square.width / 2;
        clipsToBounds = true
        
        return self
    }
    
    func zeroBorder()
    {
        layer.borderWidth = 0
    }
    
    func addBorder(thickness:CGFloat)
    {
        layer.borderWidth = thickness
    }
}
