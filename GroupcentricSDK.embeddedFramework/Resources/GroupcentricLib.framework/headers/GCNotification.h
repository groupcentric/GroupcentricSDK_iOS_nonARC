//
//  GCNotification.h
//  TestingLIb
//
//  Created by Tom Bachant on 9/1/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Groupcentric.h"

@interface GCNotification : NSObject

@property (nonatomic, strong) NSString *    title;
@property (nonatomic, strong) NSString *    subtitle;
@property (nonatomic, strong) NSString *    imageURL;
@property (nonatomic, strong) NSDate   *    date;
@property (nonatomic, assign) BOOL          unread;
@property (nonatomic, assign) int           action;
@property (nonatomic, strong) NSString *    actionVariable;

@end
