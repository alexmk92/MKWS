//
//  TimelineTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 17/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController {

    @IBOutlet weak var btnNewPost: UIBarButtonItem!
    
    // Dictionary to determine whether or not the cell has been animated into view
    var didAnimateCell:[NSIndexPath : Bool] = [:]
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
    }
    
    
    // Reset the settings which are applied on a logout
    override func viewWillAppear(animated: Bool) {
        get_posts()
        let backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        backgroundView.image = UIImage(named: "background")
        
        self.tableView.backgroundView = backgroundView
      
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        self.navigationItem.setHidesBackButton(false, animated: false)
        
        btnNewPost.tintColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem = btnNewPost
        
        self.navigationItem.leftBarButtonItem  = nil
    }
    
    // Populate the posts array
    func get_posts() {
        
        // Re-initialize the posts array
        posts = [Post]()
        
        // Add the current user to the first index (this will be used to build the users overview card)
        let emptyPost = Post()
        posts.append(emptyPost)
        
        // Get the remaining posts from the database
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.includeKey("opponent")
        query.findObjectsInBackgroundWithBlock { (results: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for post in results {
                    let p = Post() as Post
                    p.setAuthor    (post["author"]     as PFUser!)
                    p.setOpponent  (post["opponent"]   as PFUser!)
                    p.setContent   (post["content"]    as String!)
                    p.setDate      (post.createdAt     as NSDate!)
                    p.setLeftScore (post["leftScore"]  as Int!)
                    p.setRightScore(post["rightScore"] as Int!)
                    p.setType      (post["type"]       as Int!)
                    p.setMediaImage(post["image"]      as PFFile!)
                    
                    self.posts.append(p)
                }
                
                //self.tableView.estimatedRowHeight = 500
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.reloadData()
                
            } else {
                println("\(error.localizedDescription)")
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var count = posts.count
        var cell: UITableViewCell!
        
        // Get the post we are currently on
        let p = posts[indexPath.row] as Post
        
        // Build the overview cell
        if indexPath.row == 0 {
            let userCell = tableView.dequeueReusableCellWithIdentifier("UserCardCell", forIndexPath: indexPath) as UserCardCell
            
            let user = User(newUser: PFUser.currentUser())
            
            userCell.lblAbout!.text    = user.getAbout()
            userCell.lblStats!.text    = "Wins \(user.getWins()), Losses \(user.getLosses())"
            userCell.lblUsername!.text = user.getFullname()
            userCell.lblStatus!.text   = user.getPermissionAsString()
            userCell.imgAvatar!.image  = user.getAvatar()
            
            userCell.viewStatus!.backgroundColor = user.getPermissionColor()
            
            cell = userCell
        }
        // Handle other cell types
        else
        {
            if posts[indexPath.row].getType() == PostType.MEDIA
            {
                let mediaCell = tableView.dequeueReusableCellWithIdentifier("MediaCardCell", forIndexPath: indexPath) as MediaCardCell

                let user = User(newUser: p.getAuthor() as PFUser)
                
                mediaCell.lblAuthor!.text  = user.getFullname()!
                mediaCell.imgAvatar.image  = user.getAvatar()!
                mediaCell.lblContent!.text = p.getContent()!
                mediaCell.lblDate!.text    = p.getDate()!
                mediaCell.imgMedia.image   = p.getMediaImage()!
                
                cell = mediaCell
            }
            
            if posts[indexPath.row].getType() == PostType.TEXT
            {
                let textCell = tableView.dequeueReusableCellWithIdentifier("TextCardCell", forIndexPath: indexPath) as TextCardCell
                
                let user     = User(newUser: p.getAuthor()   as PFUser!)
                
                textCell.lblAuthor!.text  = user.getFullname()!
                textCell.imgAvatar!.image = user.getAvatar()!
                textCell.lblDate!.text    = p.getDate()!
                textCell.lblDesc!.text    = p.getContent()!
                
                cell = textCell
            }
            
            if posts[indexPath.row].getType() == PostType.VERSUS
            {
                let versusCell = tableView.dequeueReusableCellWithIdentifier("VersusCardCell", forIndexPath: indexPath) as VersusCardCell
                
                let user     = User(newUser: p.getAuthor()   as PFUser!)
                let opponent = User(newUser: p.getOpponent() as PFUser!)
   
                versusCell.lblMatchUp!.text      = user.getFullname()! + " VS " + opponent.getFullname()!
                versusCell.imgAvatarLeft!.image  = user.getAvatar()!
                versusCell.imgAvatarRight!.image = opponent.getAvatar()!
                versusCell.lblDate!.text         = p.getDate()!
                versusCell.lblGameType!.text     = p.getContent()!
                versusCell.lblScoreLeft!.text    = p.getLeftScoreAsString()!
                versusCell.lblScoreRight!.text   = p.getRightScoreAsString()!
                
                versusCell.updateLabelColors(p.getLeftScore(), rightScore: p.getRightScore())
                
                cell = versusCell
            }
        }
        

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if didAnimateCell[indexPath] == nil || didAnimateCell[indexPath] == false {
            didAnimateCell[indexPath] = true
            CellAnimator.animateCardIn(cell)
        }
    }

    

    @IBAction func ShowNewPost(sender: AnyObject) {

    }



}
