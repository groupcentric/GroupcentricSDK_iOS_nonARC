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
//  NewGroupVC.h
//  Groupcentric SDK
//
//  This lil beaut is the VC when a user is starting a new group


#import <UIKit/UIKit.h>
#import "gc_TKPeoplePickerController.h"
#import "gc_GroupDetailsVC.h"
//#import "gc_SharedObject.h"

@interface gc_NewGroupVC : UIViewController <UITableViewDataSource, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, gc_TKPeoplePickerControllerDelegate> {
    
    // The title of the group
    UITextField *titleText;
    
    //the shared item
    UILabel *sharedTitle;
    
    // The label of friends
    UILabel *friendsLabel;
    
    // The message text
    UITextView *messageText;
    
    // The friends who are being added
    NSMutableArray *friendsTable;
    
    // The table view
    IBOutlet UITableView *theTableView;
    
    //possible object shared externally into this group via shareselector
    BOOL fromSharedSelector;
    gc_SharedObject *sharedObject;
    
}

// Choose contacts to add to a group
- (void)pickFriends;

// Just an easier way to automatically reload the table with an animation;
- (void)reloadTheTableAnimated;

// This action is called when the "Start" button is tapped
// It should check for a valid title, and check if there's an image to upload
// If there's an image, upload it and wait for upload to finish
// Otherwise, just call finishSavingGroupMakeAPI call
- (void)startGroup;

// Dismiss the view controller without saving
- (void)close;

// After successfully saving a group, send to group details
- (void)openNewGroupDetails:(gc_Group *)group;

-(id) initWithSharedObject:(gc_SharedObject *)sharedObj;

@end
