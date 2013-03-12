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
//  gc_Group.h
//  Groupcentric SDK
//
//  group object


#import <Foundation/Foundation.h>

@interface gc_Group : NSObject {
    
}

//
// Basic group information
// These properties will be returned when calling either "GetGroupDetails" or "GetGroups"
//

@property (nonatomic, assign) int               groupId;
@property (nonatomic, strong) NSString *        groupName;
@property (nonatomic, strong) NSString *        image;
@property (nonatomic, strong) NSDate   *        date;
@property (nonatomic, strong) NSMutableArray *  friends; // Array of gc_Friend objects

//
// Group details properties
// These properties will be returned when calling "GetGroupDetails"
//
@property (nonatomic, strong) NSString *        groupCreator;
@property (nonatomic, strong) NSString *        friendLocationURL;
@property (nonatomic, strong) NSMutableArray *  messages; // Array of gc_Message objects
@property (nonatomic, strong) NSMutableArray *  sharedImages; // Array of strings, includes all images shared into the group
@property (nonatomic, assign) BOOL              pushEnabled;

//
// Group list properties
// These properties will be returned when calling "GetGroups"
//
@property (nonatomic, strong) NSDate *          lastUpdated;
@property (nonatomic, assign) BOOL              hasNewContent;
@property (nonatomic, assign) int               friendsCount;
@property (nonatomic, assign) int               messagesCount;
@property (nonatomic, strong) NSString *        lastMessageText;
@property (nonatomic, strong) NSString *        lastMessageName;
@property (nonatomic, strong) NSString *        lastMessageImage;
@property (nonatomic, strong) NSString *        lastMessageDate;

@end
