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
//  GroupDetailsVC.h
//  Groupcentric
//
//  This view controller will display the details of a group selected from the groups list.
//  It will display 3 tabs: chat, friends, details.
//  The chat contains a bit of functionality to display different attachments with messages,
//  handle tapping of those attachments, attaching objects when sending messages, etc..
//  The friends tab lists the friends in this group, can display their location, and invite more.
//  The details tab has the abitlity to toggle push notifications on/off for the group for the user
//  as well as changing the group image and title.


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "gc_UIImageView+WebCache.h"
#import <GroupcentricLib/Groupcentric.h>
#import "GCGroupChatTableViewCell.h"
#import "GCGroupFriendTableViewCell.h"
#import "gc_TTTTimeIntervalFormatter.h"
#import "gc_MWPhotoBrowser.h"
#import "GCWebBrowserVC.h"
#import "GCObjectDetailsVC.h"
#import "GCMapVC.h"
#import "gc_LoadImageRequest.h"
#import "gc_TKPeoplePickerController.h"
#import "gc_ASIFormDataRequest.h"
//#import "gc_SharedObject.h"


@protocol GroupDetailsDelegate <NSObject>
-(void) tellGroupsVCToRefresh;
@end

@interface GCGroupDetailsVC : UIViewController
<gc_TKPeoplePickerControllerDelegate,
gc_ASIHTTPRequestDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITableViewDelegate,
UITableViewDataSource,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITextViewDelegate,
UITextFieldDelegate,
CLLocationManagerDelegate> {
    
    // Set up a variable for the Groupcentric shared instance, just to make things eaiser
    Groupcentric *groupcentric;

    // The group that will be viewed
    GCGroup *myGroup;
    
    // Array of LoadImageRequest objects for loading images of friends
    NSMutableArray *friendImages;
    
    // Array of LoadImageRequest objects for messages
    // Includes user pic and an attachment pic if available
    NSMutableArray *chatImages;
    
    IBOutlet UITableView *theTableView;
    
    //possible object shared externally into this group via shareselector
    BOOL fromSharedSelector;
    BOOL goBackToObjectDetails;
    GCSharedObject *sharedObject;
    
        
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Chat tab
    //
    // View for adding a photo or location after tapping "+" button in bottom left
    IBOutlet UIView *addPhotoOrLocationView;
    BOOL addingSomething;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Friends tab
    //
    // Hmmm seems like we won't need anything there yet
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Details tab
    //
    // Image that loads group image
    UIImageView *groupImage;
    // Text field with group name; can be edited and resaved
    UITextField *groupNameEditableField;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Bottom Bar
    //
    IBOutlet UIView *bottomBar;
    // Chat
    IBOutlet UIImageView *bottomMessageBackground;
    IBOutlet UITextView *messageText;
    IBOutlet UIButton *sendButton;
    IBOutlet UIButton *locationButton;
    // Friends
    IBOutlet UIView *bottomFriendsView;
    IBOutlet UILabel *friendsCountLabel;
    // Details
    IBOutlet UIView *bottomDetailsView;
    IBOutlet UILabel *groupCreatorLabel;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Top Bar
    //
    IBOutlet UIView *topToggle;
    IBOutlet UIButton *topChatButton;
    IBOutlet UIButton *topFriendsButton;
    IBOutlet UIButton *topDetailsButton;
    IBOutlet UIButton *topDetailsButton2;
    UIButton *selectedButton;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Miscellaneous
    //
    // Check if the chat has been loaded initially
    BOOL initialized;
    // Date formatter for messages
    gc_TTTTimeIntervalFormatter *dateFormatter;
    // Should the back button dismiss the modal view controller
    // This would be YES if this view controller is not a part of the navigation tree
    // This is usually set in the case of creating a new group, and set in the init method
    BOOL shouldDismissViewController;
    // Get a location manager in case the user wants to share their location
    CLLocationManager *locationManager;
    // Set up variables for attachments
    UIImage *imageToAttach;
    BOOL attachingImage;
    BOOL attachingLocation;
    // Check if the view should be prevented from scrolling to the bottom
    // This would be the case if they viewed an attachment within the chat, as they would want to stay at the current point in the chat
    BOOL shouldNotReload;
    BOOL _reloading;
    BOOL _backButtonBlackColorFromModal;
}

@property (assign) id <GroupDetailsDelegate> delegate;
@property (nonatomic, assign) CGFloat previousContentHeight;

// If the view controller is coming from the NewGroupVC, then the back button will dismiss it entirely
// Otherwise, the nav bar will naturally send it back through the navigation hierarchy
- (void)goBack;

- (void)updateTextViewContentSize:(UITextView *)textView;
- (void)setChatBarHeight:(CGFloat)height;
- (void)scrollToBottomAnimated:(BOOL)animated;

// Handle the keyboard change
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)resizeBottomBarWithOptions:(NSDictionary *)options;

// Top toggle actions
- (IBAction)toggleChat:(id)sender;
- (IBAction)toggleFriends:(id)sender;
- (IBAction)toggleDetails:(id)sender;

// Get the group details with the API call
- (void)getGroupDetails;

// Actions related to chat
- (IBAction)addSomething; // Attach a photo or location
- (void)hideAddSomethingView; // Hide the view for attaching photo or location
- (IBAction)sendMessage;
- (void)sendMessageWithImage; // We're not using the standard API call for this
- (IBAction)attachLocation;
- (IBAction)attachPhoto;
- (void)removePhotoAttachment;
- (void)removeLocationAttachment;
-(void)removeSharedObjectAttachment;

// Actions related to friends
- (IBAction)addMoreFriends;

// Actions related to details
- (void)editImage;
- (void)saveGroupName;
- (void)cancelNameEdit;
- (void)deleteGroup;
- (void)toggleNotifications:(id)sender;

-(id)initWithGroup:(GCGroup *)group;
-(id)initWithGroup:(GCGroup *)group andShouldDismissModalViewController:(BOOL)shouldDismiss;
-(id)initWithGroup:(GCGroup *)group andShouldDismissModalViewController:(BOOL)shouldDismiss andFromNotifications:(BOOL)fromNotifications;
//init function for when sharing an object from another app via the gc_ShareSelector
-(id)initWithGroup:(GCGroup *)group andWithSharedObject:(GCSharedObject *)sharedObj;

@end
