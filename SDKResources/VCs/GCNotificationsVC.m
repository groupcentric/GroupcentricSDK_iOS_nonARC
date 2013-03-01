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
//  NotificationsVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>


@implementation GCNotificationsVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Initialize empty array
        notifications = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithNotifications:(NSMutableArray *)notifs {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Initialize array with notifications from previous VC
        notifications = [notifs retain];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the navigation bar to a custom image
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"gc_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    // Set up background
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.tableView.frame];
	background.image = [UIImage imageNamed:@"gc_notificationsbg.png"];
	background.contentMode = UIViewContentModeCenter;
	self.tableView.backgroundView = background;
	[background release];
    
    // Set up left nav button
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"gc_blackbtn.png"] forState:UIControlStateNormal];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    closeButton.titleLabel.shadowColor = [UIColor blackColor];
    closeButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBut = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = leftBut;
    [leftBut release];
    [closeButton release];
    
    // Set up the pull to refresh
    if (_refreshHeaderView == nil) {
        gc_EGORefreshTableHeaderView *view = [[gc_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
    }
    // Set the date when last updated
	[_refreshHeaderView refreshLastUpdatedDate];
    
    self.title = @"Group Notifications";
    
    // Initialize the arrays
    notificationImages = [[NSMutableArray alloc] init];
    
    // Set up the date formatter
    timeFormatter = [[gc_TTTTimeIntervalFormatter alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _refreshHeaderView = nil;
}

- (void)dealloc {    
    [notifications release];
    [notificationImages release];
    [timeFormatter release];
    _refreshHeaderView = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Every time the view appears, refresh the notifications
    [self getNotifications];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of notifications
    return [notifications count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    
    GCNotificationTableViewCell *cell = (GCNotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
	if (cell == nil) {
        cell = [[[GCNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    GCNotification *notifEntry = [notifications objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = notifEntry.title;
    cell.detailLabel.text = notifEntry.subtitle;
    cell.dateLabel.text = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:notifEntry.date];
    
    if (notifEntry.unread) {
        // Has an unread message, so update the background image
        cell.backgroundImageView.image = [UIImage imageNamed:@"gc_notificationswhiterow.png"];
    } else {
        cell.backgroundImageView.image = [UIImage imageNamed:@"gc_notificationsgrayrow.png"];
    }
    
    // Handle image loading
    // First off, just set the default blank image before the loading process begins
    cell.leftImage.image = [UIImage imageNamed:@"gc_blankgroup.png"];
    // If the index path is less than image array count, then that means the cell has already been viewed and the image has already been prompted to load
    // Just set the delegate and the image will show
    if (indexPath.row < [notificationImages count]) {
        cell.leftImage.highlighted = NO;
        [[notificationImages objectAtIndex:indexPath.row] setDelegate:cell.leftImage];
    } else {
        // If the index path is greater than the array count, then the cell has not appeared yet, and the image has not been prompted to load
        // Start loading the image with a LoadImageRequest, and it will appear automatically
        // Add it to the image array to be sure it doesn't load again
        
        // Create the class LoadImageRequest which will start asyncronously loading images
        gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:notifEntry.imageURL];
        // Add it to image array
        [notificationImages addObject:imgRequest];
        // Set the cell delegate for the image
        [imgRequest setDelegate:cell.leftImage];
        [imgRequest release];
    }

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCNotification *chosenNotification = [notifications objectAtIndex:indexPath.row];
    
    if (chosenNotification.action == 0) {
        // Notification is for a group, so open group details
        // Create a basic version of the group so there's something to view in details
        // Get group id and name from the notification
        // The notification title is the group name, and the action variable is the group id
        GCGroup *groupToOpen = [[GCGroup alloc] init];
        groupToOpen.groupName = chosenNotification.title;
        groupToOpen.groupId = [chosenNotification.actionVariable intValue];
        
        GCGroupDetailsVC *controller = [[GCGroupDetailsVC alloc] initWithGroup:groupToOpen andShouldDismissModalViewController:NO andFromNotifications:YES];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        [groupToOpen release];
    } else if (chosenNotification.action == 1) {
        // Notification should link to a website
        // Open the web browser with the appropriate URL
        GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:chosenNotification.actionVariable];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(gc_EGORefreshTableHeaderView*)view{
    
	[self getNotifications];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(gc_EGORefreshTableHeaderView*)view{
    
	return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(gc_EGORefreshTableHeaderView*)view{
    
	return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - Actions

- (void)getNotifications {
    
    if (_reloading) {
        return; // Don't bother reloading if it's already in progress!
    }
    
    
    _reloading = YES;
    
    [[Groupcentric sharedInstance] getNotifications:^(NSArray *notifs, NSError *error) {
        
        _reloading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        
        if (!error) {
            // Success
            
            // We should already have notifications stored, so only both reloading everything if something has changed
            if (![notifications isEqualToArray:notifs]) {
                [notifications removeAllObjects];
                [notificationImages removeAllObjects];
                
                [notifications addObjectsFromArray:notifs];
                
                [self.tableView reloadData];
            }
            
        } else {
            // Log the error
            NSLog(@"Error loading notifications: %@", error);
        }
        
    }];
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
