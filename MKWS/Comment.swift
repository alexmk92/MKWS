//
//  Comment.swift
//  MKWS
//
//  Created by Alex Sims on 31/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

class Comment
{
    // MARK - Encapsulated vars
    private var user    : User!
    private var comment : String!
    private var date    : NSDate!
    
    init() {}
    
    // MARK - Setters
    func setUser(user: PFUser!)-> Bool
    {
        if user != nil {
            self.user = User(newUser: user)
            return true
        }
        
        return false
    }
    
    func setComment(comment: String!)-> Bool {
        if comment != nil {
            self.comment = comment
            return true
        }
        
        return false
    }
    
    func setDate(date: NSDate!)->Bool {
        if date != nil {
            self.date = date
            return true
        }
        
        return false
    }
    
    // MARK - Getters
    func getUser()->User! {
        if user != nil {
            return user
        }
        return nil
    }
    
    func getComment()->String! {
        if comment != nil {
            return comment
        }
        return nil
    }
    
    func getDate()->NSDate! {
        if date != nil {
            return date
        }
        return nil
    }
    
    func getDateAsString()->String! {
        if date != nil {
            
            let interval = NSDate().daysAfterDate(date)
            let df = NSDateFormatter();
            let tf = NSDateFormatter();
            
            tf.dateFormat = "HH:mm"
            df.dateFormat = "DD/MM/yyyy"
            
            var displayDate = ""
            
            switch(interval) {
            case 0:
                displayDate = "\(tf.stringFromDate(date))"
            case 1:
                displayDate = "YESTERDAY"
            default:
                displayDate = "\(df.stringFromDate(date))"
            }
            
            return displayDate
        }
        
        return ""
    }
}