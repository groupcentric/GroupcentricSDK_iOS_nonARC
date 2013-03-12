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
//  gc_Request.h
//  Groupcentric SDK
//
//  web service requests


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "gc_JSON.h"
#import "gc_Group.h"
#import "gc_Reachability.h"

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

-(void)request:(gc_Request*)request didLoadGroupDetails:(gc_Group *)group;

-(void)request:(gc_Request*)request didLoadProfileWithName:(NSString *)name andImage:(NSString *)image;

-(void)request:(gc_Request*)request didFailWithError:(NSError*)error;

@end
