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
    
    private var indexPathRowSelected: NSIndexPath!
    private var limit    = 10
    private var oldLimit = 0
    private var refresh: UIRefreshControl?
    private var refreshing = false
    private var swipeDirection: UISwipeGestureRecognizerDirection!
    
    // Keep track of current direction
    private var topOffset: CGFloat = 0 {
        didSet {
            if oldValue > topOffset {
                swipeDirection = UISwipeGestureRecognizerDirection.Down
            } else {
                swipeDirection = UISwipeGestureRecognizerDirection.Up
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Timeline"
        
        tableView.delegate = self
    }

    // Reset the settings which are applied on a logout
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self.didAnimateCell = [:]
            self.get_posts(false)
            dispatch_async(dispatch_get_main_queue()) {
                let backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                backgroundView.image = UIImage(named: "background")
                
                self.tableView.backgroundView = backgroundView
                self.tabBarController?.tabBar.hidden = false
                self.navigationItem.setHidesBackButton(false, animated: false)
                self.btnNewPost.tintColor = UIColor.whiteColor()
                self.navigationItem.rightBarButtonItem = self.btnNewPost
                self.navigationItem.leftBarButtonItem  = nil
                
                // Set the refresh control
                self.refresh = UIRefreshControl()
                self.refresh!.addTarget(self, action: "refresh_view:", forControlEvents: UIControlEvents.ValueChanged)
                self.tableView.addSubview(self.refresh!)
            }
        }
    }
    
    func refresh_view(sender: AnyObject!)
    {
        refreshing = true
        get_posts(refreshing)
    }
    
    // Populate the posts array
    func get_posts(fetchFromNetwork: Bool) {
        
        // Get the remaining posts from the database
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.includeKey("opponent")
        query.orderByDescending("createdAt")
        query.limit = limit

        if !fetchFromNetwork { query.fromLocalDatastore() }
        
        query.findObjectsInBackgroundWithBlock { (results: [AnyObject]!, error: NSError!) -> Void in
            
            if results.count == 0 && !fetchFromNetwork {
                self.get_posts(true)
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
                {
                        // Re-initialize the posts array
                        self.posts = [Post]()
                        
                        // Add the current user to the first index (this will be used to build the users overview card)
                        let emptyPost = Post()
                        self.posts.append(emptyPost)
                        
                        if error == nil {
                            for post in results {
                                let p = Post(newPost: post as PFObject) as Post
                                p.setAuthor    (post["author"]     as PFUser!)
                                p.setOpponent  (post["opponent"]   as PFUser!)
                                p.setContent   (post["content"]    as String!)
                                p.setDate      (post.createdAt     as NSDate!)
                                p.setLeftScore (post["leftScore"]  as Int!)
                                p.setRightScore(post["rightScore"] as Int!)
                                p.setType      (post["type"]       as Int!)
                                p.setMediaImage(post["image"]      as PFFile!)
                                p.setObjectID  (post.objectId      as String!)
                                
                                self.posts.append(p)
                                
                                if fetchFromNetwork { post.pinInBackgroundWithBlock(nil) }
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.refresh?.endRefreshing()
                                self.tableView.rowHeight = UITableViewAutomaticDimension
                                
                                self.tableView.reloadData()
                            }
                            
                        } else {
                            println("\(error.localizedDescription)")
                        }
                }
            }
        }
        
    }

    // MARK: - Table view data source
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === self.tableView {
            topOffset = scrollView.contentOffset.y
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let count = posts.count
        var cell: UITableViewCell!
        var p: Post?
        
        // Get the post we are currently on
        if indexPath.row < count {
            p = posts[indexPath.row] as Post
        }
        
        // Build the overview cell
        if indexPath.row == 0 {
            let userCell = tableView.dequeueReusableCellWithIdentifier("UserCardCell", forIndexPath: indexPath) as UserCardCell
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let user  =  User(newUser: PFUser.currentUser())
                let image = user.getAvatar()
                dispatch_async(dispatch_get_main_queue()) {
                    userCell.lblAbout!.text    = user.getAbout()
                    userCell.lblStats!.text    = "Wins \(user.getWins()), Losses \(user.getLosses())"
                    userCell.lblUsername!.text = user.getFullname()
                    userCell.lblStatus!.text   = user.getPermissionAsString()
                    userCell.viewStatus!.backgroundColor = user.getPermissionColor()
                    
                    userCell.imgAvatar!.image  = image
                }
            }

            cell = userCell
        }
            
        // Handle other cell types
        else
        {
            if posts[indexPath.row].getType() == PostType.MEDIA
            {
                let mediaCell = tableView.dequeueReusableCellWithIdentifier("MediaCardCell", forIndexPath: indexPath) as MediaCardCell
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let user   =  User(newUser: p!.getAuthor())
                    let avatar =  user.getAvatar()
                    let image  =  p!.getMediaImage()
                    dispatch_async(dispatch_get_main_queue()) {
                        mediaCell.lblAuthor!.text   = user.getFullname()!
                        mediaCell.imgAvatar.image   = avatar!
                        mediaCell.lblContent!.text  = p!.getContent()!
                        mediaCell.lblDate!.text     = p!.getDate()!
                        
                        mediaCell.imgMedia.image    = image!
                        
                        // Prepare for the segue
                        self.indexPathRowSelected = indexPath
                        mediaCell.btnComments.addTarget(self, action: "commentButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                }
                
                cell = mediaCell
            }
            
            if posts[indexPath.row].getType() == PostType.TEXT
            {
                let textCell = tableView.dequeueReusableCellWithIdentifier("TextCardCell", forIndexPath: indexPath) as TextCardCell
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let user   =  User(newUser: p!.getAuthor())
                    let avatar =  user.getAvatar()
                    dispatch_async(dispatch_get_main_queue()) {
                        textCell.lblAuthor!.text   = user.getFullname()!
                        textCell.imgAvatar!.image  = avatar!
                        textCell.lblDate!.text     = p!.getDate()!
                        textCell.lblDesc!.text     = p!.getContent()!
                        
                        // Prepare for the segue
                        self.indexPathRowSelected = indexPath
                        textCell.btnComments.addTarget(self, action: "commentButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                }
                
                cell = textCell
            }
            
            if posts[indexPath.row].getType() == PostType.VERSUS
            {
                let versusCell = tableView.dequeueReusableCellWithIdentifier("VersusCardCell", forIndexPath: indexPath) as VersusCardCell
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let user      =  User(newUser: p!.getAuthor()  as PFUser!)
                    let opponent  =  User(newUser: p!.getOpponent() as PFUser!)
                    let userA     =  user.getAvatar()
                    let opponentA =  opponent.getAvatar()
                    dispatch_async(dispatch_get_main_queue()) {
                        versusCell.lblMatchUp!.text      = user.getFullname()! + " VS " + opponent.getFullname()!
                        versusCell.imgAvatarLeft!.image  = userA!
                        versusCell.imgAvatarRight!.image = opponentA!
                        versusCell.lblDate!.text         = p!.getDate()!
                        versusCell.lblGameType!.text     = p!.getContent()!
                        versusCell.lblScoreLeft!.text    = p!.getLeftScoreAsString()!
                        versusCell.lblScoreRight!.text   = p!.getRightScoreAsString()!
                        
                        versusCell.updateLabelColors(p!.getLeftScore(), rightScore: p!.getRightScore())
                    }
                }
                
                cell = versusCell
            }
        }

        return cell
    }
    
    // MARK: - Scroll view did end scrolling (check to load new data)
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size   = scrollView.contentSize
        let insets = scrollView.contentInset
        
        let y = offset.y + bounds.size.height - insets.bottom as CGFloat
        let h = size.height as CGFloat
        let r = 50 as CGFloat
        
        if y > (h + r) {
            oldLimit = limit
            limit += 10
            get_posts(true)
        } 
    }
    
    // Send to the appropriate segue to initiate the view
    func commentButtonTapped() {
        
        let post = posts[indexPathRowSelected.row] as Post
        
        // Switch on the post type to designate the right object to set
        switch post.getType() as PostType
        {
        case .TEXT  : performSegueWithIdentifier("commentsText", sender: self)
        case .MEDIA : performSegueWithIdentifier("commentsMedia", sender: self)
        default     : break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Set the post object dependent on which item we recieved
        if segue.identifier == "commentsText" || segue.identifier == "commentsMedia" {
            let p = posts[indexPathRowSelected.row] as Post!
            let u = User(newUser: p.getAuthor() as PFUser!) as User!
            
            if p != nil && u != nil {
                let vc = segue.destinationViewController as CommentsModalViewController
                vc.post   = p
                vc.author = u
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (didAnimateCell[indexPath] == nil || didAnimateCell[indexPath] == false) && swipeDirection == UISwipeGestureRecognizerDirection.Up {
            didAnimateCell[indexPath] = true
            CellAnimator.animateCardIn(cell)
        }
    }
    


}
