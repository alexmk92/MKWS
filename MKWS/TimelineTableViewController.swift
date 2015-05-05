//
//  TimelineTableViewController.swift
//  MKWS
//
//  Created by Alex Sims on 17/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit
import QuartzCore
import AudioToolbox

class TimelineTableViewController: UITableViewController, UITabBarControllerDelegate {

    @IBOutlet weak var btnNewPost: UIBarButtonItem!
    
    // Dictionary to determine whether or not the cell has been animated into view
    var didAnimateCell:[NSIndexPath : Bool] = [:]
    var avatars:[NSIndexPath : UIImage] = [:]
    var images:[NSIndexPath : UIImage] = [:]
    var posts = [Post]()
    
    private var indexPathRowSelected: NSIndexPath!
    private var limit    = 50
    private var oldLimit = 0
    private var refresh: UIRefreshControl?
    private var refreshing = false
    private var swipeDirection: UISwipeGestureRecognizerDirection!
    private var initialLoad = true
    private var statusBarView = UIView()
    
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
    
    // Initialise the view controller and set up any child controller references
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Timeline"
        
        tableView.delegate = self
    }

    // Reset the settings which are applied on a logout
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.clearGrayBar()
        
        // Set the initial status bar view
        statusBarView.hidden = true
        statusBarView.frame = CGRectMake(0, 0, UIApplication.sharedApplication().statusBarFrame.width, UIApplication.sharedApplication().statusBarFrame.height)
        statusBarView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 42/255, alpha: 0.95)
        view.insertSubview(statusBarView, aboveSubview: navigationController!.view)
        tabBarController?.delegate = self
        
        if PFUser.currentUser() == nil
        {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else
        {
            var shouldLoadFromNetwork = Reachability.isConnectedToNetwork()
            if initialLoad
            {
                shouldLoadFromNetwork = false
            }
            
            // Do this asynchronously as is expensive
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                self.didAnimateCell = [:]
                self.avatars = [:]
                self.images = [:]
                self.get_posts(shouldLoadFromNetwork)
                dispatch_async(dispatch_get_main_queue()) {
                    // It is no longer the initial load
                    self.initialLoad = false
                    
                    // Set the UI up
                    let backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                    backgroundView.image = UIImage(named: "background")
                    
                    self.tableView.backgroundView = backgroundView
                    self.tabBarController?.tabBar.hidden = false
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
                    self.navigationItem.setHidesBackButton(true, animated: false)
                    self.btnNewPost.tintColor = UIColor.whiteColor()
                    self.navigationItem.rightBarButtonItem = self.btnNewPost
        
                    
                    // Set the refresh control
                    self.refresh = UIRefreshControl()
                    self.refresh!.addTarget(self, action: "refresh_view:", forControlEvents: UIControlEvents.ValueChanged)
                    self.tableView.addSubview(self.refresh!)
                }
            }
        }
    }
    
    
    
    // Make a request to the network if we are connected
    func refresh_view(sender: AnyObject!)
    {
        if self.refreshing == false {
            self.refreshing = true
            get_posts(Reachability.isConnectedToNetwork())
        }
    }
    
    // Populate the posts array
    func get_posts(fetchFromNetwork: Bool) {
        
        // Get the remaining posts from the database
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.includeKey("opponent")
        query.orderByDescending("createdAt")
        query.limit = limit
        
        // Retrieve from the datastore
        if !fetchFromNetwork { query.fromLocalDatastore() }
        
        // Get the posts back from datastore or over the network dependent on bool
        query.findObjectsInBackgroundWithBlock { (data: [AnyObject]?, error: NSError?) -> Void in
            
            // Ensure the app will not blow up by checking we have results
            if let results = data {
                // Check we have a valid number of posts to retrieve, only call this is we are fetching from
                // datastore
                if (results.count == 0 && !fetchFromNetwork) || (results.count < 5 && !fetchFromNetwork) {
                    self.get_posts(true)
                } else
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
                    {
                            // Re-initialize the posts array
                            self.posts = [Post]()
                            
                            // Add the current user to the first index (this will be used to build the users overview card)
                            let emptyPost = Post()
                            self.posts.append(emptyPost)
                            
                            if error == nil
                            {
                                for post in results {
                                    let p = Post(newPost: post as! PFObject) as Post
                                    p.setAuthor    (post["author"]     as! PFUser!)
                                    p.setOpponent  (post["opponent"]   as! PFUser!)
                                    p.setContent   (post["content"]    as! String!)
                                    p.setDate      (post.createdAt     as NSDate!)
                                    p.setLeftScore (post["leftScore"]  as! Int!)
                                    p.setRightScore(post["rightScore"] as! Int!)
                                    p.setType      (post["type"]       as! Int!)
                                    p.setMediaImage(post["image"]      as! PFFile!)
                                    p.setObjectID  (post.objectId      as String!)
                                    
                                    self.posts.append(p)
                                    
                                    if fetchFromNetwork {
                                        post.pinInBackgroundWithBlock(nil)
                                    } else {
                                        post.unpinInBackgroundWithBlock(nil)
                                    }
                                }
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.refresh?.endRefreshing()
                                    self.tableView.rowHeight = UITableViewAutomaticDimension
                                    self.tableView.reloadData()
                                    self.refreshing = false
                                }
                                
                            } else {
                                println("\(error!.localizedDescription)")
                            }
                    }
                }
            }
            
        }
        
    }
    
    // MARK: - Tab bar delegate implementations
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if tabBarController.selectedIndex == 0
        {
        
        }
        return viewController != tabBarController.selectedViewController
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Here we build each of the table cells, I could have used a separate section for each cell, but instead
    // we are using autolayout to ensure that each card is evenly spaced (maybe a bad way of doing it but to late to
    // rework the structure).
    // Note howe we always make a call on a separate thread whenever we load a cell, this is because each time we pull an 
    // image back we fire a download task, very expensive on resources - therefore the load is done on a separate thread and
    // then rejoins once it is finished.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let count = posts.count
        var cell = UITableViewCell()
        var p: Post?
        
        // Get the post we are currently on
        if indexPath.row < count {
            p = posts[indexPath.row] as Post?
        }
    
        // Ensure we have a post
        if let post = p
        {
            // Build the overview cell -
            if indexPath.row == 0 {
                let userCell: UserCardCell? = tableView.dequeueReusableCellWithIdentifier("UserCardCell", forIndexPath: indexPath) as? UserCardCell
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    if PFUser.currentUser() != nil
                    {
                        let user = User(newUser: PFUser.currentUser()!)
                        user.downloadAvatar()
                        dispatch_async(dispatch_get_main_queue()) {
                            userCell?.lblAbout.text    = user.getAbout()
                            userCell?.lblStats.text    = "Wins \(user.getWins()), Losses \(user.getLosses())"
                            userCell?.lblUsername.text = user.getFullname()
                            userCell?.lblStatus.text   = user.getPermissionAsString()
                            userCell?.viewStatus.backgroundColor = user.getPermissionColor()
                            
                            userCell?.imgAvatar.image  = user.getAvatar()
                        }
                    }
                }
                
                if let c = userCell {
                    cell = c
                }
            }
                
            // Handle other cell types
            else
            {
                if post.getType() == PostType.MEDIA
                {
                    let mediaCell: MediaCardCell? = tableView.dequeueReusableCellWithIdentifier("MediaCardCell", forIndexPath: indexPath) as? MediaCardCell
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        if PFUser.currentUser() != nil
                        {
                            let user   =  User(newUser: post.getAuthor())
                            user.downloadAvatar()
                            dispatch_async(dispatch_get_main_queue()) {
                                mediaCell?.lblAuthor.text   = user.getFullname()
                                mediaCell?.imgAvatar.image  = user.getAvatar()
                                mediaCell?.lblContent.text  = post.getContent()
                                mediaCell?.lblDate.text     = post.getDate()
                               
                                mediaCell?.imgMedia.image    = post.getMediaImage()
                                
                                // Prepare for the segue
                                self.indexPathRowSelected = indexPath
                                mediaCell?.btnComments.addTarget(self, action: "commentButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
                            }
                        }
                    }
                    
                    if let c = mediaCell {
                        cell = c
                    }
                }
                
                if post.getType() == PostType.TEXT
                {
                    let textCell: TextCardCell? = tableView.dequeueReusableCellWithIdentifier("TextCardCell", forIndexPath: indexPath) as? TextCardCell
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        if PFUser.currentUser() != nil
                        {
                            let user   =  User(newUser: post.getAuthor())
                            user.downloadAvatar()
                            user.downloadAvatar()
                            let avatar =  user.getAvatar()
                            dispatch_async(dispatch_get_main_queue()) {
                                textCell?.lblAuthor.text   = user.getFullname()!
                                textCell?.imgAvatar.image  = avatar!
                                textCell?.lblDate.text     = post.getDate()!
                                textCell?.lblDesc.text     = post.getContent()!
                                
                                // Prepare for the segue
                                self.indexPathRowSelected = indexPath
                                textCell?.btnComments.addTarget(self, action: "commentButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
                            }
                        }
                    }
                    
                    if let c = textCell {
                        cell = c
                    }
                }
                
                if post.getType() == PostType.VERSUS
                {
                    let versusCell: VersusCardCell? = tableView.dequeueReusableCellWithIdentifier("VersusCardCell", forIndexPath: indexPath) as? VersusCardCell
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        if PFUser.currentUser() != nil
                        {
                            let user      =  User(newUser: post.getAuthor()  as PFUser!)
                            user.downloadAvatar()
                            let opponent  =  User(newUser: post.getOpponent() as PFUser!)
                            opponent.downloadAvatar()
                            dispatch_async(dispatch_get_main_queue()) {
                                versusCell?.lblMatchUp.text      = user.getFullname()! + " VS " + opponent.getFullname()!
                                versusCell?.imgAvatarLeft.image  = user.getAvatar()
                                versusCell?.imgAvatarRight.image = opponent.getAvatar()
                                versusCell?.lblDate.text         = post.getDate()!
                                versusCell?.lblGameType.text     = post.getContent()!
                                versusCell?.lblScoreLeft.text    = post.getLeftScoreAsString()!
                                versusCell?.lblScoreRight.text   = post.getRightScoreAsString()!
                                
                                versusCell?.updateLabelColors(post.getLeftScore(), rightScore: post.getRightScore())
                            }
                        }
                    }
                    
                    if let c = versusCell {
                        cell = c
                    }
                }
            }
        }
        
        // Set the gesture recogniser for the cell
        var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "deletePost:")
        longPress.minimumPressDuration = 1
        longPress.delegate = cell
        tableView.addGestureRecognizer(longPress)
        
        return cell
    }
    
    // MARK: - Gesture recogniser for long press
    func deletePost(gestureRecognizer: UILongPressGestureRecognizer)
    {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if let p:CGPoint = gestureRecognizer.locationInView(self.tableView) as CGPoint!
        {
            if let indexPath = tableView.indexPathForRowAtPoint(p) as NSIndexPath!
            {
                if let post = posts[indexPath.row] as Post!
                {
                    // Perform the delete on the backend
                    if post.getAuthor() == PFUser.currentUser() && post.getType() != .USER
                    {
                        let alertView = UIAlertController(title: "Really?", message: "Are you sure you want to delete this post? Once you do it will be gone forever.", preferredStyle: .Alert)
                        alertView.addAction(UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.Default, handler: { (alertView:UIAlertAction!) -> Void in
                            
                            // Get the post we are working with, then remove it from datasource
                            let p = post.getRawPost()
                            self.posts.removeAtIndex(indexPath.row)
                            self.tableView.beginUpdates()
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                            self.tableView.endUpdates()
                            
                            // Delete from server, then from datastore and then update the table
                            p.deleteInBackgroundWithBlock({ (deleted:Bool, error:NSError?) -> Void in
                                p.fetchFromLocalDatastore()
                                p.deleteInBackgroundWithBlock({ (deleted:Bool, error:NSError?) -> Void in
                                    
                                }) 
                            })
                        }))
                        alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                        
                        presentViewController(alertView, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }

    // MARK: - Scroll view did end scrolling (check to load new data)
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size   = scrollView.contentSize
        let insets = scrollView.contentInset
        
        let y = offset.y + bounds.size.height - insets.bottom as CGFloat
        let h = size.height as CGFloat
        let r = 100 as CGFloat
        
        if y > (h + r) {
            oldLimit = limit
            limit += 10
            refresh_view(self)
        }
    }
    
    
    
    // MARK: - Scroll view did begin scrolling, check to hide navigation controller
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === self.tableView {
            topOffset = scrollView.contentOffset.y
        }
        var navHeight : CGFloat! = self.navigationController?.navigationBar.frame.height;
        let navWidth  : CGFloat! = self.navigationController?.navigationBar.frame.width;
        let topHeight : CGFloat! = UIApplication.sharedApplication().statusBarFrame.size.height
        
        if navHeight == nil
        {
            navHeight = 0
        }
        
        if let direction = swipeDirection
        {
            if(direction == UISwipeGestureRecognizerDirection.Down)
            {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.navigationController?.navigationBar.frame = CGRectMake(0, navHeight-topHeight-4, navWidth, navHeight)
                    self.statusBarView.hidden = true
                })
            }
            else if (direction == UISwipeGestureRecognizerDirection.Up && topOffset > navHeight*2)
            {
                self.statusBarView.frame = CGRectMake(0, self.topOffset, self.statusBarView.frame.width, self.statusBarView.frame.height)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.navigationController?.navigationBar.frame = CGRectMake(0, -navHeight, navWidth, navHeight)
                    }, completion:{(done:Bool) -> Void in
                        self.statusBarView.hidden = false
                })
            }
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

    
    // Segue methods...
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            // Set the post object dependent on which item we recieved
            if segue.identifier == "commentsText" || segue.identifier == "commentsMedia" {
                let p = self.posts[self.indexPathRowSelected.row] as Post!
                
                if p != nil {
                    let vc = segue.destinationViewController as! CommentsModalViewController
                    vc.post   = p
                    vc.author = User(newUser: p.getAuthor())
                }
            }
        })
    }
    
    // Set the size for the cell, not optimal but this will do for scope of assignment.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Caclulated height
        if let cellType : Post = posts[indexPath.row] as Post?
        {
            if cellType.getType() != nil
            {
                switch cellType.getType() as PostType
                {
                case .MEDIA:
                    return 390.0
                case .TEXT:
                    return 150.0
                case .USER:
                    return 300.0
                case .VERSUS:
                    return 210.0
                }
            } else {
                return 200.0
            }
        }
        // Anything that falls through
        return 150.0
    }
    
    // Checks our dictionary of animated cells, if the current cell wasn't found then apply the tip animation from the CellAnimator class
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        /*
        if (didAnimateCell[indexPath] == nil || didAnimateCell[indexPath] == false) && swipeDirection == UISwipeGestureRecognizerDirection.Up {
            didAnimateCell[indexPath] = true
            CellAnimator.animateCardIn(cell)
        }
        */
    }
}

