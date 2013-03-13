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
//  GroupListTableViewCell.h
//  Groupcentric SDK
//
//  This tablecell is a group in the groups table in the main view controller GC_viewcontroller


#import <UIKit/UIKit.h>

@interface GCGroupListTableViewCell : UITableViewCell {
    UIImageView *backgroundImageView;
    
    UIImageView *groupImage1;
    UIImageView *groupImage2;
    UIImageView *groupImage3;
    UIImageView *groupImage4;
    
    UILabel *groupTitle;
    UILabel *lastMessage;
    UILabel *dateLabel;
    UIImageView *friendCountImage;
    UILabel *friendCountLabel;
}

- (void)formatImagesForFriends:(NSInteger)frndCount;

@property (nonatomic, retain) UIImageView *backgroundImageView;

@property (nonatomic, retain) UIImageView *groupImage1;
@property (nonatomic, retain) UIImageView *groupImage2;
@property (nonatomic, retain) UIImageView *groupImage3;
@property (nonatomic, retain) UIImageView *groupImage4;

@property (nonatomic, retain) UILabel *groupTitle;
@property (nonatomic, retain) UILabel *lastMessage;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UIImageView *friendCountImage;
@property (nonatomic, retain) UILabel *friendCountLabel;

@end
