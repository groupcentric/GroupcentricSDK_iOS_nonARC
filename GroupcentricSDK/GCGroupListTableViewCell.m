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
//  GroupListTableViewCell.m
//  Groupcentric SDK
//


#import "GCGroupListTableViewCell.h"

@implementation GCGroupListTableViewCell


#define GROUPLIST_IMAGE_TAG_OFFSET 100


@synthesize backgroundImageView, groupImage1, groupImage2, groupImage3, groupImage4, groupTitle, dateLabel, lastMessage, friendCountImage, friendCountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 80)];
        [self.contentView addSubview:backgroundImageView];
        
        groupImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 64, 64)];
        groupImage1.contentMode = UIViewContentModeScaleAspectFill;
        groupImage1.clipsToBounds = YES;
        groupImage1.tag = GROUPLIST_IMAGE_TAG_OFFSET;
        [self.contentView addSubview:groupImage1];
        
        groupImage2 = [[UIImageView alloc] initWithFrame:CGRectZero];
        groupImage2.contentMode = UIViewContentModeScaleAspectFill;
        groupImage2.clipsToBounds = YES;
        groupImage2.tag = GROUPLIST_IMAGE_TAG_OFFSET + 1;
        [self.contentView addSubview:groupImage2];
        
        groupImage3 = [[UIImageView alloc] initWithFrame:CGRectZero];
        groupImage3.contentMode = UIViewContentModeScaleAspectFill;
        groupImage3.clipsToBounds = YES;
        groupImage3.tag = GROUPLIST_IMAGE_TAG_OFFSET + 2;
        [self.contentView addSubview:groupImage3];
        
        groupImage4 = [[UIImageView alloc] initWithFrame:CGRectZero];
        groupImage4.contentMode = UIViewContentModeScaleAspectFill;
        groupImage4.clipsToBounds = YES;
        groupImage4.tag = GROUPLIST_IMAGE_TAG_OFFSET + 3;
        [self.contentView addSubview:groupImage4];
        
        groupTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 11, 143, 20)];
        groupTitle.font = [UIFont boldSystemFontOfSize:16];
        groupTitle.backgroundColor = [UIColor clearColor];
        groupTitle.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:groupTitle];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(223, 11, 85, 20)];
        dateLabel.textAlignment = UITextAlignmentRight;
        dateLabel.textColor = [UIColor colorWithRed:44.0f/255.0f green:147.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
        //dateLabel.font = [UIFont italicSystemFontOfSize:13];
        dateLabel.font = [UIFont systemFontOfSize:13];
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
        
        lastMessage = [[UILabel alloc] initWithFrame:CGRectMake(80, 31, 210, 37)];
        lastMessage.numberOfLines = 2;
        lastMessage.font = [UIFont systemFontOfSize:14];
        lastMessage.backgroundColor = [UIColor clearColor];
        lastMessage.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:lastMessage];
        
        //if wanted to include the number of friends in this group in the group list...
        /*friendCountImage = [[UIImageView alloc] initWithFrame:CGRectMake(28, 71, 15, 12)];
         friendCountImage.image = [UIImage imageNamed:@"gc_smallfriendicon.png"];
         [self.contentView addSubview:friendCountImage];
         
         friendCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, 70, 24, 14)];
         friendCountLabel.font = [UIFont italicSystemFontOfSize:13];
         friendCountLabel.backgroundColor = [UIColor clearColor];
         friendCountLabel.textColor = [UIColor darkGrayColor];
         [self.contentView addSubview:friendCountLabel];*/
    }
    return self;
}

- (void)formatImagesForFriends:(NSInteger)frndCount {
    // If there is no default group image, format the images to show friend images
    // The square space occupied by image(s) has a frame of [18, 11, 52 52]
    
    if (frndCount == 0) {
        groupImage1.image = [UIImage imageNamed:@"gc_blankgroup.png"];
    } else {
        groupImage1.image = [UIImage imageNamed:@"gc_blankuser.png"];
        groupImage2.image = [UIImage imageNamed:@"gc_blankuser.png"];
        groupImage3.image = [UIImage imageNamed:@"gc_blankuser.png"];
        groupImage4.image = [UIImage imageNamed:@"gc_blankuser.png"];
    }
    
    if (frndCount == 0 || frndCount == 1) {
        groupImage1.frame = CGRectMake(8,8,64,64);
        
        groupImage2.frame = CGRectZero;
        groupImage2.image = nil;
        
        groupImage3.frame = CGRectZero;
        groupImage3.image = nil;
        
        groupImage4.frame = CGRectZero;
        groupImage4.image = nil;
        
        
    } else if (frndCount == 2) {
        groupImage1.frame = CGRectMake(8,8, 64, 32);
        
        groupImage2.frame = CGRectMake(8,8 + 32, 64, 32);
        
        groupImage3.frame = CGRectZero;
        groupImage3.image = nil;
        
        groupImage4.frame = CGRectZero;
        groupImage4.image = nil;
        
    } else if (frndCount == 3) {
        groupImage1.frame = CGRectMake(8,8, 64, 32);
        
        groupImage2.frame = CGRectMake(8,8+ 32, 32, 32);
        
        groupImage3.frame = CGRectMake(8 + 32, 8 + 32, 32, 32);
        
        groupImage4.frame = CGRectZero;
        groupImage4.image = nil;
        
    } else {
        // 4 more or more friends
        groupImage1.frame = CGRectMake(8,8, 32, 32);
        
        groupImage2.frame = CGRectMake(8 + 32, 8, 32,32);
        
        groupImage3.frame = CGRectMake(8,8 + 32,32,32);
        
        groupImage4.frame = CGRectMake(8 + 32, 8 + 32,32,32);
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:YES animated:animated];
    
    // Configure the view for the selected state
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        lastMessage.frame = CGRectMake(80,31, 170, 37);
    } else {
        lastMessage.frame = CGRectMake(80,31, 210, 37);
    }
}

- (void)dealloc {
    [backgroundImageView release];
    [groupTitle release];
    [dateLabel release];
    [lastMessage release];
    [friendCountImage release];
    [friendCountLabel release];
    
    [super dealloc];
}

@end
