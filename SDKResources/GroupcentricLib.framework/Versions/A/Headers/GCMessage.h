//
//  GCMessage.h
//  Groupcentric
//
//  Created by Tom Bachant on 8/20/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"

@interface GCMessage : NSObject {
    
}

@property (nonatomic, assign) BOOL          userIsSelf; // should be NO if user is a friend
@property (nonatomic, assign) int           userId;
@property (nonatomic, strong) NSString *    userName;
@property (nonatomic, strong) NSString *    userImage;
@property (nonatomic, assign) int           groupId;
@property (nonatomic, strong) NSString *    message;
@property (nonatomic, strong) NSDate   *    date;
@property (nonatomic, assign) int           type;
@property (nonatomic, strong) NSString *    attachmentImage;
@property (nonatomic, assign) double        latitude;
@property (nonatomic, assign) double        longitude;
@property (nonatomic, strong) GCObject *    object;
@property (nonatomic, strong) NSString *    brand;
@property (nonatomic, strong) NSString *    brandURL;


/*
@property (nonatomic, strong) NSString *    var1;
@property (nonatomic, strong) NSString *    varTitle;
@property (nonatomic, strong) NSString *    varSubtitle;
@property (nonatomic, strong) NSDate   *    varDate;
@property (nonatomic, strong) NSString *    varDetails;
@property (nonatomic, strong) NSString *    varMarkup;
@property (nonatomic, strong) NSString *    brand;
@property (nonatomic, strong) NSString *    brandURL;
@property (nonatomic, assign) int           phoneType;
 */


@end
