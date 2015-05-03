//
//  BasePanel.swift
//  MKWS
//
//  Created by Alex Sims on 15/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

// Need to use Objc protocol as swift doesn't allow optional delegates
@objc protocol BasePanelDelegate {
    optional func basePanelDidSelectRowAtIndex(index:Int)
    optional func basePanelDidConfirmDate(date:NSDate)
    optional func basePanelWillClose()
    optional func basePanelWillOpen()
}

// conforms to the base panel delegate
class BasePanel: NSObject, BasePanelTableViewControllerDelegate {
   
    let container:UIView = UIView()
    let blackOverlay:UIView = UIView()
    let title:UILabel = UILabel()
    let tableViewController:BasePanelTableViewController = BasePanelTableViewController()
    var originView:UIView?
    var picker:UIDatePicker?
    var confirmDate:UIButton?
    var panelWidth:CGFloat!
    var panelHeight:CGFloat!
    var tabBarHeight:CGFloat!
    var screenHeight:CGFloat!
    var topInset:CGFloat = 50
    var animator:UIDynamicAnimator!
    var delegate:BasePanelDelegate?
    var isOpen:Bool = false
    var isPickerView:Bool = false
    var aboveView:UIView?
    
    // Constructor
    override init()
    {
        super.init()
    }
    
    // Base initialiser
    // Initialises a new Base Panel object and binds it to the source view with a list of items to 
    // be rendered in its tableView delegate.  We also define any gesture recognisers for the panel here
    // We set items to have a default of empty array here
    init(sourceView: UIView, items:Array<String> = Array<String>(), aboveView: UIView)
    {
        super.init()
        
        // Bind the source view and set the items for the delegate
        originView = sourceView
        self.aboveView = aboveView
        tableViewController.tableData = items
        
        // Initialise a new animator
        animator = UIDynamicAnimator(referenceView: originView!)
        
        // Style the panel
        initBasePanel()
        
        // Configure gesture recognisers here
        let hidePanelRecogniser:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action:"handleSwipe:")
        hidePanelRecogniser.direction = UISwipeGestureRecognizerDirection.Down
        //let showPanelRecogniser:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action:"handleSwipe:")
        //showPanelRecogniser.direction = UISwipeGestureRecognizerDirection.Up
        
        originView?.addGestureRecognizer(hidePanelRecogniser)
        //originView?.addGestureRecognizer(showPanelRecogniser)
    }
    
    // Set new items for the tableView controller delegate
    func setItems(items:Array<String>)
    {
        tableViewController.tableData = items
        tableViewController.tableView.reloadData()
    }
    
    // Style the base panel, setting its height relative to the source view so that it only takes up just
    // under half of the display.
    func initBasePanel()
    {
        // Define the bounds of the frame
        panelWidth   = originView!.frame.size.width
        panelHeight  = originView!.frame.size.height * 0.55
        screenHeight = originView!.frame.size.height
        tabBarHeight = tabBarHeight == nil ? 50 : tabBarHeight
        
        // Set the frame for the container of this view based on the parent
        container.frame = CGRectMake(0, screenHeight, panelWidth, panelHeight)
        container.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        container.clipsToBounds = true
        
        originView?.insertSubview(container, aboveSubview:aboveView!)
        //originView?.addSubview(container)
    
        // Set the blur view
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = container.bounds
        container.addSubview(blurView)
        
        // Set up the table view and add it to the view
        tableViewController.delegate = self
        tableViewController.tableView.frame = container.bounds
        tableViewController.tableView.clipsToBounds = false
        tableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableViewController.tableView.backgroundColor = UIColor.clearColor()
        tableViewController.tableView.scrollsToTop = false
        tableViewController.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        tableViewController.tableView.reloadData()
            
        // Append the tableViewController delegate to this view
        container.addSubview(tableViewController.tableView)
        
        // Create the picker and hide it by default
        picker = UIDatePicker(frame: CGRectMake(0, 40, container.frame.size.width, container.frame.size.height))
        container.addSubview(picker!)
        picker!.hidden = true

        // Create the confirm button and hide it by default
        confirmDate = UIButton(frame: CGRectMake(0, container.frame.height-65, container.frame.width, 65))
        confirmDate?.setTitle("Confirm", forState: UIControlState.Normal)
        confirmDate?.backgroundColor = UIColor(red: 2/255, green: 192/255, blue: 77/255, alpha: 1)
        confirmDate?.titleLabel?.font.fontWithSize(24)
        confirmDate?.addTarget(self, action: "basePanelDidSelectDate", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(confirmDate!)
        confirmDate?.hidden = true
        
        // Build the title bar
        let titleBar = UIView(frame: CGRectMake(0, 0, originView!.frame.width, 50))
        titleBar.backgroundColor = UIColor(red: 34/255, green: 80/255, blue: 212/255, alpha: 0.98)
        container.addSubview(titleBar)
        
        // Set the title
        title.frame = CGRectMake(0, 0, titleBar.frame.width, titleBar.frame.height)
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        titleBar.addSubview(title)
    }
    
    // Notifies the delegate and handles if panel should open or close
    func handleSwipe(recogniser:UISwipeGestureRecognizer)
    {
        let direction = recogniser.direction
        
        switch(direction)
        {
        case UISwipeGestureRecognizerDirection.Down:
            showBasePanel(false)
            delegate?.basePanelWillClose?()
        default:
            showBasePanel(true)
            delegate?.basePanelWillOpen?()
        }
    }
    
    // Define the animators properties for the view
    func showBasePanel(open:Bool)
    {
        animator.removeAllBehaviors()
        isOpen = open
        
        // Define constants to be plugged into animator
        let gravityY:CGFloat  = (open) ? -8.0 : 6.0
        let boundaryY:CGFloat = panelHeight
        let boundaryX:CGFloat = panelWidth
        
        // animator behaviours
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [container])
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items:[container])
        let panelBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items:[container])
        
        // Set the behvaiours
        panelBehavior.allowsRotation = false
        panelBehavior.elasticity = 0.3
        
        // Set collision behaviours
        collisionBehavior.addBoundaryWithIdentifier("upperBoundary", fromPoint: CGPointMake(0, screenHeight - panelHeight - tabBarHeight), toPoint: CGPointMake(boundaryX, screenHeight - panelHeight - tabBarHeight))
        collisionBehavior.addBoundaryWithIdentifier("lowerBoundary", fromPoint: CGPointMake(0, screenHeight+panelHeight + tabBarHeight), toPoint: CGPointMake(boundaryX, screenHeight+panelHeight + tabBarHeight))
        gravityBehavior.gravityDirection = CGVectorMake(0, gravityY)
        
        // set the animator behvaiours
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(panelBehavior)
        animator.addBehavior(collisionBehavior)
        
        // Handle the black overlay
        blackOverlay.frame = CGRectMake(0, 0, originView!.frame.size.width, originView!.frame.size.height)
        
        if open
        {
            blackOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
            originView?.insertSubview(blackOverlay, belowSubview: container)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.blackOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            })
        } else {
            UIView.animateWithDuration(0.75, animations: { () -> Void in
                    self.blackOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
                }) { (completed:Bool) -> Void in
                    if(completed)
                    {
                        self.blackOverlay.removeFromSuperview()
                    }
            }
        }
        
        // Determine if we're using a picker view
        if isPickerView
        {
            picker!.hidden = false
            confirmDate!.hidden = false
            tableViewController.tableView.hidden = true
        }
        else
        {
            picker!.hidden = true
            confirmDate!.hidden = true
            tableViewController.tableView.hidden = false
        }
    }
    
    // Update the title
    func setTitle(newTitle: String)
    {
        title.text = newTitle
    }
    
    // Notify the delegate that a new date has been selected
    func basePanelDidSelectDate()
    {
        if let date:NSDate = picker?.date {
            delegate?.basePanelDidConfirmDate!(date)
        }
    }
    
    // Delegate method to get the selected data
    func basePanelDidSelectRow(indexPath: NSIndexPath) {
        delegate?.basePanelDidSelectRowAtIndex!(indexPath.row)
    }
}
