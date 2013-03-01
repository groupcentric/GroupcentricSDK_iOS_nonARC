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
//  NotificationTableViewCell.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

@implementation GCNotificationTableViewCell

@synthesize backgroundImageView, leftImage, titleLabel, detailLabel, dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
        [self.contentView addSubview:backgroundImageView];
        
        leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        leftImage.clipsToBounds = YES;
        leftImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:leftImage];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 230, 18)];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 28, 230, 36)];
        detailLabel.numberOfLines = 2;
        detailLabel.font = [UIFont systemFontOfSize:14];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:detailLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 66, 230, 16)];
        dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.font = [UIFont italicSystemFontOfSize:13];
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {    
    [backgroundImageView release];
    [leftImage release];
    [titleLabel release];
    [detailLabel release];
    [dateLabel release];
    
    [super dealloc];

}

@end
