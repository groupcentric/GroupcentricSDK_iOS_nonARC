//
//  GCObject.h
//  Groupcentric
//
//  Created by Tom Bachant on 8/21/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCObject : NSObject

@property (nonatomic, assign) int           type;
@property (nonatomic, strong) NSString *    imageURL;
@property (nonatomic, strong) NSString *    var1;
@property (nonatomic, strong) NSString *    varTitle;
@property (nonatomic, strong) NSString *    varSubtitle;
@property (nonatomic, strong) NSString *    varDateString;
@property (nonatomic, strong) NSString *    varDetails;
@property (nonatomic, strong) NSString *    varMarkup;
@property (nonatomic, assign) int           phoneType;
@property (nonatomic, strong) NSString *    apiKey;

@end
