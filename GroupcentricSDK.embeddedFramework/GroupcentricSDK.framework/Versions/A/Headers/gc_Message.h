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
//  gc_Message.h
//  Groupcentric SDK
//
//  message object used in chat


#import <Foundation/Foundation.h>
#import "gc_Object.h"

@interface gc_Message : NSObject {
    
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
@property (nonatomic, strong) gc_Object *    object;
@property (nonatomic, strong) NSString *    brand;
@property (nonatomic, strong) NSString *    brandURL;
@property (nonatomic, strong) NSString *           apikey;




@end
