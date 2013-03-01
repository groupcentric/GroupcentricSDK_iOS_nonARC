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
//  GroupFriendTableViewCell.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

@implementation GCGroupFriendTableViewCell

@synthesize friendImage, friendName, locationImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // Add the friend's profile image
        friendImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 42, 42)];
        friendImage.clipsToBounds = YES;
        friendImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:friendImage];
        
        // Set up the background image
        // This is going on top of the friend image to create a fake rounded corner effect without taking up as much memory
        UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
        bg.image = [UIImage imageNamed:@"gc_friendrowbg_filled.png"];
        [self.contentView addSubview:bg];
        [bg release];
        
        // Add the label for friend's name
        friendName = [[UILabel alloc] initWithFrame:CGRectMake(53, 11, 257, 20)];
        friendName.textColor = [UIColor darkGrayColor];
        friendName.backgroundColor = [UIColor clearColor];
        friendName.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:friendName];
        
        // Location image, indicates if the user has shared their location
        locationImage = [[UIImageView alloc] initWithFrame:CGRectMake(300, 14, 10, 17)];
        [self.contentView addSubview:locationImage];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [friendImage release];
    [friendName release];
    
    [super dealloc];
}

@end
