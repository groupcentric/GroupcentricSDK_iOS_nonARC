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
//  ViewController.m
//  Groupcentric SDK
//


#import "GCViewController.h"

#define GROUPLIST_CELL_IMAGE_TAG_OFFSET 100

@implementation GCViewController

@synthesize delegate; //the delegate for the parent to update the notification count after getnotifications is called

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   
	// Do any additional setup after loading the view, typically from a nib.
        
    self.title=@"My Groups";
    
    // Add the notification button to nav bar
    UIButton *notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 31)];
    [notificationButton setBackgroundImage:[UIImage imageNamed:@"gc_topsmallbtn.png"] forState:UIControlStateNormal];
    [notificationButton setTitle:@"0" forState:UIControlStateNormal];
    notificationButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    notificationButton.titleLabel.shadowColor = [UIColor blackColor];
    notificationButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [notificationButton addTarget:self action:@selector(openNotifications) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithCustomView:notificationButton];
    self.navigationItem.rightBarButtonItem = rightBut;
    [rightBut release];
    [notificationButton release];
    
    _signedIn = true;
    
    // Set up the left navigation item
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
    
    
    // Initialize groups and images array
    myGroups = [[NSMutableArray alloc] init];
    myGroupImages = [[NSMutableArray alloc] init];
    notifications = [[NSMutableArray alloc] init];
    
    // Initialize the date formatter
    dateFormatter = [[gc_TTTTimeIntervalFormatter alloc] init];
    
    // Set up the pull to refresh
    if (_refreshHeaderView == nil) {
        gc_EGORefreshTableHeaderView *view = [[gc_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - theTableView.bounds.size.height, self.view.frame.size.width, theTableView.bounds.size.height)];
		view.delegate = self;
		[theTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
    }
    // Set the date when last updated
	[_refreshHeaderView refreshLastUpdatedDate];
    
    // Set up table view parameters
    theTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTableView.backgroundColor = [UIColor clearColor];
    theTableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0); // add insets for nicer spacing, and for dealing with overlapping bottom button
    
    
    
    // Check to see if there is a logged in user. If not, show the login/signup screen
    // Lack of user id indicates no user
    // ID less than 1 indicates an error in the signup process    
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    
    int userId = groupcentric.userId;
        
    if (!userId || userId <= 0) {
        _signedIn = false;
        //[self.view bringSubviewToFront:bgView];
        [self.view bringSubviewToFront:getStartedView];
        [self.view sendSubviewToBack:theTableView];
    }
    else{
        [self.view bringSubviewToFront:bgView];
        [self.view bringSubviewToFront:theTableView];
        [self.view sendSubviewToBack:getStartedView];
        NSLog(@"calling GetGroups from ViewDidLoad 122");
        initialLoading = YES;
        startingNewGroup = NO;
        [self getGroups];
        NSLog(@"addobserver nsnotif for push 11");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups) name:@"refresh" object:nil];
    
     [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _refreshHeaderView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
 
    [super viewWillAppear:animated];
   
    // Check to see if there is a logged in user. If not, show the signin vc
    // Lack of user id indicates no user
    // ID less than 1 indicates an error in the signup process
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    
    int userId = groupcentric.userId;
    
    if (!userId || userId <= 0) {
        _signedIn = false;
        // Present the view controller for signing in
        [self.view sendSubviewToBack:bgView];
        [self.view bringSubviewToFront:getStartedView];
        [self.view sendSubviewToBack:theTableView];
        // Hide Notifications button in nav controller
        self.navigationItem.rightBarButtonItem = nil;
       
    }
    else {
        if(!_signedIn && userId > 0)  //wasnt signed in but now userid > 0 and coming back from some modal so must have just signed in
        {
            _signedIn = true;
            initialLoading = NO;
            
            // Add the notification button to nav bar
            UIButton *notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 31)];
            [notificationButton setBackgroundImage:[UIImage imageNamed:@"gc_topsmallbtn.png"] forState:UIControlStateNormal];
            [notificationButton setTitle:@"0" forState:UIControlStateNormal];
            notificationButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            notificationButton.titleLabel.shadowColor = [UIColor blackColor];
            notificationButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
            [notificationButton addTarget:self action:@selector(openNotifications) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithCustomView:notificationButton];
            self.navigationItem.rightBarButtonItem = rightBut;
            [rightBut release];
            [notificationButton release];
            
            
            [self getGroups];
           // NSLog(@"addobserver nsnotif for push 22");
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups) name:@"refresh" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups) name:UIApplicationDidBecomeActiveNotification object:nil];
            
            [theTableView setContentOffset:CGPointZero animated:YES];
           
        }
        else{
            if(initialLoading)  //so first time loading groups acts normal, loads them from viewdidload
            {
                initialLoading = NO;
            }
            else {  //only time here and need to take action is if the user started a new group then need to refresh
                 if(startingNewGroup || unreadCount > 0)
                 {
                     startingNewGroup = NO;
                     [self getGroups];
                 }
            }
        }
       
        //the bgView is just a nice grey background and theTableView is the groups list; it has a transparent background hence we use bgView too
        [self.view bringSubviewToFront:bgView];
        [self.view bringSubviewToFront:theTableView];
        [self.view sendSubviewToBack:getStartedView];
        
        
        
    }
    
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //doesnt help the fact that this gets called twice when coming back from details...[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(viewDidAppear) object:nil];
   /* if (shouldNotReload) {
        shouldNotReload = NO;
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotificationsOnPushNotif) name:@"refresh" object:nil];
        shouldNotReload = YES;
    }*/
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refresh" object:nil];
    
	[super viewDidDisappear:animated];
}

- (void)dealloc {
    [myGroups release];
    [myGroupImages release];
    [dateFormatter release];
    [notifications release];
    _refreshHeaderView = nil;
    
    [super dealloc];    
}

#pragma mark - Actions

-(void)viewPrivacyTos:(id)sender {
    GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:@"http://groupcentric.com/m/privacytos.html"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(UIViewController *)parentVC:(UIResponder*)view {
    id nextResponder = nil;
    id v = view;
    while (nextResponder == [v nextResponder]) {
        if([nextResponder isKindOfClass:[UIViewController class]])
            return nextResponder;
        v = nextResponder;
    }
    return nil;
}

- (void)getGroups {
   
    if (_reloading) {
        return; // Don't reload if it's already reloading
    }
    
    _reloading = YES;
    
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    
    if (groupcentric.userId <= 0) {
        // Invalid user id
        _reloading = NO;
        return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [groupcentric getGroups:^(NSArray *groups, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        _reloading = NO;
        
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:theTableView];
        
        if (!error) {
            
            // Check to be sure the notifications are actually of type GCGroup
            // Will return and break function if true
            if ([groups count]) {
                if (![[groups lastObject] isKindOfClass:[GCGroup class]]) {
                    // Error: objects returned were not groups
                    
                    if ([[groups lastObject] isKindOfClass:[GCNotification class]]) {
                        // Loaded notifications by mistake
                        [notifications removeAllObjects];
                        [notifications addObjectsFromArray:groups];
                        
                        [self.delegate parentUpdateGroupNotificationsCount];
                        
                        // Set the right bar button with the proper number of unread notifs
                        [self checkUnreadNotifications];
                    }
                    
                    return;
                }
            }
            
            
            // Groups loaded successfully
            
            [myGroups removeAllObjects];
            [myGroups addObjectsFromArray:groups];
            
            [myGroupImages removeAllObjects];
            
            // Now update table view with a fancy animation
            [theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self getNotifications];
            
        } else {
            // Log the error
            NSLog(@"Error getting groups: %@ %@", error, [error userInfo]);
        }
        
        
        
        
    }];
    
        
}

- (void)getNotifications {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[Groupcentric sharedInstance] getNotifications:^(NSArray *notifs, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            
            // Check to be sure the notifications are actually of type GCNotification
            // If not, it will return and break function
            if ([notifs count]) {
                if (![[notifs lastObject] isKindOfClass:[GCNotification class]]) {
                    // Error: objects returned were not notifications
                    
                    if ([[notifs lastObject] isKindOfClass:[GCGroup class]]) {
                        // Loaded groups by mistake
                        [myGroups removeAllObjects];
                        [myGroups addObjectsFromArray:notifs];
                        
                        [myGroupImages removeAllObjects];
                        
                        // Now update table view with a fancy animation
                        [theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
                    return;
                }
            }
            
            // Successfully loaded notifications
            
            [notifications removeAllObjects];
            [notifications addObjectsFromArray:notifs];
            
            [self.delegate parentUpdateGroupNotificationsCount];
            
            // Set the right bar button with the proper number of unread notifs
            [self checkUnreadNotifications];
            
        } else {
            NSLog(@"Error getting notifications: %@ %@", error, [error userInfo]);
        }
        
        
    }];
}

//groupdetailsdelegate method
-(void) tellGroupsVCToRefresh {
    unreadCount = 1; //this will cause the Groups to refresh in viewwillappear
}

//when a push notif comes in check notifications to see if anything new/updated. if so then refresh groups
- (void)getNotificationsOnPushNotif {
    /*[[Groupcentric sharedInstance] getNotifications:^(NSArray *notifs, NSError *error) {
        
        if (!error) {
            
            [notifications removeAllObjects];
            [notifications addObjectsFromArray:notifs];
            
            [self.delegate parentUpdateGroupNotificationsCount];
            
            // Set the right bar button with the proper number of unread notifs
            [self checkUnreadNotifications];
            
            // Go through each notification to see if there is an unread message
            unreadCount = 0;
            for (gc_Notification *entry in notifications) {
                if (entry.unread && entry.action == 0) {  //action 0 is groups
                    unreadCount++;
                }
            }
          //  if(unreadCount > 0) {
                [self getGroups];
          //  }
            
        } else {
            NSLog(@"Error getting notifications: %@ %@", error, [error userInfo]);
        }
        
        
    }];*/
    [self getGroups];
}

-(NSMutableArray *)getNotificationsFromParent {
    return notifications;
}

-(IBAction)getStarted:(id)sender {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set up controller
    GCSignupOrLoginVC *controller = [[GCSignupOrLoginVC alloc] initInSignupMode:YES];
    
    // Set up navigation
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
    
    // Show view
    [self presentModalViewController:navCntrl animated:YES];
    
    [controller release];
    [navCntrl release];
}

- (IBAction)newGroup:(id)sender {
    // Present the view controller for creating new groups
    startingNewGroup = YES;
    // Set up controller
    GCNewGroupVC *controller = [[GCNewGroupVC alloc] init];
    
    // Set up navigation
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
    
    // Show view
    [self presentModalViewController:navCntrl animated:YES];
    
    [controller release];
    [navCntrl release];
}

- (void)newGroupFromStartButtonInGroupListFooter {
    // Present the view controller for creating new groups
    
    // Set up controller
    GCNewGroupVC *controller = [[GCNewGroupVC alloc] init];
    
    // Set up navigation
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
    
    // Show view
    [self presentModalViewController:navCntrl animated:YES];
    
    [controller release];
    [navCntrl release];
}

- (IBAction)chatAction:(id)sender {
    // Show groups
    
        
        // Change content insets
        theTableView.contentInset = UIEdgeInsetsMake(5, 0, 10, 0); // add insets for nicer spacing, and for dealing with overlapping bottom button

        // Reload the table with an animation
        [theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    
}



-(void) viewProfileFromProfileLinkInGroupListFooter:(id)sender {
    // Present the view controller for notifications
    
    // Set up controller
    GCProfileVC *controller = [[GCProfileVC alloc] initWithNibName:@"GCProfileVC" bundle:nil];
    
    // Set up navigation
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
    
    // Show view
    [self presentModalViewController:navCntrl animated:YES];
    
    [controller release];
    [navCntrl release];
}

- (void)openNotifications {
    // Present the view controller for notifications
    
    // Set up controller
    GCNotificationsVC *controller = [[GCNotificationsVC alloc] initWithNotifications:notifications];
    
    // Set up navigation
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
    
    // Show view
    [self presentModalViewController:navCntrl animated:YES];
    
    [controller release];
    [navCntrl release];
}

- (void)checkUnreadNotifications {
    // Start counting the number of unread notifications
    unreadCount = 0;
    
    // Go through each notification to see if there is an unread message
    for (GCNotification *entry in notifications) {
        if (entry.unread && entry.action == 0) {  //action 0 is groups
            unreadCount++;
        }
    }
    
    // If there is an unread message, alter the right bar button to show the user
    UIButton *notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 31)];
    
    if (unreadCount > 0) {
        [notificationButton setBackgroundImage:[UIImage imageNamed:@"gc_topsmallbtnblue.png"] forState:UIControlStateNormal];
    } else {
        [notificationButton setBackgroundImage:[UIImage imageNamed:@"gc_topsmallbtn.png"] forState:UIControlStateNormal];
    }
    
    [notificationButton setTitle:[NSString stringWithFormat:@"%i", unreadCount] forState:UIControlStateNormal];
    [notificationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    notificationButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    notificationButton.titleLabel.shadowColor = [UIColor blackColor];
    notificationButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [notificationButton addTarget:self action:@selector(openNotifications) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithCustomView:notificationButton];
    self.navigationItem.rightBarButtonItem = rightBut;
    [rightBut release];
    [notificationButton release];
}



#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
            case 0:
                return 80.0; //group
            case 1:
                return 200.0; //start group btn and profile link
        }
    
    // default
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
            case 0:
                return [myGroups count]; 
            case 1:
                return 1;  //start group btn and profile link
        }
    
    //default
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cell id for groups
	static NSString *cellID = @"cellID";
    // Cell id for startbtn and profile link below groups
    static NSString *cellIDFooter = @"cellIDFooter";
    // Cell id for no groups
    static NSString *cellIDNogroups = @"cellIDNogroups";
    
    //the group list in section 0, start button and profile link in section 1
    if(indexPath.section == 0) {
        // This should be the cells for the group list
        
        GCGroupListTableViewCell *groupCell = (GCGroupListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (groupCell == nil) {
            groupCell = [[[GCGroupListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
            
            groupCell.accessoryType = UITableViewCellAccessoryNone;
            groupCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // Get the individual group entry
        GCGroup *entry = (GCGroup *)[myGroups objectAtIndex:indexPath.row];

        groupCell.groupTitle.text = entry.groupName;
        
        if (entry.date) {
            groupCell.dateLabel.text = [dateFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:entry.date];
        } else {
            groupCell.dateLabel.text = @"";
        }
        
        groupCell.friendCountLabel.text = [NSString stringWithFormat:@"%i", entry.friendsCount];
        
        if ([entry.lastMessageText length]) {
            groupCell.lastMessage.text = [NSString stringWithFormat:@"%@: %@", entry.lastMessageName, entry.lastMessageText];
        } else {
            groupCell.lastMessage.text = @"";
        }
        
        // Handle image loading
        
        // First, let's set the image frames
        // If there's no group image, we're going to format the image so that it will fit up to 4 friend images as the icon image
        if (entry.image && [entry.image length]) {
            // Group has a defined group image
            // Format the cell so that it doesn't show multiple friend images
            
            [groupCell formatImagesForFriends:0];
        } else {
            // Group does not have a defined image
            // Use the group friends images as the image
            // Fit up to 4 friends in the square
            
            // Format the cell to fit multiple friend images if necessary
            [groupCell formatImagesForFriends:[entry.friends count]];
        }
        
        // Now we are going to set the images
        // When a cell is viewed, the image is prompted to load, and added to the array
        // If the index path is less than image array count, then that means the cell has already been viewed and the image has already been prompted to load
        if (indexPath.row < [myGroupImages count]) {
            // Cell has been viewed, just set the delegate for the image loading
            // Get the array of LoadImageRequest objects to set each image in the cell appropriately
            
            NSArray *arrayOfImageRequests = [myGroupImages objectAtIndex:indexPath.row];
            
            if ([arrayOfImageRequests count]) {
                for (int i = 0; i < [arrayOfImageRequests count]; i++) {
                    
                    UIImageView *imgToSet = (UIImageView *)[groupCell.contentView viewWithTag:(i + GROUPLIST_CELL_IMAGE_TAG_OFFSET)];
                    
                    // Set the delegate to ensure the loaded image shows
                    imgToSet.highlighted = NO;
                    [[arrayOfImageRequests objectAtIndex:i] setDelegate:imgToSet];
                    
                }
            } else {
                NSLog(@"ViewController: error loading image at row %i. No image request to load", indexPath.row);
            } 
            
        } else {
            // If the index path is greater than the array count, then the cell has not appeared yet, and the image has not been prompted to load
            // Start loading the image with a LoadImageRequest, and it will appear automatically
            // Add it to the image array to be sure it doesn't load again
            
            if (entry.image && [entry.image length]) {
                // Group has default image to load
                gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:entry.image];
                imgRequest.delegate = groupCell.groupImage1;
                
                // Add it to the array of images
                [myGroupImages addObject:[NSArray arrayWithObject:imgRequest]];
                [imgRequest release];
                
            } else if ([entry.friends count]) {
                // Group doesn't have default image, so load images based on friends in the group
                // There will end up being an array of image requests created here
                NSMutableArray *imageRequests = [NSMutableArray array];
                // It should go through a maximum of 4 images, so a maximum index of 3
                int maximumIteration = [entry.friends count] > 4 ? 4 : [entry.friends count];

                for (int i = 0; i < maximumIteration; i++) {

                    GCFriend *friendWithImage = [entry.friends objectAtIndex:i];
                                    
                    UIImageView *imgToSet = (UIImageView *)[groupCell.contentView viewWithTag:(i + GROUPLIST_CELL_IMAGE_TAG_OFFSET)];

                    // Start the request, but make sure the image isn't blank
                    if ([friendWithImage.image length]) {
                        
                        gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:friendWithImage.image];
                        [imgRequest setDelegate:imgToSet];
                        [imageRequests addObject:imgRequest];
                        [imgRequest release];
                        
                    } else {
                        
                        gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:@"/Images/InsideChat/gc_blankuser.png"];
                        [imgRequest setDelegate:imgToSet];
                        [imageRequests addObject:imgRequest];
                        [imgRequest release];
                        
                    }
                }
                
                // Add the array of requests to the array
                [myGroupImages addObject:imageRequests];
                
            } else {
                // No group image or friend images... just show the default
                gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:@"/Images/InsideChat/gc_blankuser.png"];
                imgRequest.delegate = groupCell.groupImage1;
                
                // Add it to the array of images
                [myGroupImages addObject:[NSArray arrayWithObject:imgRequest]];
                [imgRequest release];
            }
        }
        
        // Check to see if there is a recent update
        if (entry.hasNewContent) {
            groupCell.backgroundImageView.image = [UIImage imageNamed:@"gc_grouprow_active.png"];
            groupCell.backgroundImageView.highlightedImage = [UIImage imageNamed:@"grouplist_blue_active_pressed.png"];
        } else {
            groupCell.backgroundImageView.image = [UIImage imageNamed:@"gc_grouprow_inactive.png"];
            groupCell.backgroundImageView.highlightedImage = [UIImage imageNamed:@"grouplist_blue_inactive_pressed.png"];
        }
        
        
        
        return groupCell;
    }
    
    else if(indexPath.section == 1) {
       
        //footer below groups list that contains a Start Group button and Profile link
        
        UITableViewCell *groupCell2 = [tableView dequeueReusableCellWithIdentifier:cellIDFooter];
        
        if (groupCell2 == nil) {
            groupCell2 = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDFooter] autorelease];
        
            
            
            groupCell2.accessoryType = UITableViewCellAccessoryNone;
            groupCell2.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIButton *startgroupButton = [[UIButton alloc] initWithFrame:CGRectMake(30,30,260,42)];
            [startgroupButton setBackgroundImage:[UIImage imageNamed:@"gc_startagroupbtn.png"] forState:UIControlStateNormal];
            [startgroupButton addTarget:self action:@selector(newGroupFromStartButtonInGroupListFooter) forControlEvents:UIControlEventTouchUpInside];
            [groupCell2.contentView addSubview:startgroupButton];//groupListFooterView];
            [startgroupButton release];
            
            
            UILabel *profileLinkLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,220,25)];
            profileLinkLbl.numberOfLines = 1;
            profileLinkLbl.font = [UIFont systemFontOfSize:15];
            profileLinkLbl.backgroundColor = [UIColor clearColor];
            profileLinkLbl.textColor = [UIColor colorWithRed:44.0f/255.0f green:147.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
            profileLinkLbl.text = @"My Groupcentric Profile";
            
            UIButton *profileLinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            profileLinkBtn.frame = CGRectMake(80,92,220,45);
            [profileLinkBtn addSubview:profileLinkLbl];
            [profileLinkBtn addTarget:self action:@selector(viewProfileFromProfileLinkInGroupListFooter:) forControlEvents:UIControlEventTouchUpInside];
            [groupCell2.contentView addSubview:profileLinkBtn];//groupListFooterView];
            [profileLinkBtn release];
            [profileLinkLbl release];
            
        
        }
        
        return groupCell2; //start group btn and profile link
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Remove the selected group
            
            GCGroup *groupToDelete = [myGroups objectAtIndex:indexPath.row];
            
            // Make API call with group id
            [[Groupcentric sharedInstance] removeGroup:groupToDelete.groupId result:^(BOOL success, NSError *error) {
                if (!error && success) {
                    // Success
                } else {
                    // Failed, so put the group back in
                    [self getGroups];
                }

            }];
            
            // Update the notification count. This removed group may have been new/updated
            [self getNotifications];
            
            // Remove from array for faster loading
            [myGroups removeObjectAtIndex:indexPath.row];
            [myGroupImages removeObjectAtIndex:indexPath.row];
            
            // Reload the table with a fancy little animation
            [theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //section 0 is groups list
    if(indexPath.section == 0)
    {
        // Get the group to view from the array, and open up the details
        
        GCGroup *selectedGroup = (GCGroup *)[myGroups objectAtIndex:indexPath.row];
        
        GCGroupDetailsVC *controller = [[GCGroupDetailsVC alloc] initWithGroup:selectedGroup];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
    
    
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
    
	[self getGroups];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(gc_EGORefreshTableHeaderView*)view{
    
	return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(gc_EGORefreshTableHeaderView*)view{
    
	return [NSDate date]; // should return date data source was last changed
    
}




@end
