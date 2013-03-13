//
//  gc_Request.h
//  Groupcentric
//
//  Created by Tom Bachant on 8/16/12.
//  Copyright (c) 2012 Shizzlr, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "gc_JSON.h"
#import "GCGroup.h"


@protocol gc_RequestDelegate;


@interface gc_Request : NSObject {
	id<gc_RequestDelegate> delegate;
	NSString *webServiceName;
	NSDictionary *parameters;
	NSURLConnection *theConnection;
	NSMutableData *resultData;
	
	BOOL canceled;
}

@property (nonatomic, retain) id<gc_RequestDelegate> delegate;
@property (nonatomic, readonly) NSString *webServiceName;

-(id)initWithWebService:(NSString*)ws andParameters:(NSDictionary*)params;
-(void)connect;
-(void)cancel;

@end


@protocol gc_RequestDelegate

-(void)request:(gc_Request*)request didLoadSuccessfully:(BOOL)success;

-(void)request:(gc_Request*)request didFinishRegisteringWithUserID:(int)userId;


-(void)request:(gc_Request*)request didLoadArray:(NSArray *)objects;

-(void)request:(gc_Request*)request didLoadGroupDetails:(GCGroup *)group;

-(void)request:(gc_Request*)request didLoadProfileWithName:(NSString *)name andImage:(NSString *)image;

-(void)request:(gc_Request*)request didFailWithError:(NSError*)error;

@end
