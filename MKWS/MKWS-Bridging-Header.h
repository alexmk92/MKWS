/*
 |------------------------------------------------------------------------------
 | Bridging Header
 |------------------------------------------------------------------------------
 | This header allows Objective-C legacy components to be used in conjunction
 | with SWIFT, simply by including the .h file of the Objective C class.
 | 
 | In this app, its purposes is to link the Parse framework with the Swift
 | application, as Parse is currently an Objective-C only framework.
 |
 | @copyright -
 | You may download and use this code for your own educational
 |            | purposes, do not try to claim this piece as your own work unless
 |            | you modify at least 50% of the code, even then provide credit
 |            | where necessary.
 |            -
 |
 | @author    - Alexander Sims
 | @contact   - alexander.sims92@gmail.com
 |
 |------------------------------------------------------------------------------
 */

// Parse includes
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

// NSDate helper library
#import "NSDate+Utilities.h"

// JSQ Custom messaging view controller and its dependencies
#import "JSQMessages.h"