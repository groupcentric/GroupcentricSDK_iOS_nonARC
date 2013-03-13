//
//  gc_Message.h
//  Groupcentric
//
//  Created by Tom Bachant on 8/20/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface gc_SharedObject : NSObject {
    
}

@property (nonatomic, assign) int           type;
@property (nonatomic, strong) NSString *    imageURL;
@property (nonatomic, strong) NSString *    varTitle;
@property (nonatomic, strong) NSString *    varSubtitle;
@property (nonatomic, strong) NSString *    varDateString;
@property (nonatomic, strong) NSString *    varDetails;
@property (nonatomic, strong) NSString *    varMarkup;
@property (nonatomic, strong) NSString *    varURL;

-(id)initWithContent:(int)type_ withTitle:(NSString *)title_ withSubtitle:(NSString *)subtitle_ withImageURL:(NSString *)imageurl_ withURL:(NSString *)url_ withDate:(NSString *)date_ withDetails:(NSString *)details_ withMarkup:(NSString *)markup_;

@end
