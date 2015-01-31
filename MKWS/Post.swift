//
//  Post.swift
//  MKWS
//
//  Created by Alex Sims on 28/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

// Enum to dictate the post type (set as int on the server)
enum PostType {
    case TEXT
    case MEDIA
    case VERSUS
    case USER
}

class Post {
    
    // Encapsulate all of our member variables for this post
    private var author      : PFUser!
    private var opponent    : PFUser!
    private var leftScore   : String!
    private var rightScore  : String!
    private var content     : String!
    private var date        : String!
    private var image       : UIImage!
    private var type        : PostType!
    private var postID      : String!
    
    
    init(){}
    
    // Setters
    func setType(newType: Int!)-> Bool {
        if newType != nil {
            // A valid integer has been set, now set the type dependent on the enum - if we find no matches, default to USER (shouldn't happen)
            switch(newType)
            {
                case 0:  type = .TEXT
                case 1:  type = .MEDIA
                case 2:  type = .VERSUS
                case 3:  type = .USER
                default: type = .USER
            }
            
            return true
        }

        return false
    }

    func setAuthor(user: PFUser!)-> Bool {
        if user != nil {
            println(user.username)
            author = user!
            return true
        }
        
        return false
    }
    
    func setOpponent(user: PFUser!)-> Bool {
        if user != nil {
            opponent = user!
            return true
        }
        
        return false
    }
    
    func setLeftScore(score: Int!)-> Bool {
        if score != nil {
            leftScore = String(score!)
            return true
        }
        
        return false
    }
    
    func setRightScore(score: Int!)-> Bool {
        if score != nil {
            rightScore = String(score!)
            return true
        }
        
        return false
    }
    
    func setDate(newDate: NSDate!)-> Bool {
        
        if newDate != nil {
            
            let interval = NSDate().daysAfterDate(newDate)
            let df = NSDateFormatter();
            let tf = NSDateFormatter();
            
            tf.dateFormat = "HH:mm"
            df.dateFormat = "DD/MM/yyyy"
            
            var displayDate = ""
            
            switch(interval) {
            case 0:
                displayDate = "\(tf.stringFromDate(newDate))"
            case 1:
                displayDate = "YESTERDAY"
            default:
                displayDate = "\(df.stringFromDate(newDate))"
            }
            
            date = displayDate
            return true
        }
        
        date = ""
        return false
    }
    
    func setContent(newContent: String!)-> Bool {
        
        if newContent != nil {
            content = newContent!
            return true
        }
        
        return false
    }
    
    func setMediaImage(newImage: PFFile!)-> Bool {
        
        if newImage != nil {
            image = UIImage(data: newImage.getData() as NSData)
            return true
        }
        
        return false
    }
    
    func setObjectID(objectID: String!)-> Bool {
        if objectID != nil {
            postID = objectID
            return true
        }
        
        return false
    }
    
    
    // Getters - return variable is optional so we can send a nil value back if it was not set,
    // when we reutrn, we return the unwrapped values as we know they are set due to our check
    func getType() -> PostType! {
        
        if type != nil
        {
            return type!
        }
        
        return nil
    }
    
    func getAuthor()-> PFUser! {
        
        if author != nil {
            return author!
        }
        
        return nil
    }
    
    func getOpponent()-> PFUser! {
        
        if author != nil {
            return opponent!
        }
        
        return nil
    }
    
    func getDate()-> String! {
        
        if date != nil {
            return date!
        }
        
        return nil
    }
    
    func getContent()-> String! {
        
        if content != nil {
            return content!
        }
        
        return nil
    }
    
    func getMediaImage()-> UIImage! {
    
        if image != nil {
            return image!
        }
        
        return nil
    }
    
    func getLeftScoreAsString()-> String! {
    
        if leftScore != nil {
            return String(leftScore!)
        }
        
        return "0"
    }
    
    func getRightScoreAsString()-> String! {
        
        if rightScore != nil {
            return String(rightScore!)
        }
        
        return "0"
    }
    
    func getLeftScore()->Int! {
        if leftScore != nil {
            return leftScore.toInt()!
        }
        
        return 0
    }
    
    func getRightScore()->Int! {
        if rightScore != nil {
            return rightScore.toInt()!
        }
        
        return 0
    }
    
    func getPostID()->String! {
        if postID != nil {
            return postID
        }
        return ""
    }
    
    func getTypeAsInt(type: PostType)-> Int {
        switch type
        {
        case .TEXT   : return 0
        case .MEDIA  : return 1
        case .VERSUS : return 2
        case .USER   : return 3
        }
    }
    
}