//
//  GCFriend.h
//  Groupcentric
//
//  Created by Tom Bachant on 8/20/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Groupcentric.h"

@interface GCFriend : NSObject {
    
}

// Generic friend properties
@property (nonatomic, strong) NSString *    name;
@property (nonatomic, strong) NSString *    image;
@property (nonatomic, strong) NSString *    phone;

// Friend properties returned in group details
@property (nonatomic, strong) NSString *    thumbnail;
@property (nonatomic, assign) double        latitude;
@property (nonatomic, assign) double        longitude;
@property (nonatomic, strong) NSString *    location;
@property (nonatomic, assign) BOOL          userIsSelf;

-(id)initWithFriendName:(NSString *)name andPhone:(NSString *)phone andImage:(NSString *)image;
+(id)friendWithName:(NSString *)name andPhone:(NSString *)phone andImage:(NSString *)image;

@end
