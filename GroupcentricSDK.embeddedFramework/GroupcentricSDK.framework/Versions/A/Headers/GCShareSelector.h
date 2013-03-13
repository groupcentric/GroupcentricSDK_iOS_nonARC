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
//  gc_shareSelector.h
//  Groupcentric SDK
//
//  This is the VC used when a user is in your app and wants to share your content into one of their groups


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GCGroupListTableViewCell.h"
#import <GroupcentricLib/Groupcentric.h>
#import "GCGroupDetailsVC.h"
#import "GCNewGroupVC.h"
#import "gc_TTTTimeIntervalFormatter.h"
//#import "gc_SharedObject.h"
#import "GCSignupOrLoginVC.h"


@interface GCShareSelector : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // signup ----------------------
    IBOutlet UIButton *GetStartedButton;
    IBOutlet UIView *getStartedView;
    IBOutlet UIButton *PrivacyTosButton;
    
    // The main table view
    IBOutlet UITableView *theTableView;
    IBOutlet UIImageView *imageShared;
    IBOutlet UILabel *titleShared;
    
    // Array of GCGroup objects
    NSMutableArray *myGroups;
    
    // Array of arrays containing at least 1 LoadImageRequest object
    // Can contain up to 4 LoadImageRequest objects in each subarray
    NSMutableArray *myGroupImages;
    
    
    // Date formatter that uses the form "2 minutes ago", "1 day ago", etc.
    gc_TTTTimeIntervalFormatter *dateFormatter;
    
    BOOL _reloading;
   
    
    GCSharedObject *sharedObject;
}


-(id) initWithContent:(GCSharedObject *)sharedObj;

// Get the list of groups
- (void)getGroups;

// Get Started Signing in
- (void)getStarted:(id)sender;

// open privacytos
- (void)viewPrivacyTos:(id)sender;

@end
