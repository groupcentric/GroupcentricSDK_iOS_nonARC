/*
 Copyright 2010-2013 Shizzlr Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE SHIZZLR INC``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  NotificationsVC.h
//  Groupcentric SDK
//
//  This is the VC that lists the notifications (new groups/unread messages/etc)


#import <UIKit/UIKit.h>
#import <GroupcentricLib/Groupcentric.h>
#import "gc_TTTTimeIntervalFormatter.h"
#import "gc_EGORefreshTableHeaderView.h"
#import "gc_NotificationTableViewCell.h"
#import "gc_WebBrowserVC.h"
#import "gc_GroupDetailsVC.h"
#import "gc_LoadImageRequest.h"

@interface gc_NotificationsVC : UITableViewController <EGORefreshTableHeaderDelegate> {
    
    // This will be an array of GCNotification objects
    NSMutableArray *notifications;
    
    // This will be an array of LoadImageRequest objects, each of which will correspond to a notification
    // This array will load images as they appear to reduce load time
    NSMutableArray *notificationImages;
    
    // This time formatter will put the date in the format "2 minutes ago", "1 day ago", etc.
    gc_TTTTimeIntervalFormatter *timeFormatter;
    
    // Set up the pull to refresh
    gc_EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

// Update notifications
- (void)getNotifications;

// Dismiss the notifications view controller
- (void)close;

// The main view controller can transfer notifications to this controller if they've already loaded
- (id)initWithNotifications:(NSMutableArray *)notifs;

@end
