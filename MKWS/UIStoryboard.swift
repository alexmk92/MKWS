//
//  StoryboardExtension.swift
//  MKWS
//
//  Created by Alex Sims on 21/04/2015.
//  Copyright (c) 2015 Alexander Sims. All rights reserved.
//

import Foundation

extension UIStoryboard
{
    // Returns the reference to the main storyboard
    class func mainStoryboard()     -> UIStoryboard { return UIStoryboard(name:"Main", bundle: NSBundle.mainBundle()) }
    class func gameStoryboard()     -> UIStoryboard { return UIStoryboard(name:"Game", bundle: NSBundle.mainBundle()) }
    class func chatStoryboard()     -> UIStoryboard { return UIStoryboard(name:"Chat", bundle: NSBundle.mainBundle()) }
    class func settingsStoryboard() -> UIStoryboard { return UIStoryboard(name:"Settings", bundle: NSBundle.mainBundle()) }
    class func eventsStoryboard()   -> UIStoryboard { return UIStoryboard(name:"Events", bundle: NSBundle.mainBundle()) }
    
    // Returns a notification view controller
    class func notificationViewController() -> NotificationViewController?
    {
        return mainStoryboard().instantiateViewControllerWithIdentifier("notificationVC") as? NotificationViewController
    }
    // Returns a finding matches view controller
    class func findingResultsViewController() -> FindingMatchesViewController?
    {
        return gameStoryboard().instantiateViewControllerWithIdentifier("searchingVC") as? FindingMatchesViewController
    }
    // Returns a messages view controller
    class func messageThreadViewController() -> MessageThreadViewController?
    {
        return chatStoryboard().instantiateViewControllerWithIdentifier("MessageThreadVC") as? MessageThreadViewController
    }
    // Returns the results view controller
    class func matchResultTableViewController() -> MatchResultTableViewController?
    {
        return gameStoryboard().instantiateViewControllerWithIdentifier("matchResultsVC") as? MatchResultTableViewController
    }
    // Returns the calendar view controllers
    class func calendarViewController() -> CalendarTableViewController?
    {
        return eventsStoryboard().instantiateViewControllerWithIdentifier("calendarVC") as? CalendarTableViewController
    }
    // Returns the stats view controller
    class func userStatsViewController() -> UserStatsViewController?
    {
        return eventsStoryboard().instantiateViewControllerWithIdentifier("userStatsVC") as? UserStatsViewController
    }
}