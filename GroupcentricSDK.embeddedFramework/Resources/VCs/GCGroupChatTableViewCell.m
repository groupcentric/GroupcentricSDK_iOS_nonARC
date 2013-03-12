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
//  GroupChatTableViewCell.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>


@implementation GCGroupChatTableViewCell

@synthesize userIcon, userIconBackground, attachmentImage, attachmentBackground, attachmentLabel, attachmentDetails, messageText, detailsLabel, userNameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        attachmentBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
        attachmentBackground.clipsToBounds = YES;
        [self.contentView addSubview:attachmentBackground];
        
        userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 40, 40)];
        userIcon.contentMode = UIViewContentModeScaleAspectFill;
        userIcon.clipsToBounds = YES;
        [self.contentView addSubview:userIcon];
        
        userIconBackground = [[UIImageView alloc] initWithFrame:userIcon.frame];
        userIconBackground.image = [UIImage imageNamed:@"gc_cell-photo-back.png"];
        [self.contentView addSubview:userIconBackground];
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 6, 244, 20)];
        userNameLabel.font = [UIFont boldSystemFontOfSize:16];
        userNameLabel.textColor = [UIColor grayColor];
        userNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:userNameLabel];
        
        messageText = [[UITextView alloc] init];
        messageText.font = [UIFont systemFontOfSize:16];
        messageText.textColor = [UIColor blackColor];
        messageText.backgroundColor = [UIColor clearColor];
        messageText.editable = NO;
        messageText.scrollEnabled = NO;
        messageText.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink | UIDataDetectorTypeAddress;
        messageText.contentInset = UIEdgeInsetsMake(-4,-8,0,0); // get rid of unnecessary padding
        [self.contentView addSubview:messageText];
        
        attachmentImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        attachmentImage.contentMode = UIViewContentModeScaleAspectFill;
        attachmentImage.clipsToBounds = YES;
        [self.contentView addSubview:attachmentImage];
        
        attachmentLabel = [[UILabel alloc] init];
        attachmentLabel.font = [UIFont boldSystemFontOfSize:14];
        attachmentLabel.textColor = [UIColor darkGrayColor];
        attachmentLabel.backgroundColor = [UIColor clearColor];
        attachmentLabel.numberOfLines = 2;
        [self.contentView addSubview:attachmentLabel];
        
        attachmentDetails = [[UILabel alloc] init];
        attachmentDetails.font = [UIFont systemFontOfSize:14];
        attachmentDetails.textColor = [UIColor grayColor];
        attachmentDetails.numberOfLines = 2;
        attachmentDetails.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:attachmentDetails];
        
        detailsLabel = [[UILabel alloc] init];
        detailsLabel.font = [UIFont systemFontOfSize:12];
        detailsLabel.textColor = [UIColor grayColor];
        detailsLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:detailsLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)formatImageAndLabelForSelf:(BOOL)isSelf {
    
    if (isSelf) {
        userNameLabel.textColor = [UIColor colorWithRed:44.0f/255.0f green:147.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    } else {
        userNameLabel.textColor = [UIColor grayColor];
    }

}

- (void)hideAttachmentLabelsAndImages {
    attachmentDetails.text = @"";
    attachmentLabel.text = @"";
    attachmentBackground.image = nil;
    attachmentBackground.frame = CGRectZero;
    attachmentImage.image = nil;
    attachmentImage.frame = CGRectZero;
}

- (void)dealloc {
    
    [userIcon release];
    [userIconBackground release];
    
    [attachmentImage release];
    [attachmentLabel release];
    [attachmentDetails release];
    [attachmentBackground release];
    
    [messageText release];
    [detailsLabel release];
    [userNameLabel release];
    
    [super dealloc];
    
}

@end
