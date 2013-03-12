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
//  ViewController.h
//  Groupcentric SDK
//
//  At the bottom of a users Group list in the GC_ViewController is a 'My Profile' button that opens up this VC


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GCGroupListTableViewCell.h"
#import "gc_ASIFormDataRequest.h"
#import <GroupcentricLib/Groupcentric.h>
#import "GCGroupDetailsVC.h"
#import "GCNewGroupVC.h"
#import "GCNotificationsVC.h"
#import "GCWebBrowserVC.h"
#import "gc_TTTTimeIntervalFormatter.h"
#import "gc_EGORefreshTableHeaderView.h"

@interface GCProfileVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, gc_ASIHTTPRequestDelegate> {
    
    // The main table view
    IBOutlet UITableView *theTableView;
}

// Get the basic information about the user's profile
- (void)getProfile;

// Log the user out
- (void)logout;

// Upload a photo for the user's image
- (void)uploadUserImage;

// Dismiss the notifications view controller
- (void)close;

@end
