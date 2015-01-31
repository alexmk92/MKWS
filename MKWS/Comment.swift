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
    private var post    : Post!
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
    
    func setPost(post: Post!)-> Bool {
        if post != nil {
            self.post = post
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
    
    func getPost()->Post! {
        if post != nil {
            return post
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
}