//
//  gc_Group.h
//  Groupcentric
//
//  Created by Tom Bachant on 8/20/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface gc_Group : NSObject {
    
}

//
// Basic group information
// These properties will be returned when calling either "GetGroupDetails" or "GetGroups"
//

@property (nonatomic, assign) int               groupId;
@property (nonatomic, strong) NSString *        groupName;
@property (nonatomic, strong) NSString *        image;
@property (nonatomic, strong) NSDate   *        date;
@property (nonatomic, strong) NSMutableArray *  friends; // Array of gc_Friend objects

//
// Group details properties
// These properties will be returned when calling "GetGroupDetails"
//
@property (nonatomic, strong) NSString *        groupCreator;
@property (nonatomic, strong) NSString *        friendLocationURL;
@property (nonatomic, strong) NSMutableArray *  messages; // Array of gc_Message objects
@property (nonatomic, strong) NSMutableArray *  sharedImages; // Array of strings, includes all images shared into the group
@property (nonatomic, assign) BOOL              pushEnabled;

//
// Group list properties
// These properties will be returned when calling "GetGroups"
//
@property (nonatomic, strong) NSDate *          lastUpdated;
@property (nonatomic, assign) BOOL              hasNewContent;
@property (nonatomic, assign) int               friendsCount;
@property (nonatomic, assign) int               messagesCount;
@property (nonatomic, strong) NSString *        lastMessageText;
@property (nonatomic, strong) NSString *        lastMessageName;
@property (nonatomic, strong) NSString *        lastMessageImage;
@property (nonatomic, strong) NSString *        lastMessageDate;

@end
