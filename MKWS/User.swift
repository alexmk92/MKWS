//
//  User.swift
//  MKWS
//
//  Created by Alex Sims on 28/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

// Used only as a basic wrapper for the PFUser object, all setters are declared private
// because changes to the user are made directly to the server not the object - this objec merely cleans
// up the code when it comes to querying objects later down the line, changes to user code can then be made
// here in this file, opposed to in all files where the PFUser object is used.  
// Default values for setters shall be provided here to ensure we are never unwrapping optionals.
class User {
    
    private var user       : PFUser!
    private var userID     : String!
    private var forename   : String!
    private var surname    : String!
    private var username   : String!
    private var about      : String!
    private var email      : String!
    private var avatar     : UIImage!
    private var wins       : Int!
    private var losses     : Int!
    private var permission : Permission!
    private var location   : AnyObject! // not implemented yet.
    
    init(newUser: PFUser) {
        
        user   = newUser
        userID = user.objectId
        
        // Init the user
        setForename()
        setSurname()
        setUsername()
        setAbout()
        setEmail()
        setAvatar()
        setWins()
        setLosses()
        setPermission()
        setLocation()
    }
    
    // Setters
    private func setForename() {
        if user["forename"] != nil {
            forename = user["forename"] as! String!
        } else {
            forename = user["username"] as! String!
        }
    }
    
    private func setSurname() {
        if user["surname"] != nil {
            surname = user["surname"] as! String!
        } else {
            surname = ""
        }
    }
    
    private func setUsername() {
        if user["username"] != nil {
            username = user["username"] as! String!
        } else {
            username = ""
        }
    }
    
    private func setAbout() {
        if user["about"] != nil {
            about = user["about"] as! String
        } else {
            about = "I have not set my about section within the settings menu yet..."
        }
    }
    
    private func setEmail() {
        if user["email"] != nil {
            email = user["email"] as! String
        } else {
            email = ""
        }
    }
    
    private func setAvatar() {
        if user["avatar"] != nil {
            avatar = UIImage(data: (user["avatar"]!.getData() as NSData?)!)!
        } else {
            avatar = UIImage(named: "defaultAvatar")
        }
    }
    
    private func setWins() {
        if user["gamesWon"] != nil {
            wins = user["gamesWon"] as! Int!
        } else {
            wins = 0
        }
    }
    
    private func setLosses() {
        if user["gamesLost"] != nil {
            losses = user["gamesLost"] as! Int
        } else {
            losses = 0
        }
    }
    
    private func setPermission() {
        let p = UserPermission()
        p.setPermission(0)
        
        if user["permission"] != nil {
            p.setPermission(user["permission"] as! Int)
            permission = p.getPermission()
        } else {
            permission = p.getPermission()
        }
    }
    
    private func setLocation() {
    
    }
    
    // Getters
    func getFullname()-> String! {
        if count(forename!) > 1 && count(surname!) > 1 {
            return forename! + " " + surname!
        }
        return username!
    }
    
    func getForename()-> String! {
        if forename != nil {
            return forename!
        }
        return ""
    }
    
    func getSurname()-> String! {
        return surname!
    }
    
    func getUsername()-> String! {
        return username!
    }
    
    func getAbout()-> String! {
        return about!
    }
    
    func getEmail()-> String! {
        return email!
    }
    
    func getAvatar()-> UIImage! {
        return avatar!
    }
    
    func getWins()-> Int! {
        return wins!
    }
    
    func getLosses()-> Int! {
        return losses!
    }
    
    func getPermission()-> Permission! {
        return permission!
    }
    
    func getPermissionAsString()-> String! {
        
        let p = getPermission() as Permission
        
        switch p
        {
        case .DEV    : return "D"            
        case .ADMIN  : return "A"
        case .GUEST  : return "G"
        case .MEMBER : return "M"
        default      : return "_"
        }
        
    }
    
    func getPermissionColor()-> UIColor! {
        
        let p = getPermission() as Permission
        
        switch p
        {
        case .DEV    : return UIColor(red: 66.0/255.0,  green: 193.0/255.0, blue: 229.0/255.0, alpha: 1)
        case .ADMIN  : return UIColor(red: 43.0/255.0,  green: 43.0/255.0,  blue: 43.0/255.0,  alpha: 1)
        case .GUEST  : return UIColor(red: 229.0/255.0, green: 66.0/255.0,  blue: 66.0/255.0,  alpha: 1)
        case .MEMBER : return UIColor(red: 2.0/255.0,   green: 180.0/255.0, blue: 72.0/255.0,  alpha: 1)
        default      : return UIColor.blackColor()
        }
    }
    
    func getLocation()-> AnyObject {
        return location!
    }
    
    func getUserID()-> String! {
        return userID
    }
    
    func getPFUser()->PFUser! {
        return user
    }
}