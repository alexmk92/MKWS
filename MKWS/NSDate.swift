//
//  NSDate.swift
//  MKWS
//
//  Created by Alex Sims on 02/05/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

extension NSDate
{
    var setDateAtTimeFormat:String
    {
        let dString = stringWithFormat("dd-MMM-yyyy")
        let tString = stringWithFormat("h:mma")
        return "\(dString) at \(tString)"
    }
}