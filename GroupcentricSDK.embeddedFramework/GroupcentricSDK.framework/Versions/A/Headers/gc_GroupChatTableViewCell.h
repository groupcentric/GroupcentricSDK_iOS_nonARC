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
//  GroupChatTableViewCell.h
//  Groupcentric SDK
//
//  This is the tableview cell used in the group chat table of messages defined in gc_GroupDetailsVC

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface gc_GroupChatTableViewCell : UITableViewCell {
    UIImageView *userIcon;
    UIImageView *userIconBackground;
    
    UIImageView *attachmentImage;
    UIImageView *attachmentBackground;
    UILabel *attachmentLabel;
    UILabel *attachmentDetails;
    
    UILabel *userNameLabel;
    UITextView *messageText; // text view to recognize links and phone numbers
    UILabel *detailsLabel;
}

// Set up the user image and user name for each cell
- (void)formatImageAndLabelForSelf:(BOOL)isSelf;

// Hide attachment labels and images if it is a type 0 message
- (void)hideAttachmentLabelsAndImages;

@property (nonatomic, retain) UIImageView *userIcon;
@property (nonatomic, retain) UIImageView *userIconBackground;
@property (nonatomic, retain) UIImageView *attachmentImage;
@property (nonatomic, retain) UIImageView *attachmentBackground;
@property (nonatomic, retain) UILabel *attachmentLabel;
@property (nonatomic, retain) UILabel *attachmentDetails;

@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) UITextView *messageText;
@property (nonatomic, retain) UILabel *detailsLabel;

@end
