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
        
        newUser.fetchIfNeeded()
        user   = newUser
        userID = user.objectId
        
        // Init the user
        setForename()
        setSurname()
        setUsername()
        setAbout()
        setEmail()
        setWins()
        setLosses()
        setPermission()
        setLocation()
    }
    
    // Setters
    private func setForename() {
        if let forename: String = user["forename"] as? String
        {
            self.forename = forename
        }
        else
        {
            self.forename = ""
        }
    }
    
    private func setSurname() {
        if let surname: String = user["surname"] as? String
        {
            self.surname = surname
        }
        else
        {
            self.surname = ""
        }
    }
    
    private func setUsername() {
        if let username: String = user["username"] as? String
        {
            self.username = username
        }
        else
        {
            self.username = ""
        }
    }
    
    private func setAbout() {
        if let about: String = user["about"] as? String
        {
            self.about = user["about"] as! String
        }
        else {
            self.about = "I have not set my about section within the settings menu yet..."
        }
    }
    
    private func setEmail() {
        if let email: String = user["email"] as? String
        {
            self.email = user["email"] as! String
        }
        else {
            self.email = ""
        }
    }
    
    func downloadAvatar() {
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
        if count(forename!) > 0 && count(surname!) > 0 {
            return forename! + " " + surname!
        }
        return username!
    }
    
    func getForename()-> String! {
        if forename != nil && count(forename!) > 0 {
            return forename!
        }
        return getUsername()
    }
    
    func getSurname()-> String! {
        if surname == nil
        {
            return ""
        }
        return surname!
    }
    
    func getUsername()-> String! {
        if username == nil
        {
            return ""
        }
        return username!
    }
    
    func getAbout()-> String! {
        if about == nil
        {
            return ""
        }
        return about!
    }
    
    func getEmail()-> String! {
        if email == nil
        {
            return ""
        }
        return email!
    }
    
    func getAvatar()-> UIImage! {
        return avatar!
    }
    
    func getWins()-> Int! {
        if wins == nil
        {
            return 0
        }
        return wins!
    }
    
    func getLosses()-> Int! {
        if losses == nil
        {
            return 0
        }
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