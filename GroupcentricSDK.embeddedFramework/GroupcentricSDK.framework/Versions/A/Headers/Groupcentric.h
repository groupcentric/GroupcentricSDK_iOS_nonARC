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
//  Groupcentric.h
//  Groupcentric SDK
//


#import <Foundation/Foundation.h>
#import "gc_Object.h"
#import "gc_Friend.h"
#import "gc_Group.h"
#import "gc_Message.h"
#import "gc_Notification.h"
#import "gc_NewMessage.h"
#import "gc_Request.h"


typedef void (^gc_RequestBooleanCallback)(BOOL success, NSError *error);
typedef void (^gc_RequestArrayCallback)(NSArray *objects, NSError *error);
typedef void (^gc_RequestIntegerCallback)(int value, NSError *error);
typedef void (^gc_RequestGroupCallback)(gc_Group *group, NSError *error);


#define GROUPCENTRIC_MESSAGE_TYPE_TEXT 0
#define GROUPCENTRIC_MESSAGE_TYPE_PHOTO 1
#define GROUPCENTRIC_MESSAGE_TYPE_LOCATION 2
#define GROUPCENTRIC_MESSAGE_TYPE_URL 3
#define GROUPCENTRIC_MESSAGE_TYPE_OBJECT 4


@interface Groupcentric : NSObject <gc_RequestDelegate> {
    
    NSString                *_apiKey; // Groupcentric API key (available at groupcentric.com)
    NSString                *_deviceToken; // Urban airship token
    int                     userId;
    NSString                *userPhoneNumber;
    NSString                *userFullName;
    NSString                *userProfileImage;
    
    NSDateFormatter         *dateFormatter;
    
}

//////////////////////////////////////////////////////////////////////////////////////////////
//
// Initialization
//
//////////////////////////////////////////////////////////////////////////////////////////////

// Initialize the singleton instance
// Set API key which is stored locally
// Recommended to implement in app delegate didFinishLaunchingWithOptions
+ (id)setupWithAPIKey:(NSString *)apiKey andLaunchOptions:(NSDictionary *)options;

// Create the singleton instance
// Use this to make API calls from any view controller
// Just call [[Groupcentric sharedInstance] someMethodHere];
+ (id)sharedInstance;


//////////////////////////////////////////////////////////////////////////////////////////////
//
// API Calls
//
//////////////////////////////////////////////////////////////////////////////////////////////

// Registering requires a phone number, and sends a text with a passcode
-(void)registerStartWithPhone:(NSString *)phoneNumber
                       result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// After user has received passcode, can should finish registration
-(void)registerFinishWithPhone:(NSString *)phoneNumber
                   andUserName:(NSString *)name
                   andPasscode:(int)passcode
                        result:(gc_RequestIntegerCallback)block;
/*
 Returns:
 int         0 = fail, >1 = userid
 NSError     Server side error returned, nil if no error
 */

// After user has received passcode, they can finish registeration with Urban Airship token for push notifications
// Device tokens are received in the App Delegate upon registering for push notifications
-(void)registerFinish_AlreadyRegisteredAppWithUAwithPhone:(NSString *)phoneNumber
                                              andUserName:(NSString *)name
                                              andPasscode:(int)passcode
                                           andDeviceToken:(NSString *)token
                                                   result:(gc_RequestIntegerCallback)block;
/*
 Returns:
 int         0 = fail, >1 = userid
 NSError     Server side error returned, nil if no error
 */

// Update a user's account with an Urban Airship token for push notifications
// Device tokens are received in the App Delegate upon registering for push notifications
-(void)updateUAToken:(NSString *)token
              result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Login a user using an email or phone number and a password
-(void)login:(NSString *)phoneOrEmail
    password:(NSString *)psswrd
      result:(gc_RequestIntegerCallback)block;
/*
 Returns:
 int         0 = fail, >1 = userid
 NSError     Server side error returned, nil if no error
 */

// Check if the user has registered their phone number already
-(void)isRegisteredPhone:(NSString *)phoneNumber
                  result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = registered, NO = unregistered
 NSError     Server side error returned, nil if no error
 */

// Texts a new passcode to the user's phone
-(void)forgotPasscodeForPhone:(NSString *)phoneNumber
                       result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Retrieve the list of user's groups
-(void)getGroups:(gc_RequestArrayCallback)block;
/*
 Returns:
 NSArray     gc_Group objects
 NSError     Server side error returned, nil if no error
 */

// Retrieve the details of a group chat and the friends within the group
-(void)openGroup:(int)groupId
          result:(gc_RequestGroupCallback)block;
/*
 Returns:
 gc_Group     Group details
 NSError     Server side error returned, nil if no error
 */

// Start a new group chat
// Image to upload should be a URL string
// If there is no image to upload, then just leave the image field as a blank string
-(void)startGroupWithTitle:(NSString *)grpTitle
                  andImage:(NSString *)grpImg
                andMessage:(NSString *)msg
               andContacts:(NSArray *)cntcts
                    result:(gc_RequestGroupCallback)block;
/*
 Returns:
 gc_Group     Group details
 NSError     Server side error returned, nil if no error
 */


// Start a new group based around an object (e.g. a place or event)
-(void)startGroupWithTitle:(NSString *)grpTitle
                  andImage:(NSString *)grpImg
                andMessage:(NSString *)msg
               andContacts:(NSArray *)cntcts
                 andObject:(gc_Object *)object
                    result:(gc_RequestGroupCallback)block;
/*
 Returns:
 gc_Group     Group details
 NSError     Server side error returned, nil if no error
 */


// Add friends to an existing group
-(void)addFriendsToGroup:(int)groupId
             withFriends:(NSArray *)newFriends
                  result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Remove an existing group
-(void)removeGroup:(int)groupId
            result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Change the details of the group
-(void)editGroup:(int)groupId
   withGroupName:(NSString *)groupName
   andGroupImage:(NSString *)groupPic
          result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Send a message to the members of the group
-(void)sendMessage:(gc_Message *)message
            result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Stop sending push notifications to a user in a specific group
-(void)togglePushNotificationsForGroup_OffForGroup:(int)groupId
                                            result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Start sending push notificatinos to a user in a specific group
-(void)togglePushNotificationsForGroup_OnForGroup:(int)groupId
                                           result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */


// Toggle the sending of push notifications for a specific group
-(void)togglePushNotificationsForGroup:(int)groupId
                                turnOn:(BOOL)on
                                result:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 NSError     Server side error returned, nil if no error
 */

// Get new notifications and the notification count
-(void)getNotifications:(gc_RequestArrayCallback)block;
/*
 Returns:
 NSArray     gc_Notification objects
 NSError     Server side error returned, nil if no error
 */

// Update the Groupcentric object with the correct information about the user
-(void)getProfile:(gc_RequestBooleanCallback)block;
/*
 Returns:
 BOOL        YES = success, NO = fail
 Success means that the Groupcentric object will now have proper userFullName and userProfileImage
 */


//////////////////////////////////////////////////////////////////////////////////////////////
//
// Local functions
//
//////////////////////////////////////////////////////////////////////////////////////////////

// Log the user out
// Remove all data such as stored id, name, and phone number
-(void)logout;

// Save the phone number
// Stores it on groupcentric object and locally on NSUserDefaults
-(void)saveNewUserPhoneNumber:(NSString *)phone;

// Save the user's full name
// Stores it on groupcentric object and locally on NSUserDefaults
-(void)saveNewUserFullName:(NSString *)name;

// Save the user's image URL
// Stores it on groupcentric object and locally on NSUserDefaults
-(void)saveNewUserProfileImage:(NSString *)imgURL;

// Register for push notifications
// Must include receiver function "saveDeviceToken:" in app delegate under didRegisterForRemoteNotifications
-(void)registerWithUAWithLaunchOptions:(NSDictionary *)launchOptions;

// Save the user's device token for push notifications
// Must be placed in didRegisterForRemoteNotifications
-(void)saveDeviceToken:(NSData *)token;

// Called upon didEnterBackground
-(void)didEnterBackground;

// Called in the app delegate after "applicationWillTerminate"
-(void)terminate;

//called in the app delegate to reset the badge in aplicationsdidbecomeactive
-(void)resetBadge;



//////////////////////////////////////////////////////////////////////////////////////////////
//
// Properties
//
//////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly, assign) int userId;
@property (nonatomic, retain) NSString *_apiKey;
@property (nonatomic, retain) NSString *_deviceToken;
@property (nonatomic, retain) NSString *userPhoneNumber;
@property (nonatomic, retain) NSString *userFullName;
@property (nonatomic, retain) NSString *userProfileImage;

@property (nonatomic, copy) gc_RequestBooleanCallback booleanCallbackBlock;
@property (nonatomic, copy) gc_RequestArrayCallback arrayCallbackBlock;
@property (nonatomic, copy) gc_RequestIntegerCallback integerCallbackBlock;
@property (nonatomic, copy) gc_RequestGroupCallback groupCallbackBlock;



@end
