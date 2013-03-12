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


@protocol GCRequestDelegate;


@interface GCRequest : NSObject {
	id<GCRequestDelegate> delegate;
	NSString *webServiceName;
	NSDictionary *parameters;
	NSURLConnection *theConnection;
	NSMutableData *resultData;
	
	BOOL canceled;
}

@property (nonatomic, retain) id<GCRequestDelegate> delegate;
@property (nonatomic, readonly) NSString *webServiceName;

-(id)initWithWebService:(NSString*)ws andParameters:(NSDictionary*)params;
-(void)connect;
-(void)cancel;

@end


@protocol GCRequestDelegate

-(void)request:(GCRequest*)request didLoadSuccessfully:(BOOL)success;

-(void)request:(GCRequest*)request didFinishRegisteringWithUserID:(int)userId;

-(void)request:(GCRequest*)request didLoadArray:(NSArray *)objects;

-(void)request:(GCRequest*)request didLoadGroups:(NSArray *)groups;

-(void)request:(GCRequest*)request didLoadNotifications:(NSArray *)notifications;

-(void)request:(GCRequest*)request didLoadGroupDetails:(GCGroup *)group;

-(void)request:(GCRequest*)request didLoadProfileWithName:(NSString *)name andImage:(NSString *)image;

-(void)request:(GCRequest*)request didFailWithError:(NSError*)error;

@end
