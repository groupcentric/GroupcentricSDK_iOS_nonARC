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
//  GroupcentricSDK.h
//  Groupcentric SDK
//
//  Essentially like the app delegate of this library


#import <Foundation/Foundation.h>
#import <GroupcentricLib/Groupcentric.h>
#import "GCViewController.h"
#import "GCShareSelector.h"

@class GCViewController;

@interface GroupcentricSDK : NSObject

@property (strong, nonatomic) GCViewController *gc_VC;
@property (strong, nonatomic) GCShareSelector *gc_Share;

//for when using UrbanAirship 
+ (void)initFrameworkWithAPIKey:(NSString *)apiKey andUrbanAirship:(NSDictionary *)launchOptions;

//for when not using UA
+ (void)initFrameworkWithAPIKey:(NSString *)apiKey;


/*
 *
 * Coming soon
 * Use APNS for push notificaitons
 
+ (void)initFrameworkWithAPIKey:(NSString *)apiKey andUseAPNS:(BOOL)use;
 
*/

@end
