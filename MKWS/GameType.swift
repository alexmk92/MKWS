//
//  GameType.swift
//  MKWS
//
//  Created by Alex Sims on 24/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

class GameType {
    
    // Private vars
    private var abbrev     : String?
    private var name       : String?
    private var category   : String?
    private var gameId     : String?
    private var subscribed : Bool?
    private var gameCatId  : String?
    private var sectionId  : Int?
    
    init(abbr : String, name : String, cat : String)
    {
        setAbbrev(abbr)
        setName(name)
        setCategory(cat)
    }
    
    init(){}
    
    // Setters
    func setAbbrev(inAbbr : String?)
    {
        if let newAbbr = inAbbr {
            self.abbrev = newAbbr
        }
    }
    
    func setName(inName : String?)
    {
        if let newName = inName {
            self.name = newName
        }
    }
    
    func setCategory(inCat : String?)
    {
        if let newCat = inCat {
            self.category = newCat
        }
    }
    
    func setSubscribed(isSubscribed : Bool?)
    {
        if let newBool = isSubscribed {
            self.subscribed = newBool
        }
    }
    
    func setGameId(gameId : String?)
    {
        if let objectId = gameId {
            self.gameId = objectId
        }
    }
    
    func setGameCatId(catId: String?)
    {
        if let gameCatId = catId {
            self.gameCatId = catId
        }
    }
    
    func setSectionId(sectionId: Int?)
    {
        if let secId = sectionId {
            self.sectionId = sectionId
        }
    }
    
    // Getters
    func getAbbrev() -> String? {
        return self.abbrev
    }
    
    func getSection() -> Int? {
        return self.sectionId
    }
    
    func getCategory() -> String? {
        return self.category
    }
    
    func getName() -> String? {
        return self.name
    }
    
    func getSubscribed() -> Bool? {
        return self.subscribed
    }
    
    func getGameId() -> String? {
        return self.gameId
    }
    
    func getGameCatId() -> String? {
        return self.gameCatId
    }
}


