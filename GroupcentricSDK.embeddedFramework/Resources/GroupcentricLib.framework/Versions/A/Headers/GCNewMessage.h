//
//  GCNewMessage.h
//  Groupcentric
//
//  Created by Tom Bachant on 8/21/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"


@interface GCNewMessage : NSObject

// required
@property (nonatomic, assign) int           groupId;
@property (nonatomic, strong) NSString *    message;

// optional
@property (nonatomic, assign) int           type;
@property (nonatomic, strong) NSString *    imageURL;
@property (nonatomic, strong) GCObject *    object;
/*
@property (nonatomic, strong) NSString *    var1;
@property (nonatomic, strong) NSString *    varTitle;
@property (nonatomic, strong) NSString *    varSubtitle;
@property (nonatomic, strong) NSDate   *    varDate;
@property (nonatomic, strong) NSString *    varDetails;
@property (nonatomic, strong) NSString *    varMarkup;
 */

-(id)initWithMessage:(NSString *)message forGroup:(int)groupId;

+(id)messageWithMessage:(NSString *)message forGroup:(int)groupId;

@end
