//
//  SideBar.swift
//  MKWS
//
//  Created by Alex Sims on 17/01/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import UIKit

// Toggle methods for the side bar - must be an objective c protocol to implement optionals
// as SWIFT will behave like any other OO language, where all interfaces must be implemented
@objc protocol SideBarDelegate {
    func sideBarDidSelectRowAtIndex(index:Int)
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
   
    let barWidth:CGFloat = 200.0
    let sideBarTableViewTopInset:CGFloat = 65.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    let originView:UIView!
    let animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
    
    var isSideBarOpen:Bool = false
    
    override init() {
        super.init()
    }
    
    init(sourceView: UIView) {
        super.init()
    }
    
    init(sourceView: UIView, menuItems:Array<String>) {
        super.init()
        originView = sourceView
        sideBarTableViewController.tableData = menuItems
        
        animator = UIDynamicAnimator(referenceView: originView)
        
        initSidebar()
        
        // Bind the gesture recogniser to the
        let showGestureRecogniser:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecogniser.direction = UISwipeGestureRecognizerDirection.Right
        originView.addGestureRecognizer(showGestureRecogniser)
        
        let hideGestureRecogniser:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecogniser.direction = UISwipeGestureRecognizerDirection.Left
        originView.addGestureRecognizer(hideGestureRecogniser)
    }
    
    // Set up the sidebar
    func initSidebar() {
        
        sideBarContainerView.frame = CGRectMake(-barWidth-1, originView.frame.origin.y, barWidth, originView.frame.size.height)
        sideBarContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        sideBarContainerView.clipsToBounds = false
        
        // Add the sidebar to the parent window
        originView.addSubview(sideBarContainerView)
        
        // Set up a blur component and clip it to the rect we have drawn (sidebar)
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
    }
    
    // Invoke the didSelectRowAtIndexPath method in the delegate
    func sideBarControlDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectRowAtIndex(indexPath.row)
    }
    
    //
    func handleSwipe(recogniser:UISwipeGestureRecognizer){
        switch(recogniser.direction)
        {
            
        case UISwipeGestureRecognizerDirection.Left:
            
            showSideBar(false)
            delegate?.sideBarWillClose?()
            
        case UISwipeGestureRecognizerDirection.Right:
            
            showSideBar(true)
            delegate?.sideBarWillOpen?()
            
        // Does not currently support Top and Bottom swipe gestures...
        default:
            println("Undefined direction behaviour")
            
        }
    }
    
    func showSideBar(isOpen: Bool) {
        
        animator.removeAllBehaviors()
        isSideBarOpen = isOpen
        
        // Animator params
        let gravityX:CGFloat   = (isOpen) ? 0.7 : -0.7
        let gravityY:CGFloat   = (isOpen) ? 0   : 0
        let magnitude:CGFloat  = (isOpen) ? 50  : -50
        let boundaryX:CGFloat  = (isOpen) ? barWidth : -barWidth-1
        let elasticity:CGFloat = 0.3
        
        
        // 
        let gravityBehaviour:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        let collisionBehaviour:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        let pushBehaviour:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        let elasticityBehaviour:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        
        gravityBehaviour.gravityDirection = CGVectorMake(gravityX, gravityY)
        collisionBehaviour.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        pushBehaviour.magnitude = magnitude
        elasticityBehaviour.elasticity = elasticity
        
        
        animator.addBehavior(gravityBehaviour)
        animator.addBehavior(collisionBehaviour)
        animator.addBehavior(pushBehaviour)
        animator.addBehavior(elasticityBehaviour)

    }
    
    // Accessor methods for theme stuff
    func loadFriends() {
    
    }
}
