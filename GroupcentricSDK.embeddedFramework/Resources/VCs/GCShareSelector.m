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
//  gc_ShareSelector.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

#define GROUPLIST_CELL_IMAGE_TAG_OFFSET 100

@interface GCShareSelector ()

@end

@implementation GCShareSelector

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithContent:(GCSharedObject *)sharedObj {
    if (self) {
        // Custom initialization
        sharedObject = [[GCSharedObject alloc]initWithContent:sharedObj.type withTitle:sharedObj.varTitle withSubtitle:sharedObj.varSubtitle withImageURL:sharedObj.imageURL withVariable:sharedObj.var1 withDate:sharedObj.varDateString withDetails:sharedObj.varDetails withMarkup:sharedObj.varMarkup];
      
    }
    return self;
}

#pragma mark - View lifecycle

int _signedIn = 0;
int _justSignedIn;


- (void)viewDidLoad
{
    
	// Do any additional setup after loading the view, typically from a nib.
    
    //self.title=@"Group Sharing";
    CGRect frame = CGRectMake(0,2,200,44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15.0];
    /*label.shadowColor =  [UIColor colorWithWhite:0.0 alpha:0.2];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[[UIColor alloc] initWithRed:49.0f/255.0f green:112.0f/255.0f blue:98.0f/255.0f alpha:1.0];*/
    label.shadowColor =  [[UIColor alloc] initWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[UIColor darkGrayColor];
    
    label.text = @"Group Sharing";
    self.navigationItem.titleView = label;
    [label release];
    
    
    // Initialize groups and images array
    myGroups = [[NSMutableArray alloc] init];
    myGroupImages = [[NSMutableArray alloc] init];
    
    // Initialize the date formatter
    dateFormatter = [[gc_TTTTimeIntervalFormatter alloc] init];
    
    // Set up table view parameters
    theTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTableView.backgroundColor = [UIColor clearColor];
    //theTableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0); // add insets for nicer spacing, and for dealing with overlapping bottom button
    
    // set the shared content ui
    titleShared.text = sharedObject.varTitle;
    NSLog(@"imageurl %@",sharedObject.imageURL);
    gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:sharedObject.imageURL];
    [imgRequest setDelegate:imageShared];
    [imgRequest release];
    
    // Set up the left navigation item
    // So, create a back button that dismisses the view controller entirely
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
    
    //check that the user has a GC account, if not need to remember that if they try to share content they will have to signin first
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    int userId = groupcentric.userId;
    
    _justSignedIn = 0;
    if (userId <= 0) {
        _signedIn =  0;
        [self.view bringSubviewToFront:getStartedView];
        [self.view sendSubviewToBack:theTableView];
    }
    else
    {
        _signedIn = 1;
        [self.view bringSubviewToFront:theTableView];
        [self.view sendSubviewToBack:getStartedView];
    }
    
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    int userId = groupcentric.userId;
   
    
    if(_signedIn == 1)
    {
        [self getGroups];
    }
    else{
        
       
        if(_signedIn == 0 && userId > 0)
        {
             _signedIn = 1;
            _justSignedIn = 1;
            [self.view bringSubviewToFront:theTableView];
            [self.view sendSubviewToBack:getStartedView];
            [self getGroups];
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [myGroups release];
    [myGroupImages release];
    [dateFormatter release];
    [sharedObject release];
    
    [super dealloc];
}

#pragma mark - Actions
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)getGroups {
    
    if (_reloading) {
        return; // Don't reload if it's already reloading
    }
    
    _reloading = YES;
    
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
   
    if (groupcentric.userId <= 0) {
        // Invalid user id
        return;
    }
 
    [groupcentric getGroups:^(NSArray *groups, NSError *error) {
     
        _reloading = NO;
        
        if (!error) {
            
            [myGroups removeAllObjects];
            [myGroups addObjectsFromArray:groups];
            
            [myGroupImages removeAllObjects];
            
            // Now update table view with a fancy animation
            [theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
           
            if(_justSignedIn == 1)
            {
                _justSignedIn = 0;
                if([groups count] == 0)
                {
                    GCNewGroupVC *controller = [[GCNewGroupVC alloc] initWithSharedObject:sharedObject];
                    
                    // Set up navigation
                    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
                    
                    // Show view
                    [self presentModalViewController:navCntrl animated:YES];
                    
                    [controller release];
                    [navCntrl release];
                }
            }
                
            
            
        } else {
            // Log the error
            NSLog(@"Error getting groups: %@ %@", error, [error userInfo]);
        }
        
        
    }];
    
    
}

-(void)viewPrivacyTos:(id)sender {
    GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:@"http://groupcentric.com/m/privacytos.html"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

-(void) getStarted:(id)sender {
    //need to ask them to signin
    GCSignupOrLoginVC *controller = [[GCSignupOrLoginVC alloc] initInSignupMode:YES];
    
    // Set up navigation
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
    
    // Show view
    [self presentModalViewController:navCntrl animated:YES];
    
    [controller release];
    [navCntrl release];
}

-(void) newGroupFromStartButtonInGroupListFooter:(id)sender {
    // Present the view controller for creating new groups
    
    if(_signedIn) {
        // Set up controller
        GCNewGroupVC *controller = [[GCNewGroupVC alloc] initWithSharedObject:sharedObject];
        
        // Set up navigation
        UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
        
        // Show view
        [self presentModalViewController:navCntrl animated:YES];
        
        [controller release];
        [navCntrl release];
    }
    else
    {
        //need to ask them to signin
        GCSignupOrLoginVC *controller = [[GCSignupOrLoginVC alloc] initInSignupMode:YES];
        
        // Set up navigation
        UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:controller];
        
        // Show view
        [self presentModalViewController:navCntrl animated:YES];
        
        [controller release];
        [navCntrl release];
    }
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case 0:
            return 80.0; //group
        case 1:
            return 200.0; //start group btn and profile link
            //case 2:
            //return 200.0; //start group btn and profile link
    }
    
    // Group cells should be 96 pixels high
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return [myGroups count]; //group
        case 1:
            return 1;
            
    }
    return 0;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //was 3 with no groups label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cell id for groups
	static NSString *cellID = @"cellID";
    // Cell id for startbtn and profile link below groups
    static NSString *cellIDFooter = @"cellIDFooter";
    // Cell id for no groups
    //static NSString *cellIDNogroups = @"cellIDNogroups";
    
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
            groupCell.backgroundImageView.highlightedImage = [UIImage imageNamed:@"gc_grouprow_active_pressed.png"];
        } else {
            groupCell.backgroundImageView.image = [UIImage imageNamed:@"gc_grouprow_inactive.png"];
            groupCell.backgroundImageView.highlightedImage = [UIImage imageNamed:@"gc_grouprow_inactive_pressed.png"];
        }
        
        
        
        return groupCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIDFooter];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDFooter] autorelease];
        
        
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *startgroupButton = [[UIButton alloc] initWithFrame:CGRectMake(30,30,260,42)];
        [startgroupButton setBackgroundImage:[UIImage imageNamed:@"gc_startagroupbtn.png"] forState:UIControlStateNormal];
        [startgroupButton addTarget:self action:@selector(newGroupFromStartButtonInGroupListFooter:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:startgroupButton];
        [startgroupButton release];
        
        
    }
    
    return cell; //start group btn and profile link
    
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
        
        GCGroupDetailsVC *controller = [[GCGroupDetailsVC alloc] initWithGroup:selectedGroup andWithSharedObject:sharedObject];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


@end
