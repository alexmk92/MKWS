//
//  Permission.swift
//  MKWS
//
//  Created by Alex Sims on 24/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

enum Permission {
     case GUEST         // 0  Everyone is a guest until they are promoted
     case MEMBER        // 1  Subscribed and paid members
     case ADMIN         // 2  Any other admins will be set here
     case SUPER_ADMIN   // 3  Neil will be the only super admin
     case DEV           // 4. Developer Access (my account)
}

class UserPermission {
    
    // Create this as a singleton
    struct Static {
        static var instance: UserPermission?
        static var token: dispatch_once_t = 0
    }
    
    class var sharedInstance: UserPermission {
        
        dispatch_once(&Static.token) {
            Static.instance = UserPermission()
        }
        
        return Static.instance!
    }
    
    init(){}

    // Encapsulated vars
    private var permission: Permission?
    
    // Global funcs
    func setPermission(userPermission: Int) {
        switch userPermission
        {
            case 0:  permission = .GUEST
            case 1:  permission = .MEMBER
            case 2:  permission = .ADMIN
            case 3:  permission = .SUPER_ADMIN
            case 4:  permission = .DEV
            default: permission = .GUEST
        }
    }
    
    func getPermission() -> Permission {
        if permission != nil {
            return permission!
        }
        return Permission.GUEST
    }
}


