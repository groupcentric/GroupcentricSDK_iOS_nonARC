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
//  ObjectDetailsVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

#define SECTION_TITLE 0
#define SECTION_SUBTITLE 1
#define SECTION_DATE 2
#define SECTION_LINK 3
#define SECTION_DETAILS 4

@interface GCObjectDetailsVC ()

@end

@implementation GCObjectDetailsVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSLog(@"Invalid initalizer. Please use 'initWithObject'");
    }
    return self;
}

- (id)initWithObject:(GCSharedObject *)objct {
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        object = [objct retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //set the title, font white, dark gray shadow
    CGRect frame = CGRectMake(0,2,200,44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.shadowColor =  [UIColor darkGrayColor];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[[UIColor alloc] initWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    label.text = @"";
    self.navigationItem.titleView = label;
    [label release];
    
    webDetails = [[UIWebView alloc] initWithFrame:CGRectMake(5, 5, 310, 50)];
    webDetails.opaque = NO;
    webDetails.backgroundColor = [UIColor clearColor];
    // We don't want scrolling enabled within the web view
    if ([webDetails respondsToSelector:@selector(scrollView)]) {
        webDetails.scrollView.scrollEnabled = NO;
    }
    webDetails.delegate = self;
    // Load the URL of the object
    NSString *tmp = [object.varDetails stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    object.varDetails = tmp;
    [webDetails loadHTMLString:object.varDetails
                       baseURL:nil];
    
    // Set up background
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.tableView.frame];
	background.image = [UIImage imageNamed:@"gc_notificationsbg.png"];
	background.contentMode = UIViewContentModeCenter;
	self.tableView.backgroundView = background;
	[background release];
    
    // No separators
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //left nav btn
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"gc_blankbtn.png"] forState:UIControlStateNormal];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    backButton.titleLabel.shadowColor = [UIColor blackColor];
    backButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = but;
    [but release];
    [backButton release];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [object release];
    [webDetails release];
    
    [super dealloc];
}

#pragma mark - Actions
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewImage {
    NSArray *photos = [NSArray arrayWithObject:[gc_MWPhoto photoWithURL:[NSURL URLWithString:object.imageURL]]];
    NSArray *strings = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@", object.imageURL]];

    // Create browser
    gc_MWPhotoBrowser *browser = [[gc_MWPhotoBrowser alloc] initWithPhotos:photos andStrings:strings andName:object.varTitle];
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // Usually we'll only show cells where there's information to show
    
    if (section == SECTION_TITLE) {
        // Always show the title
        return 1;
    /*} else if (section == SECTION_SUBTITLE) { //working on moving subtitle up to under title
        if ([object.varSubtitle length]) {
            return 1;
        }*/
    } else if (section == SECTION_DATE) {
        if ([object.varDateString length]) {
            return 1;
        }
    } else if (section == SECTION_LINK) {
        if ([object.var1 length]) {
            return 1;
        }
    } else if (section == SECTION_DETAILS) {
        // Always show the details
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TitleCellIdentifier = @"TitleCell";
    static NSString *InfoCellIdentifier = @"InfoCell";
    static NSString *DetailsCellIdentifier = @"DetailCell";
    
    UITableViewCell *cell;
    
    // Configure the cell...
    
    if (indexPath.section == SECTION_TITLE) {
        cell = [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier] autorelease];
            
            // Add image to the top
            UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
            bgImage.image = [[UIImage imageNamed:@"gc_photobg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            [cell.contentView addSubview:bgImage];
            
            UIImageView *objectImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 80, 80)];
            [objectImage setImageWithURL:[NSURL URLWithString:object.imageURL] placeholderImage:[UIImage imageNamed:@"gc_blankgroup.png"]];
            [cell.contentView addSubview:objectImage];
            
            // Put a button over the image to open the larger version
            UIButton *imgButton = [[UIButton alloc] initWithFrame:objectImage.frame];
            [imgButton addTarget:self action:@selector(viewImage) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:imgButton];
            
            // Add the title
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bgImage.frame) + 10, 10, 200, CGRectGetHeight(objectImage.frame)/2)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.numberOfLines = 2;
            titleLabel.font = [UIFont boldSystemFontOfSize:18];
            titleLabel.shadowColor = [UIColor whiteColor];
            titleLabel.shadowOffset = CGSizeMake(0, 1);
            titleLabel.text = object.varTitle;
            
            [cell.contentView addSubview:titleLabel];
            
            // Add the title
            UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bgImage.frame) + 10, CGRectGetHeight(objectImage.frame)/2+10, 200, CGRectGetHeight(objectImage.frame)/2-10)];
            subtitleLabel.backgroundColor = [UIColor clearColor];
            subtitleLabel.numberOfLines = 2;
            subtitleLabel.font = [UIFont systemFontOfSize:16];
            subtitleLabel.shadowColor = [UIColor whiteColor];
            subtitleLabel.shadowOffset = CGSizeMake(0, 1);
            subtitleLabel.text = object.varSubtitle;
            
            [cell.contentView addSubview:subtitleLabel];
            
            [bgImage release];
            [objectImage release];
            [imgButton release];
            [titleLabel release];
            [subtitleLabel release];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else if (indexPath.section == SECTION_DETAILS) {
        cell = [tableView dequeueReusableCellWithIdentifier:DetailsCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DetailsCellIdentifier] autorelease];
            
            [cell addSubview:webDetails];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:InfoCellIdentifier] autorelease];
            
        }
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        
        switch (indexPath.section) {
            /*case SECTION_SUBTITLE: {
                cell.textLabel.text = @"Details";
                cell.detailTextLabel.text = object.varSubtitle;
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                break;
            }*/
            case SECTION_DATE: {
                cell.textLabel.text = @"Date";
                cell.detailTextLabel.text = object.varDateString;
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                break;
            }
            case SECTION_LINK: {
                cell.textLabel.text = @"Website";
                cell.detailTextLabel.text = object.var1;
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
                break;
            }                
            default:
                break;
        }
        
    }
    
    NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"gc_cell-back" ofType:@"png"];
    UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
    cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_DETAILS) {
        CGSize fittingSize = webDetails.frame.size;
        return fittingSize.height + 10;
    }
    
    if (indexPath.section == SECTION_TITLE) {
        return 110.0;
    }
    
    return 44.0;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == SECTION_LINK) {
        GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:object.var1];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Web View Delegation

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGSize fittingSize = [webDetails sizeThatFits:CGSizeZero];
    webDetails.frame = CGRectMake(5, 5, 310, fittingSize.height);
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SECTION_DETAILS]]
                          withRowAnimation:UITableViewRowAnimationFade];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:[[request URL] absoluteString]];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        return NO;
    }
    return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Web error");
}

@end
