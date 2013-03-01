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
//  GroupDetailsVC.m
//  Groupcentric SDK
//
//  Some code attributed to AcaniChat
//  https://github.com/acani/AcaniChat
//  Released under MIT license (http://opensource.org/licenses/MIT)
//




#import <GroupcentricSDK/GroupcentricSDK.h>

static CGFloat const kMessageFontSize           = 16.0f;
static CGFloat const kMessageTextWidth          = 198.0f;
static CGFloat const kContentHeightMax          = 74.0f;
static CGFloat const kChatBarHeight1            = 44.0f;
static CGFloat const kChatBarHeight4            = 100.0f;
static CGFloat const kChatBarAttachedLocation   = 140.0f;
static CGFloat const kChatBarAttachedPhoto      = 180.0f;

// Tags for action sheets and alert views
#define TAG_ALERT_CONFIRM_DELETE 10
#define TAG_ACTION_UPLOAD_CAMERA 11
#define TAG_ACTION_UPLOAD_NO_CAMERA 12
#define TAG_ACTION_ATTACHMENT_CAMERA 13
#define TAG_ACTION_ATTACHMENT_NO_CAMERA 14

// Tags for adding views into the message text view
#define TAG_MESSAGE_LOCATION_MAP 20
#define TAG_MESSAGE_PHOTO_IMAGE 21
#define TAG_MESSAGE_REMOVE_BUTTON 22
#define TAG_SHAREDOBJECT_TITLE 23

// Tag for the friend map image
#define TAG_FRIEND_MAP_IMAGE 30

// Constants for cell heights in the chat
#define CELL_HEIGHT_MINIMUM 56
#define CELL_PHOTO_HEIGHT 180
#define CELL_MAP_HEIGHT 80
#define CELL_OBJECT_HEIGHT 80
#define CELL_OBJECT_WIDTH 260


@implementation GCGroupDetailsVC

@synthesize previousContentHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        myGroup = [[GCGroup alloc] init];
        
        groupcentric = [Groupcentric sharedInstance];
    }
    return self;
}

//GroupDetailsVC being init'd from the gc_ShareSelector and passed an object to attach to a message
- (id)initWithGroup:(GCGroup *)group andWithSharedObject:(GCSharedObject *)sharedObj{
    if ((self = [super init])) {
        myGroup = [group retain];
        sharedObject = [[GCSharedObject alloc]initWithContent:sharedObj.type withTitle:sharedObj.varTitle withSubtitle:sharedObj.varSubtitle withImageURL:sharedObj.imageURL withURL:sharedObj.varURL withDate:sharedObj.varDateString withDetails:sharedObj.varDetails withMarkup:sharedObj.varMarkup];
        fromSharedSelector = true;
        groupcentric = [Groupcentric sharedInstance];
        
    }
    return self;
}


- (id)initWithGroup:(GCGroup *)group {
    if ((self = [super init])) {
        myGroup = [group retain];
        
        groupcentric = [Groupcentric sharedInstance];
        
    }
    return self;
}

- (id)initWithGroup:(GCGroup *)group andShouldDismissModalViewController:(BOOL)shouldDismiss {
    if ((self = [super init])) {
        myGroup = [group retain];
        shouldDismissViewController = shouldDismiss;
        _backButtonBlackColorFromModal = shouldDismiss; //determin if black like modal controller or same color as header from calling app
        groupcentric = [Groupcentric sharedInstance];
        
    }
    return self;
}

- (id)initWithGroup:(GCGroup *)group andShouldDismissModalViewController:(BOOL)shouldDismiss andFromNotifications:(BOOL)fromNotifications{
    if ((self = [super init])) {
        myGroup = [group retain];
        shouldDismissViewController = shouldDismiss;
        _backButtonBlackColorFromModal = fromNotifications; //determin if black like modal controller or same color as header from calling app
        groupcentric = [Groupcentric sharedInstance];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [groupImage release];
    [groupNameEditableField release];
    [myGroup release];
    [friendImages release];
    [chatImages release];
    [imageToAttach release];
    [locationManager release];
    [dateFormatter release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.title = myGroup.groupName;
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
    
    label.text = myGroup.groupName;
    self.navigationItem.titleView = label;
    [label release];
    
    // Set up the table view's background
    theTableView.backgroundColor = [UIColor clearColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.frame];
	background.image = [UIImage imageNamed:@"gc_greybg.png"];
	background.contentMode = UIViewContentModeCenter;
	theTableView.backgroundView = background;
	[background release];
    
    friendsCountLabel.text = [NSString stringWithFormat:@"%i friends in this chat", myGroup.friendsCount];
    
    // Initialize stuff
    friendImages = [[NSMutableArray alloc] init];
    chatImages = [[NSMutableArray alloc] init];
    imageToAttach = [[UIImage alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    dateFormatter = [[gc_TTTTimeIntervalFormatter alloc] init];
    
    // Set which of the top tab buttons is going to be selected first
    selectedButton = topChatButton;
    
    // No text, so send button is disabled
    sendButton.enabled = NO;
    
    // Set up the background of the bottom chat bar to handle stretching
    // As text is added to the message field, it should grow in size
    UIImage *img = [[UIImage imageNamed:@"gc_groupfootermerged.png"] stretchableImageWithLeftCapWidth:50.0 topCapHeight:24.0];
    bottomMessageBackground.image = img;
    bottomMessageBackground.clipsToBounds = YES;
    
    // Set up the group image
    groupImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 68, 68)];
    groupImage.clipsToBounds = YES;
    groupImage.contentMode = UIViewContentModeScaleAspectFill;
    groupImage.image = [UIImage imageNamed:@"gc_blankgroup.png"];
    if ([myGroup.image length]) {
        groupImage.highlighted = NO;
        
        gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:myGroup.image];
        [imgRequest setDelegate:groupImage];
        [imgRequest release];
    }
    
    // Set up the name field of the group which will be an editable text field
    groupNameEditableField = [[UITextField alloc] initWithFrame:CGRectMake(102, 50, 200, 31)];
    groupNameEditableField.text = myGroup.groupName;
    groupNameEditableField.delegate = self;
    groupNameEditableField.placeholder = @"Name this group";
    groupNameEditableField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    groupNameEditableField.autocorrectionType = UITextAutocorrectionTypeNo;
    groupNameEditableField.returnKeyType = UIReturnKeyDone;
    
    // Set up the left navigation item
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    if(_backButtonBlackColorFromModal)
        [backButton setBackgroundImage:[UIImage imageNamed:@"gc_blackbtn.png"] forState:UIControlStateNormal];
    else
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

    goBackToObjectDetails = NO;
    if (fromSharedSelector)
    {
        sendButton.enabled = YES;
        goBackToObjectDetails = YES;
    }
    
    // Set all the image attachment
    imageToAttach = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (shouldNotReload) {
        shouldNotReload = NO;
    } else {
        [self getGroupDetails];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check for update from a push notification with name @"refresh"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationComingThrough) name:@"refresh" object:nil];
    // Check for keyboard appearing/disappearing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    //check if object being shared from share selector
    if(fromSharedSelector)
    {
        if(sharedObject.type == 1)
        {
            //its a picture so check for title, if title exists then set as messageText.text
            if([sharedObject.varTitle length])
            {
                messageText.text = [[@"'" stringByAppendingString:sharedObject.varTitle] stringByAppendingString:@"'"];
            }
            sendButton.enabled = YES; //so can send image without text
        }
        
        //prepare the message input box to show a thumbnail of the object being attached
        UIImageView *imageViewAttached = [[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(messageText.frame) + 10, 14, 50, 50)] autorelease];
        imageViewAttached.clipsToBounds = YES;
        imageViewAttached.contentMode = UIViewContentModeScaleAspectFill;
        gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:sharedObject.imageURL];
        [imgRequest setDelegate:imageViewAttached];
        [imgRequest release];
        imageViewAttached.tag = TAG_MESSAGE_PHOTO_IMAGE;
        [bottomBar addSubview:imageViewAttached];
        
        UILabel *profileLinkLbl = [[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(messageText.frame) + 70, 14, 120, 40)] autorelease];
        profileLinkLbl.numberOfLines = 2;
        profileLinkLbl.font = [UIFont systemFontOfSize:13];
        profileLinkLbl.backgroundColor = [UIColor clearColor];
        profileLinkLbl.textColor = [UIColor colorWithRed:44.0f/255.0f green:147.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
        if(sharedObject.type > 1)
            profileLinkLbl.text = sharedObject.varTitle;
        profileLinkLbl.tag = TAG_SHAREDOBJECT_TITLE;
        [bottomBar addSubview:profileLinkLbl];
        
        //add an X for the user to remove the attachment
        UIButton *deleteButton = [[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(messageText.frame) + 3, 7, 24, 24)] autorelease];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"gc_cancelattachment.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(removeSharedObjectAttachment) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = TAG_MESSAGE_REMOVE_BUTTON;
        [bottomBar addSubview:deleteButton];
        
        previousContentHeight = 23.0f;
        
        [self updateTextViewContentSize:messageText];
        [messageText becomeFirstResponder];
    }
}

-(void) pushNotificationComingThrough {
    //update the parent view controller's notification new/unread count
    [self.delegate tellGroupsVCToRefresh];
    [self getGroupDetails];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //just incase it's being used...
    [locationManager stopUpdatingLocation];
    
    // Stop listening for update from push notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refresh" object:nil];
    // Stop listening for keyboard changes
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (selectedButton == topFriendsButton) {
        return 44.0;
    }
    
    if (selectedButton == topDetailsButton) {
        return 0.0; // there shouldn't be any cells here anyway
    }
    
    GCMessage *entry = [myGroup.messages objectAtIndex:indexPath.row];
    // Get message size
    CGSize textViewSize = [entry.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(224, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    // Find a starting height based on the message height
    CGFloat designatedCellHeight = textViewSize.height + 22 + 8; // text view frame has minimum Y value of 22px, and has 8 px of padding
    
    // Check the message type
    if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_TEXT) {
        // Just a message, meaning that the current height indicates the height of content in the cell
    } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_PHOTO) {
        // Picture
        designatedCellHeight += (CELL_PHOTO_HEIGHT + 16); // 8 pixel padding above and below the photo
    } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_LOCATION) {
        // Map of user location
        designatedCellHeight += (CELL_MAP_HEIGHT + 16); // 8 pixel padding above and below the map
    } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_URL) {
        // URL object
        designatedCellHeight += (CELL_OBJECT_HEIGHT + 16); // 8 pixel padding above and below the object
    } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_OBJECT || entry.type >= 100) {
        // Any other object
        designatedCellHeight += (CELL_OBJECT_HEIGHT + 16); // 8 pixel padding above and below the object
    }
    
    // Add the height for the detail label that indicates time of message, and add final padding
    designatedCellHeight += 24;
    
    if (designatedCellHeight < CELL_HEIGHT_MINIMUM) {
        designatedCellHeight = CELL_HEIGHT_MINIMUM;
    }
    
    return designatedCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (selectedButton == topFriendsButton) {
        // Show friends in the plan
        return [myGroup.friends count];
    }
    
    if (selectedButton == topDetailsButton) {
        return 0;
    }
    
    // selectedButton == topChatButton
	return [myGroup.messages count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (selectedButton == topFriendsButton) {
        // Friends tab is selected
        // Default is to have a 120px map with a 24px table header
        UIView *headerFriendView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(theTableView.frame), 144)] autorelease];
        
        UIImageView *divider = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 120, CGRectGetWidth(theTableView.frame), 24)] autorelease];
        divider.image = [UIImage imageNamed:@"gc_groupfriends_divider.png"];
        [headerFriendView addSubview:divider];
        
        UILabel *dividerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 120, 200, 24)] autorelease];
        dividerLabel.font = [UIFont boldSystemFontOfSize:14];
        dividerLabel.textColor = [UIColor darkGrayColor];
        dividerLabel.shadowColor = [UIColor whiteColor];
        dividerLabel.shadowOffset = CGSizeMake(0, 1);
        dividerLabel.text = @"Friends Locations";
        dividerLabel.backgroundColor = [UIColor clearColor];
        [headerFriendView addSubview:dividerLabel];
        
        
        // If there is a URL to a map of friend locations to show, put it in the header
        UIImageView *gc_blankmap = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(theTableView.frame), 120)] autorelease];
        
        gc_blankmap.tag = TAG_FRIEND_MAP_IMAGE;
        gc_blankmap.clipsToBounds = YES;
        gc_blankmap.contentMode = UIViewContentModeScaleAspectFill;
        
        if ([myGroup.friendLocationURL length]) {
            // Show the friends' locations in a web view
            [gc_blankmap setImageWithURL:[NSURL URLWithString:myGroup.friendLocationURL] placeholderImage:[UIImage imageNamed:@"gc_blankmap.png"]];
        } else {
            // Otherwise, just show a static image of a map
            [gc_blankmap setImage:[UIImage imageNamed:@"gc_blankmap.png"]];
        }
        
        [headerFriendView addSubview:gc_blankmap];
        
        return headerFriendView;
    }
    
    if (selectedButton == topDetailsButton) {
        // Details tab, should show group image and name in the title
        UIView *headerDetailView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(theTableView.frame), 214)] autorelease];
        
        // Add a background image for the header
        UIImageView *bgImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(theTableView.frame), 105)] autorelease];
        bgImage.image = [UIImage imageNamed:@"gc_detailstopbg.png"];
        [headerDetailView addSubview:bgImage];
        
        // Add the background to the text field
        UIImageView *textFieldBg = [[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(groupNameEditableField.frame) - 9, CGRectGetMinY(groupNameEditableField.frame) - 8, 218, 40)] autorelease]; // frame should have enough padding to fit text field inside, based on image size
        textFieldBg.image = [UIImage imageNamed:@"gc_namefillbox.png"];
        [headerDetailView addSubview:textFieldBg];
        
        // The image of the group
        [headerDetailView addSubview:groupImage];
        // The title of the group, a text field that the user can edit and save
        [headerDetailView addSubview:groupNameEditableField];
        
        // Put a little text description above the group name
        UILabel *groupNameHeader = [[[UILabel alloc] initWithFrame:CGRectMake(93, 15, 200, 20)] autorelease];
        groupNameHeader.backgroundColor = [UIColor clearColor];
        groupNameHeader.textColor = [UIColor darkGrayColor];
        groupNameHeader.font = [UIFont boldSystemFontOfSize:16];
        groupNameHeader.text = @"Group name";
        [headerDetailView addSubview:groupNameHeader];
        
        // Add a button over the image, so the user can edit the image
        UIButton *imageButton = [[[UIButton alloc] initWithFrame:groupImage.frame] autorelease];
        [imageButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
        [headerDetailView addSubview:imageButton];
        
        // Add a label for notifications
        UILabel *notificationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 112, 160, 27)] autorelease];
        notificationLabel.backgroundColor = [UIColor clearColor];
        notificationLabel.textColor = [UIColor darkGrayColor];
        notificationLabel.font = [UIFont boldSystemFontOfSize:16];
        notificationLabel.text = @"Notifications";
        [headerDetailView addSubview:notificationLabel];
        
        // Add the toggle for receiving notifications in the chat
        UISwitch *notificationToggle = [[[UISwitch alloc] initWithFrame:CGRectMake(300 - 79, 112, 79, 27)] autorelease];
        [notificationToggle addTarget:self action:@selector(toggleNotifications:) forControlEvents:UIControlEventValueChanged];
        [notificationToggle setOn:myGroup.pushEnabled]; // should only be on if pushes are enabled
        [headerDetailView addSubview:notificationToggle];
        
        // Set up the button to delete
        UIButton *deleteGroupButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 159, 300, 44)];
        [deleteGroupButton setBackgroundImage:[UIImage imageNamed:@"gc_greybtn.png"] forState:UIControlStateNormal];
        [deleteGroupButton setTitle:@"Leave this Group" forState:UIControlStateNormal];
        [deleteGroupButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [deleteGroupButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteGroupButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        deleteGroupButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [deleteGroupButton addTarget:self action:@selector(deleteGroup) forControlEvents:UIControlEventTouchUpInside];
        [headerDetailView addSubview:deleteGroupButton];
        
        // Lastly, put a label below the image to indicate that they are able to edit the image
        UILabel *imageUploadLabel = [[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(groupImage.frame), CGRectGetMaxY(groupImage.frame), CGRectGetWidth(groupImage.frame), 14)] autorelease];
        imageUploadLabel.backgroundColor = [UIColor clearColor];
        imageUploadLabel.textColor = [UIColor grayColor];
        imageUploadLabel.font = [UIFont systemFontOfSize:10];
        imageUploadLabel.textAlignment = UITextAlignmentCenter;
        imageUploadLabel.text = @"Tap to change";
        [headerDetailView addSubview:imageUploadLabel];
        
        return headerDetailView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (selectedButton == topFriendsButton) {
        // Friends tab, defaults to 144px header
        return 144.0;
    }
    
    if (selectedButton == topDetailsButton) {
        // Details tab, the header should include the image and name of the chat
        return 214.0;
    }
    
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return [[UIView new] autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return 0.01f;
    }
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"cellID";
    static NSString *friendCellID = @"friendCellID";
    
    if (selectedButton == topFriendsButton) {
        // Configure cells for the friends tab
        
        GCGroupFriendTableViewCell *friendCell = [tableView dequeueReusableCellWithIdentifier:friendCellID];
        
        if (friendCell == nil) {
            friendCell = [[[GCGroupFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCellID] autorelease];
            
            friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // Friend object
        GCFriend *friend = [myGroup.friends objectAtIndex:indexPath.row];
        
        // Set name label
        friendCell.friendName.text = friend.name;
        
        // Set the image
        [friendCell.friendImage setImageWithURL:[NSURL URLWithString:friend.image] placeholderImage:[UIImage imageNamed:@"gc_blankuser.png"]];
        
        // Check if the user has shared their location
        // If they have, set the location image
        if (friend.latitude) {
            friendCell.locationImage.image = [UIImage imageNamed:@"gc_groupfooter_location_unpressed.png"];
            friendCell.locationImage.highlightedImage = [UIImage imageNamed:@"gc_groupfooter_location_pressed.png"];
            friendCell.selectionStyle = UITableViewCellSelectionStyleGray;
        } else {
            friendCell.locationImage.image = nil;
            friendCell.locationImage.highlightedImage = nil;
            friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        return friendCell;
        
    } else if (selectedButton == topDetailsButton) {
        // Details tab selected, no cells should be returned
        
    }
    
    // Configure the cell for the chat messages
    GCGroupChatTableViewCell *groupCell = (GCGroupChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
	if (groupCell == nil) {
        groupCell = [[[GCGroupChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        
        groupCell.selectionStyle = UITableViewCellSelectionStyleNone;
        groupCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    GCMessage *entry = (GCMessage *)[myGroup.messages objectAtIndex:indexPath.row];
    
    // Set up the frame of the user image and user name label
    // Last minute change: keep all images formatted the same regardless of user
    // [groupCell formatImageAndLabelForSelf:NO];
    
    // Set the name
    groupCell.userNameLabel.text = entry.userName;
    // Set the image
    [groupCell.userIcon setImageWithURL:[NSURL URLWithString:entry.userImage] placeholderImage:[UIImage imageNamed:@"gc_blankuser.png"]];
    
    // Set up the message text
    groupCell.messageText.text = entry.message;
    // Figure out the frame of the text view
    CGSize textViewSize = [entry.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(224, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap]; // Subtract 16 from width to match text view padding
    
    //if (entry.userIsSelf) {
    //    groupCell.messageText.frame = CGRectMake(CGRectGetMaxX(groupCell.userNameLabel.frame) - textViewSize.width, 25, 240, textViewSize.height + 8); // add 8px for padding
    //} else {
    groupCell.messageText.frame = CGRectMake(CGRectGetMinX(groupCell.userNameLabel.frame), 25, textViewSize.width + 16, textViewSize.height + 8); // add 8px for padding
    //}
    
    // Start gathering the height of the content in the message
    CGFloat runningCellHeight = 22 + textViewSize.height;
    
    // Check for other content in the message and set the details accordingly
    if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_TEXT) {
        // Just a message. Hide any other unnecessary outlets
        [groupCell hideAttachmentLabelsAndImages];
        
    } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_PHOTO) {
        // This is an attached photo. Set the frame.
        // For now, we're going to leave it as a square, but you could use ImageIO framework to get the size
        
        groupCell.attachmentBackground.image = [[UIImage imageNamed:@"gc_photobg.png"] stretchableImageWithLeftCapWidth:8.0 topCapHeight:8.0];
        
        //if (entry.userIsSelf) {
        //    groupCell.attachmentBackground.frame = CGRectMake(CGRectGetMaxX(groupCell.userNameLabel.frame) - (CELL_PHOTO_HEIGHT + 10), runningCellHeight + 13, CELL_PHOTO_HEIGHT + 10, CELL_PHOTO_HEIGHT + 10);
        //} else {
        groupCell.attachmentBackground.frame = CGRectMake(CGRectGetMinX(groupCell.userNameLabel.frame), runningCellHeight + 13, CELL_PHOTO_HEIGHT + 10, CELL_PHOTO_HEIGHT + 10);
        //}
        
        groupCell.attachmentImage.frame = CGRectMake(CGRectGetMinX(groupCell.attachmentBackground.frame) + 5, CGRectGetMinY(groupCell.attachmentBackground.frame) + 5, CELL_PHOTO_HEIGHT, CELL_PHOTO_HEIGHT);
        
        [groupCell.attachmentImage setImageWithURL:[NSURL URLWithString:entry.attachmentImage] placeholderImage:[UIImage imageNamed:@"gc_blankgroup.png"]];
        
        groupCell.attachmentLabel.text = @"";
        groupCell.attachmentDetails.text = @"";
        
        runningCellHeight += (CELL_PHOTO_HEIGHT + 14); // add photo height plus padding on each side
        
    } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_LOCATION) {
        // This is an attached lat/lon of a user. Add a map and set the frame.
        
        groupCell.attachmentBackground.image = [[UIImage imageNamed:@"gc_objectbg.png"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
        
        //if (entry.userIsSelf) {
        //    groupCell.attachmentBackground.frame = CGRectMake(CGRectGetMaxX(groupCell.userNameLabel.frame) - CELL_OBJECT_WIDTH, runningCellHeight + 13, CELL_OBJECT_WIDTH, CELL_OBJECT_HEIGHT + 10);
        //
        //} else {
        groupCell.attachmentBackground.frame = CGRectMake(CGRectGetMinX(groupCell.userNameLabel.frame), runningCellHeight + 13, CELL_OBJECT_WIDTH, CELL_OBJECT_HEIGHT + 10);
        //
        //}
        
        groupCell.attachmentImage.frame = CGRectMake(CGRectGetMinX(groupCell.attachmentBackground.frame) + 5, CGRectGetMinY(groupCell.attachmentBackground.frame) + 5, CELL_OBJECT_WIDTH - 24, CELL_OBJECT_HEIGHT); // subtract 24 from width to show the disclosure indicator of attachment background image
        
        // Generate a static google map with the location
        [groupCell.attachmentImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=13&size=280x%i&maptype=roadmap&markers=color:blue%%7Clabel:*%%7C%f,%f&sensor=false", entry.latitude, entry.longitude, CELL_MAP_HEIGHT, entry.latitude, entry.longitude]]
                                  placeholderImage:[UIImage imageNamed:@"gc_mapload.png"]];
        
        groupCell.attachmentLabel.text = @"";
        groupCell.attachmentDetails.text = @"";
        
        runningCellHeight += (CELL_MAP_HEIGHT + 14); // add photo height plus padding on each side
        
    } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_OBJECT || entry.type == GROUPCENTRIC_MESSAGE_TYPE_URL || entry.type >= 100) {
        // This is an object attachment
        //Type 3 GROUPCENTRIC_MESSAGE_TYPE_URL is an object that when tapped will open an associated url
        //Type 4 GROUPCENTRIC_MESSAGE_TYPE_OBJECT is an object with a title,subtitle,date,details,etc or parts of
        //Type 100+ is a custom object that a developer has defined. If the object's API key matches the current app viewing it then render the image and title and leave the ontap to the developer. Else, when the object is tapped on it should open to the app brand's url so the user can get that brand's app.
        
        GCObject *objectAttached = entry.object;
        
        //
        // Set up the frames of the background image as well as the details label/image
        //
        groupCell.attachmentBackground.image = [[UIImage imageNamed:@"gc_objectbg.png"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
        
        //if (entry.userIsSelf) {
        //    groupCell.attachmentBackground.frame = CGRectMake(CGRectGetMaxX(groupCell.userNameLabel.frame) - CELL_OBJECT_WIDTH, runningCellHeight + 13, CELL_OBJECT_WIDTH, CELL_OBJECT_HEIGHT + 10);
        //} else {
        groupCell.attachmentBackground.frame = CGRectMake(CGRectGetMinX(groupCell.userNameLabel.frame), runningCellHeight + 13, CELL_OBJECT_WIDTH, CELL_OBJECT_HEIGHT + 10);
        //}
        
        // Setting image and label frames are relative to attachment background, with 5px of padding
        // Only show if there is a valid image to be displayed
        if ([entry.attachmentImage length]) {
            groupCell.attachmentImage.frame = CGRectMake(CGRectGetMinX(groupCell.attachmentBackground.frame) + 5, CGRectGetMinY(groupCell.attachmentBackground.frame) + 5, CELL_OBJECT_HEIGHT, CELL_OBJECT_HEIGHT);
            [groupCell.attachmentImage setImageWithURL:[NSURL URLWithString:objectAttached.imageURL] placeholderImage:[UIImage imageNamed:@"gc_blankgroup.png"]];
            groupCell.attachmentLabel.frame = CGRectMake(CGRectGetMaxX(groupCell.attachmentImage.frame) + 5, CGRectGetMinY(groupCell.attachmentImage.frame), CELL_OBJECT_WIDTH - 30 - CGRectGetWidth(groupCell.attachmentImage.frame), 20);
        } else {
            groupCell.attachmentImage.frame = CGRectZero;
            groupCell.attachmentLabel.frame = CGRectMake(CGRectGetMinX(groupCell.attachmentBackground.frame) + 10, CGRectGetMinY(groupCell.attachmentBackground.frame) + 5, CELL_OBJECT_WIDTH - 30 - CGRectGetWidth(groupCell.attachmentImage.frame), 18);
        }
        
        // Check that the title is not empty. If it is, then the details should be centered onto the background image
        if ([objectAttached.varTitle length]) {
            groupCell.attachmentDetails.frame = CGRectMake(CGRectGetMinX(groupCell.attachmentLabel.frame), CGRectGetMaxY(groupCell.attachmentLabel.frame), CELL_OBJECT_WIDTH - 30 - CGRectGetWidth(groupCell.attachmentImage.frame), 54);
        } else {
            groupCell.attachmentDetails.frame = CGRectMake(CGRectGetMinX(groupCell.attachmentLabel.frame), CGRectGetMinY(groupCell.attachmentImage.frame), CELL_OBJECT_WIDTH - 30 - CGRectGetWidth(groupCell.attachmentImage.frame), CGRectGetHeight(groupCell.attachmentImage.frame));
        }
        
        //
        // Set the labels
        //
        groupCell.attachmentLabel.text = objectAttached.varTitle;
        
        // Check if the object is either a normal object or a brand object from the same API key
        if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_URL) {
            // This is a URL, show the link in detail label
            if([objectAttached.varSubtitle length])
            {
                groupCell.attachmentDetails.text = objectAttached.varSubtitle;
            }
            else
                groupCell.attachmentDetails.text = objectAttached.var1;
        } else if (entry.type == GROUPCENTRIC_MESSAGE_TYPE_OBJECT || [objectAttached.apiKey isEqualToString:groupcentric._apiKey]) {
            // Regular object
            if ([objectAttached.varDateString length]) {
                if ([objectAttached.varSubtitle length]) {
                    groupCell.attachmentDetails.text = [NSString stringWithFormat:@"%@ - %@", objectAttached.varDateString, objectAttached.varSubtitle];
                } else {
                    groupCell.attachmentDetails.text = objectAttached.varDateString;
                }
            } else {
                groupCell.attachmentDetails.text = objectAttached.varSubtitle;
            }
        } else {
            // This is a brand custom object 
            groupCell.attachmentDetails.text = [NSString stringWithFormat:@"View details on %@ app", entry.brand];
        }
        
        runningCellHeight += (CELL_OBJECT_HEIGHT + 14); // add photo height plus padding on each side
        
    } else {
        // This is an unexpected type
        [groupCell hideAttachmentLabelsAndImages];
    }
    
    // Lastly, add the details label that will indicate the time of message sent
    groupCell.detailsLabel.text = [dateFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:entry.date];
    // Set frame
    groupCell.detailsLabel.frame = CGRectMake(56, runningCellHeight + 9, 208, 18); // provides enough spacing regardless of whether user is self
    // Set alignment
    //if (entry.userIsSelf) {
    //    groupCell.detailsLabel.textAlignment = UITextAlignmentRight;
    //} else {
    groupCell.detailsLabel.textAlignment = UITextAlignmentLeft;
    //}
    
    // Set the background image
    NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"gc_cell-back" ofType:@"png"];
    UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
    groupCell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    groupCell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return groupCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (selectedButton == topFriendsButton) {
        
        // Go to a specific friend's location
        
        GCFriend *friend = [myGroup.friends objectAtIndex:indexPath.row];
        
        if (friend.latitude) {
            // Set the friends map to zoom in on location
            UIImageView *mapImage = (UIImageView *)[theTableView viewWithTag:TAG_FRIEND_MAP_IMAGE];
            
            [mapImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=320x120&maptype=roadmap&markers=color:blue%%7Clabel:*%%7C%f,%f&sensor=false", friend.latitude, friend.longitude, friend.latitude, friend.longitude]]
                     placeholderImage:[UIImage imageNamed:@"gc_mapload.png"]];
            
        }
        
    } else if (selectedButton == topDetailsButton) {
        
        // There aren't any actions associated with selecting these cells yet
        
    } else if (selectedButton == topChatButton) {
        
        // Selecting a cell within a chat
        // The action depends on the message type
        
        GCMessage *messageSelected = [myGroup.messages objectAtIndex:indexPath.row];
        
        if (messageSelected.type == GROUPCENTRIC_MESSAGE_TYPE_TEXT) {
            
            // Just a message. No action
            
        } else if (messageSelected.type == GROUPCENTRIC_MESSAGE_TYPE_PHOTO) {
            
            // This is an attached photo. Open all photos.
            
            NSMutableArray *photos = [NSMutableArray array];
            // Check for what index the current photo is with respect to all group photos
            int selectedIndex = 0;
            for (int i = 0; i < [myGroup.sharedImages count]; i++) {
                NSString *imgString = [myGroup.sharedImages objectAtIndex:i];
                if ([imgString isEqualToString:messageSelected.attachmentImage]) {
                    selectedIndex = i;
                }
                [photos addObject:[gc_MWPhoto photoWithURL:[NSURL URLWithString:imgString]]];
            }
            
            // Dismiss keyboard to fix weird issue
            [messageText resignFirstResponder];
            
            // Create browser
            gc_MWPhotoBrowser *browser = [[gc_MWPhotoBrowser alloc] initWithPhotos:photos andStrings:myGroup.sharedImages andName:myGroup.groupName];
            [browser setInitialPageIndex:selectedIndex];
            [self.navigationController pushViewController:browser animated:YES];
            [browser release];
            
            shouldNotReload = YES;
            
        } else if (messageSelected.type == GROUPCENTRIC_MESSAGE_TYPE_LOCATION) {
            
            if (messageSelected.latitude) {
                // valid lat long
                
                // Dismiss keyboard to fix weird issue
                [messageText resignFirstResponder];
                
                GCMapVC *controller = [[GCMapVC alloc] initWithLatitude:messageSelected.latitude andLongitude:messageSelected.longitude];
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
                
                shouldNotReload = YES;
                
            } else {
                NSLog(@"No valid latitude/longitude pair to show");
            }
            
        } else if (messageSelected.type == GROUPCENTRIC_MESSAGE_TYPE_URL) {
            
            // This is an attached URL. Open the link
            
            // Dismiss keyboard to fix weird issue
            [messageText resignFirstResponder];
            
            // The link is stored in the message object under the "var1" property
            GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:messageSelected.object.var1];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            
            shouldNotReload = YES;
            
        } else if (messageSelected.type == GROUPCENTRIC_MESSAGE_TYPE_OBJECT) {
            
            // Dismiss keyboard to fix weird issue
            [messageText resignFirstResponder];
            
            // This is an attached object. View the details
            GCObjectDetailsVC *controller = [[GCObjectDetailsVC alloc] initWithObject:messageSelected.object];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            
            shouldNotReload = YES;
            
        } else if (messageSelected.type >= 100) {
            
            // This is a custom object from a developer
            if (![messageSelected.object.apiKey isEqualToString:groupcentric._apiKey]) {
                // API keys do not match, open brand URL
                [messageText resignFirstResponder];
                
                GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:messageSelected.brandURL];
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
                
                shouldNotReload = YES;
            }
            else{
                /*DEVELOPERS ADD YOUR CUSTOM OBJECT CODE HERE
                 if (messageSelected.type == XYZ) {  //your custom object TYPE
                    //Take the values from the messageSelected and pass them to a view controller of your own to process.
                    //You can pass the gc_Object object  messageSelected.object  which contains all the message content
                    //or you can pass the values individually if you want (all are strings):
                    //messageSelected.object.imageURL;
                    //messageSelected.object.var1;     (var1 is a wildcard usually used for a url or object id)
                    //messageSelected.object.varTitle;
                    //messageSelected.object.varSubtitle;
                    //messageSelected.object.varDateString;
                    //messageSelected.object.varDetails;
                    //messageSelected.object.varMarkup;
                 }
                 */
            }
            
        }
    }
    
}

#pragma mark - Actions

- (void)goBack {
    if(fromSharedSelector || goBackToObjectDetails) //from a shared object details view into this group
    {
        NSArray *vcs = [self.navigationController viewControllers];
        [self.navigationController popToViewController:[vcs objectAtIndex:[vcs count]-3] animated:true];
    }
    
    else{ //normal
        if (shouldDismissViewController) {
            [self dismissModalViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)getGroupDetails {
    
    // Set activity indicator in right of navigation bar to show loading
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
    
    [groupcentric openGroup:myGroup.groupId result:^(GCGroup *group, NSError *error) {
        
        _reloading = NO;
        
        // Show that loading has ended
        self.navigationItem.rightBarButtonItem = nil;
        
        if (!error) {
            // Success!
            [myGroup release];
            myGroup = [group retain];
            
            [chatImages release];
            chatImages = [[NSMutableArray alloc] initWithCapacity:[myGroup.messages count]];
            
            // Get some basic information out of thew newly found group!
            
            // Check if the group creator is defined
            if ([myGroup.groupCreator length]) {
                groupCreatorLabel.text = [NSString stringWithFormat:@"Group started by %@", myGroup.groupCreator];
            }
            
            // Check if there's an image
            if ([myGroup.image length]) {
                groupImage.highlighted = NO;
                
                gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:myGroup.image];
                [imgRequest setDelegate:groupImage];
                [imgRequest release];
            }
            
            // Update how many friends are in the group
            if ([myGroup.friends count] == 1) {
                friendsCountLabel.text = @"1 friend in this chat";
            } else {
                friendsCountLabel.text = [NSString stringWithFormat:@"%i friends in this chat", [myGroup.friends count]];
            }
            
            // Get all of the friend images loaded right off the bat
            for (GCFriend *friend in myGroup.friends) {
                // Create the class LoadImageRequest which will start asyncronously loading images
                if ([friend.image length]) {
                    gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:friend.image];
                    // Add it to image array
                    [friendImages addObject:imgRequest];
                    [imgRequest release];
                } else {
                    gc_LoadImageRequest *imgRequest = [[gc_LoadImageRequest alloc] initWithResourceString:@"/Images/InsideChat/gc_blankuser.png"];
                    // Add it to image array
                    [friendImages addObject:imgRequest];
                    [imgRequest release];
                }
            }
            
            [theTableView reloadData];
            
            if (selectedButton == topChatButton) {
                if (initialized) {
                    [self scrollToBottomAnimated:YES];
                } else {
                    [self scrollToBottomAnimated:NO];
                }
            }
        } else {
            // Log the error
        }
        
        initialized = YES;
    }];
}

- (IBAction)toggleChat:(id)sender {
    if (selectedButton != topChatButton) {
        selectedButton = topChatButton;
        
        [theTableView reloadData];
        
        // Set top toggle images
        [topFriendsButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_friendsbtn_unpressed.png"] forState:UIControlStateNormal];
        [topDetailsButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_detailsbtn_unpressed.png"] forState:UIControlStateNormal];
        [topChatButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_chatbtn_pressed.png"] forState:UIControlStateNormal];
        
        // Fix the bottom bar
        if ([messageText.text length]) {
            [messageText becomeFirstResponder];
        }
        
        if ([bottomDetailsView superview]) {
            [bottomDetailsView removeFromSuperview];
        }
        if ([bottomFriendsView superview]) {
            [bottomFriendsView removeFromSuperview];
        }
        
        [self scrollToBottomAnimated:NO];
        
        [self updateTextViewContentSize:messageText];
    }
}

- (IBAction)toggleFriends:(id)sender {
    if (selectedButton != topFriendsButton) {
        selectedButton = topFriendsButton;
        
        [theTableView reloadData];
        
        [messageText resignFirstResponder]; // hide the keyboard
        
        [topFriendsButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_friendsbtn_pressed.png"] forState:UIControlStateNormal];
        [topDetailsButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_detailsbtn_unpressed.png"] forState:UIControlStateNormal];
        [topChatButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_chatbtn_unpressed.png"] forState:UIControlStateNormal];
        
        // Fix the bottom bar
        [self setChatBarHeight:44];
        if ([bottomDetailsView superview]) {
            [bottomDetailsView removeFromSuperview];
        }
        if (![bottomFriendsView superview]) {
            [bottomBar addSubview:bottomFriendsView];
        }
        
    }
}

- (IBAction)toggleDetails:(id)sender {
    if (selectedButton != topDetailsButton) {
        selectedButton = topDetailsButton;
        
        [theTableView reloadData];
        
        [messageText resignFirstResponder]; // hide the keyboard
        
        [topFriendsButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_friendsbtn_unpressed.png"] forState:UIControlStateNormal];
        [topDetailsButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_detailsbtn_pressed.png"] forState:UIControlStateNormal];
        [topChatButton setBackgroundImage:[UIImage imageNamed:@"gc_groupheader_chatbtn_unpressed.png"] forState:UIControlStateNormal];
        
        // Fix the bottom bar
        [self setChatBarHeight:44];
        if (![bottomDetailsView superview]) {
            [bottomBar addSubview:bottomDetailsView];
        }
        if ([bottomFriendsView superview]) {
            [bottomFriendsView removeFromSuperview];
        }
        
    }
}

- (IBAction)addSomething {
    
    // Hide keyboard so action sheet shows properly
    [messageText resignFirstResponder];
    [groupNameEditableField resignFirstResponder];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"Attach to your message" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo from Library", @"My Location", nil];
        ac.tag = TAG_ACTION_ATTACHMENT_CAMERA;
        ac.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [ac showInView:self.view];
        [ac release];
    } else {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"Attach to your message" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Photo From Library", @"My Location", nil];
        ac.tag = TAG_ACTION_ATTACHMENT_NO_CAMERA;
        ac.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [ac showInView:self.view];
        [ac release];
    }

}

- (void)hideAddSomethingView {
    addingSomething = NO;
    // Animate the add view to disappear below the screen
    [UIView beginAnimations:nil context:NULL];
    
    addPhotoOrLocationView.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) + (CGRectGetHeight(addPhotoOrLocationView.frame) / 2));
    addPhotoOrLocationView.alpha = 0;
    
    [UIView commitAnimations];
}

- (IBAction)sendMessage {
    
    if (attachingImage) {
        // Sending a photo, the api call will be replaced by the ASIHTTPRequest
        [self sendMessageWithImage];
        return;
    }
    
    NSString *messageStringRaw = [[messageText.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if (!fromSharedSelector && !attachingLocation && [messageStringRaw length] == 0) {
        // No attachment, and message is basically empty
        messageText.text = @"";
        
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Cannot Send Message" message:@"Your message was blank. Please enter some text before sending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
        
        return;
    }
    
    // Set activity indicator in right of navigation bar to show loading
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
    
    self.title = @"Sending...";
    
    // Add the message to the group assuming that it will go through successfully.
    GCMessage *newMessage = [[GCMessage alloc] init];
    newMessage.userIsSelf = YES;
    newMessage.userId = groupcentric.userId;
    // Pull the image from friend list
    NSString *usrImg = [NSString stringWithFormat:@"http://www.groupcentric.com/images/users/Profile%i.jpg", newMessage.userId]; // Deprecated image source
    for (GCFriend *frnd in myGroup.friends) {
        // Iterate through each friend in the group to find the user's image
        // This is just for speed of use to the use to add a full message before the API call is complete
        if (frnd.userIsSelf == YES) {
            usrImg = frnd.image;
            break;
        }
    }
    
    newMessage.userImage = usrImg;
    newMessage.userName = groupcentric.userFullName;
    newMessage.groupId = myGroup.groupId;
    newMessage.message = messageText.text;
    newMessage.date = [NSDate date];
    newMessage.attachmentImage = @"";
    
    // Deterimne the attachment type
    if (attachingLocation) {
        // Attach a latitude and longitude
        newMessage.type = GROUPCENTRIC_MESSAGE_TYPE_LOCATION;
        newMessage.latitude = locationManager.location.coordinate.latitude;
        newMessage.longitude = locationManager.location.coordinate.longitude;
    } else if (fromSharedSelector) {
        //app content object being shared
        newMessage.attachmentImage = sharedObject.imageURL;
        newMessage.object = [[GCObject alloc] init];
        newMessage.type = sharedObject.type;
        newMessage.object.varTitle = sharedObject.varTitle;
        newMessage.object.varSubtitle = sharedObject.varSubtitle;
        newMessage.object.imageURL = sharedObject.imageURL;
        newMessage.object.var1 = sharedObject.varURL;
        newMessage.object.varDateString = sharedObject.varDateString;
        NSString *tmp = [sharedObject.varDetails stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        tmp = [tmp stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        tmp = [tmp stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        newMessage.object.varDetails = tmp;
        NSString *tmpM = [sharedObject.varMarkup stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        tmpM = [tmpM stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        tmpM = [tmpM stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        newMessage.object.varDetails = tmp;
        newMessage.object.varMarkup = tmpM;
        
        if(sharedObject.type == 1)
        {
            [myGroup.sharedImages addObject:sharedObject.imageURL];
        }
    } else {
        newMessage.type = GROUPCENTRIC_MESSAGE_TYPE_TEXT;
    }
    
    // Disable send button temporarily
    sendButton.enabled = NO;
    
    // Assume the message will send successfully and add it to the array
    [myGroup.messages addObject:newMessage];
    
    [groupcentric sendMessage:newMessage result:^(BOOL success, NSError *error) {
        
        // Activity has ended
        self.title = myGroup.groupName;
        self.navigationItem.rightBarButtonItem = nil;
        
        // Only re-enable the send button if there's text to send
        if ([messageText.text length]||fromSharedSelector||attachingLocation) {
            sendButton.enabled = YES;
        }
        
        if (success) {
            // Sent message successfully
            // Everything went according to plan...
        } else {
            if (error) {
                // Log the error
                NSLog(@"GroupDetails: Error sending message: %@", error);
            }
            // Alert the user
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error Sending Message" message:@"Your message was not sent successfully. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
            
            // Remove the message that we thought was sent successfully
            [myGroup.messages removeLastObject];
            [theTableView reloadData];
            
        }
        [newMessage release];
    }];
    
    messageText.text = @"";
    
    // Removing any attachments also resets heights for bottom bar
    [self removeSharedObjectAttachment];
    [self removeLocationAttachment];
    [self removePhotoAttachment];
    
    [theTableView reloadData];
    [self scrollToBottomAnimated:YES];
    
    [self.view endEditing:TRUE];
    
}

- (void)sendMessageWithImage {
    // Note: you could upload an image with the standard API using an image URL, but rather than uploading an image, getting the URL, and then making the API call, you can use Groupcentric's image uploading functionality
    
    // Set activity indicator in right of navigation bar to show loading
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
    
    self.title = @"Sending...";
    
    NSData *imageData = UIImageJPEGRepresentation(imageToAttach, 0.4);
    
    // setting up the URL to post to
    NSString *urlString = @"http://www.groupcentric.com/mobileImageUpload.ashx";
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    // convert to base64
    const uint8_t* input = (const uint8_t*)[imageData bytes];
    NSInteger length = [imageData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    // After that magical code created a base64 version of the image, we're ready to send it off
    
    NSString *imageDataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSDateFormatter *tempDateFormatter = [[NSDateFormatter alloc] init];
    tempDateFormatter.dateStyle = NSDateFormatterShortStyle;
    tempDateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    // Set up the request
    gc_ASIFormDataRequest *request = [gc_ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[NSNumber numberWithInt:myGroup.groupId] forKey:@"groupid"];
    [request setPostValue:[NSNumber numberWithInt:groupcentric.userId] forKey:@"userid"];
    [request setPostValue:[NSString stringWithFormat:@"C"] forKey:@"imagetype"];
    [request setPostValue:imageDataString forKey:@"image"];
    [request setPostValue:messageText.text forKey:@"msg"];
    [request setPostValue:[tempDateFormatter stringFromDate:[NSDate date]] forKey:@"devicedate"];

    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];
    [imageDataString release];
    
    messageText.text = @"";
    
    // Removing any attachments also resets heights for bottom bar
    [self removePhotoAttachment];
    
    [theTableView reloadData];
    [self scrollToBottomAnimated:YES];
    
}

- (IBAction)attachLocation {
    
    if (attachingImage) {
        // You are only able to attach either a photo or location, not both
        
        [self hideAddSomethingView];
        
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Already Attaching Photo" message:@"You can't attach a photo and a location. If you want to add your location, remove the photo attachment first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
        
        return;
    }
    
    // Check authorization status
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Location Access Denied" message:@"To share your location on this app, please go to Settings > Privacy > Location and enable access" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
        
        return;
    }
    
    if (addingSomething) {
        [self hideAddSomethingView];
        
        // If they're already attaching location, no need to do anything
        if (!attachingLocation) {
            // Have the location manager pull the user's location
            [locationManager startUpdatingLocation];
            // Don't let them try again until we've heard back from the delegate
            locationButton.enabled = NO;
        }
    } else {
        // The button in the message text field was tapped
        // For this button, we allow toggling to turn location on/off
        if (attachingLocation) {
            // Already attaching, so remove it
            [self removeLocationAttachment];
        } else {
            // Have the location manager pull the user's location
            [locationManager startUpdatingLocation];
            // Don't let them try again until we've heard back from the delegate
            locationButton.enabled = NO;
        }
    }
}

- (IBAction)attachPhoto {
    // Can use the same function used to edit the group image
    
    if (attachingLocation) {
        // You are only able to attach either a photo or location, not both
        
        [self hideAddSomethingView];
        
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Already Attaching Location" message:@"You can't attach a photo and a location. If you want to add a photo, remove your location first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
        
        return;
    }
    
    [messageText resignFirstResponder];
    
    [self editImage];
    [self hideAddSomethingView];
}

- (void)removeLocationAttachment {
    [locationManager stopUpdatingLocation];
    [locationButton setBackgroundImage:[UIImage imageNamed:@"gc_groupfooter_location_unpressed.png"] forState:UIControlStateNormal];
    
    attachingLocation = NO;
    
    // Remove the views added to indicate location
    MKMapView *locationMap = (MKMapView *)[bottomBar viewWithTag:TAG_MESSAGE_LOCATION_MAP];
    [locationMap removeFromSuperview];
    UIButton *deleteButton = (UIButton *)[bottomBar viewWithTag:TAG_MESSAGE_REMOVE_BUTTON];
    [deleteButton removeFromSuperview];
    
    if ([messageText.text length]) {
        previousContentHeight = -10.0f;
    }
    
    [self updateTextViewContentSize:messageText];
}

- (void)removePhotoAttachment {
    
    attachingImage = NO;
    
    // Remove the views added to indicate location
    UIImageView *photoImage = (UIImageView *)[bottomBar viewWithTag:TAG_MESSAGE_PHOTO_IMAGE];
    [photoImage removeFromSuperview];
    UIButton *deleteButton = (UIButton *)[bottomBar viewWithTag:TAG_MESSAGE_REMOVE_BUTTON];
    [deleteButton removeFromSuperview];
    
    if ([messageText.text length]) {
        previousContentHeight = -7.0f;
    }
    
    [self updateTextViewContentSize:messageText];
}

-(void)removeSharedObjectAttachment {
    fromSharedSelector = NO;
    // Remove the views added to indicate location
    UIImageView *photoImage = (UIImageView *)[bottomBar viewWithTag:TAG_MESSAGE_PHOTO_IMAGE];
    [photoImage removeFromSuperview];
    UIButton *deleteButton = (UIButton *)[bottomBar viewWithTag:TAG_MESSAGE_REMOVE_BUTTON];
    [deleteButton removeFromSuperview];
    UILabel *titleLbl = (UILabel *)[bottomBar viewWithTag:TAG_SHAREDOBJECT_TITLE];
    [titleLbl removeFromSuperview];
    
    if ([messageText.text length]) {
        previousContentHeight = -7.0f;
    }
    
    [self updateTextViewContentSize:messageText];
}

- (IBAction)addMoreFriends {
    // Show the controller for picking contacts from the user's phone
    gc_TKPeoplePickerController *controller = [[[gc_TKPeoplePickerController alloc] initPeoplePicker] autorelease];
    controller.actionDelegate = self;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalViewController:controller animated:YES];
}

- (void)editImage {
    
    // Resign text fields so the action sheet shows properly
    [messageText resignFirstResponder];
    [groupNameEditableField resignFirstResponder];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
        ac.tag = TAG_ACTION_UPLOAD_CAMERA;
        ac.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [ac showInView:self.view];
        [ac release];
    } else {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing", nil];
        ac.tag = TAG_ACTION_UPLOAD_NO_CAMERA;
        ac.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [ac showInView:self.view];
        [ac release];
    }
    //when user changes image for group and goes back to groups list want the list to refresh
    [self.delegate tellGroupsVCToRefresh];
}

- (void)saveGroupName {
    
    // Set activity indicator in right of navigation bar to show loading
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
    
    // Remove any buttons from the left of nav bar
    self.navigationItem.leftBarButtonItem = nil;
    
    self.title = @"Saving...";
    
    [groupcentric editGroup:myGroup.groupId withGroupName:groupNameEditableField.text andGroupImage:myGroup.image result:^(BOOL success, NSError *error) {
        
        // API call finished
        
        if (success) {
            // Success
            myGroup.groupName = groupNameEditableField.text;
            self.title = myGroup.groupName;
            
        } else {
            if (error) {
                // Log the error
                NSLog(@"GroupDetails: Error saving group: %@", error);
            }
            // Alert the user
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error Saving Group" message:@"Your group name was not saved successfully. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
            
        }
        
        [self cancelNameEdit];
        
    }];
    //when user changes name for group and goes back to groups list want the list to refresh
    [self.delegate tellGroupsVCToRefresh];
}

- (void)cancelNameEdit {
    groupNameEditableField.text = myGroup.groupName;
    [groupNameEditableField resignFirstResponder];
    
    // Reset right nav bar item
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    // Reset left nav bar item, but first check if it should be custom button or not
    if (shouldDismissViewController) {
        // So, create a back button that dismisses the view controller entirely
        // Check in GroupDetailsVC to see that calling "dismissGroupViewController" will close the view completely
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"topbigbtn.png"] forState:UIControlStateNormal];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        backButton.titleLabel.shadowColor = [UIColor blackColor];
        backButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [backButton addTarget:self action:@selector(dismissGroupViewController) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:but animated:YES];
        [but release];
        [backButton release];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
}

- (void)deleteGroup {
    UIAlertView *deleteConfirmation = [[UIAlertView alloc] initWithTitle:@"Delete Group?" message:@"Are you sure you want to delete this group? This action cannot be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    deleteConfirmation.tag = TAG_ALERT_CONFIRM_DELETE;
    [deleteConfirmation show];
    [deleteConfirmation release];
}

- (void)toggleNotifications:(id)sender {
    // Set activity indicator in right of navigation bar to show loading
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
    
    UISwitch *theSwitch = (UISwitch *)sender;
    theSwitch.enabled = NO;
    
    [[Groupcentric sharedInstance] togglePushNotificationsForGroup:myGroup.groupId turnOn:theSwitch.isOn result:^(BOOL success, NSError *error) {
        
        self.navigationItem.rightBarButtonItem = nil;
        theSwitch.enabled = YES;
        
        if (success) {
            // Nice!
        } else {
            // Failed, so reset it to its original point
            BOOL resetValue = !theSwitch.isOn;
            [theSwitch setOn:resetValue];
            
            UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"Error Changing Notifications" message:@"Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [failAlert show];
            [failAlert release];
        }
    }];
}

#pragma mark - Keyboard Change

- (void)keyboardWillShow:(NSNotification *)notification {
    [self resizeBottomBarWithOptions:[notification userInfo]];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self resizeBottomBarWithOptions:[notification userInfo]];
}

- (void)resizeBottomBarWithOptions:(NSDictionary *)options {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    CGRect viewFrame = self.view.frame;
    
    CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    viewFrame.size.height =  keyboardFrameEndRelative.origin.y;
    self.view.frame = viewFrame;
    [UIView commitAnimations];
    
    // This function checks if the button selected is the chat button
    [self scrollToBottomAnimated:YES];
    messageText.contentInset = UIEdgeInsetsMake(-5.0f, 0.0f, -3.0f, 0.0f);
    messageText.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if (selectedButton == topChatButton) {
        NSInteger bottomRow = [myGroup.messages count] - 1;
        if (bottomRow >= 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
            [theTableView scrollToRowAtIndexPath:indexPath
                                atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    
    [self updateTextViewContentSize:textView];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    previousContentHeight = 0; // this forces a recalculation upon editing the text view
    
    [self updateTextViewContentSize:textView];
    
}

- (void)updateTextViewContentSize:(UITextView *)textView {
    CGFloat contentHeight = textView.contentSize.height - kMessageFontSize + 6.0f;
    NSString *rightTrimmedText = @"";
    
     //   NSLog(@"content height: %f and %f and %f", contentHeight, previousContentHeight, kContentHeightMax);
    //    NSLog(@"contentOffset: (%f, %f)", textView.contentOffset.x, textView.contentOffset.y);
    //    NSLog(@"contentInset: %f, %f, %f, %f", textView.contentInset.top, textView.contentInset.right,
    //          textView.contentInset.bottom, textView.contentInset.left);
    //    NSLog(@"contentSize.height: %f", contentHeight);
    
    if ([textView hasText]) {
        rightTrimmedText = textView.text;
        
        //if (textView.text.length > 160) { // truncate text to 160 chars
        //    textView.text = [textView.text substringToIndex:160];
        //}
        
        // Resize textView to contentHeight
        if (contentHeight != previousContentHeight) { 
            if (contentHeight <= kContentHeightMax) { // limit chatInputHeight <= 4 lines
               
                CGFloat chatBarHeight = contentHeight + 18.0f;
                
                [self setChatBarHeight:chatBarHeight];
                
                if (previousContentHeight > kContentHeightMax) {
                    textView.scrollEnabled = NO;
                }
                
                textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
                
                [self scrollToBottomAnimated:YES];
                
            } else if (previousContentHeight <= kContentHeightMax) { // grow
                
                textView.scrollEnabled = YES;
                textView.contentOffset = CGPointMake(0.0f, contentHeight-68.0f); // shift to bottom
                if (previousContentHeight < kContentHeightMax) {
                    [self setChatBarHeight:kChatBarHeight4];
                    [self scrollToBottomAnimated:YES];
                }
            }
        }
    } else { // textView is empty
        
        if (previousContentHeight > 22.0f) {
            [self setChatBarHeight:kChatBarHeight1];
            if (previousContentHeight > kContentHeightMax) {
                textView.scrollEnabled = NO;
            }
        }
        
        textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
        
    }
    
    // Enable sendButton if chatInput has non-blank text, disable otherwise.
    if (rightTrimmedText.length > 0 || fromSharedSelector) {
        sendButton.enabled = YES;
    } else {
        sendButton.enabled = NO;
    }
    
    previousContentHeight = contentHeight;
}

// Fix a scrolling quirk.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    textView.contentInset = UIEdgeInsetsMake(-5.0f, 0.0f, -3.0f, 0.0f);
    return YES;
}

- (void)setChatBarHeight:(CGFloat)height {
    
    // Get height including attachments
    CGFloat attachmentHeight = 0;
    if (selectedButton == topChatButton) {
        if (attachingLocation) {
            attachmentHeight = 60;
        } else if (attachingImage) {
            attachmentHeight = 60;
        } else if (fromSharedSelector) {
            attachmentHeight = 60;
        }
    }
    
    CGRect chatContentFrame = theTableView.frame;
    chatContentFrame.size.height = self.view.frame.size.height - (height + attachmentHeight) - 44; // 44 pixels to offet top toggle
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1f];
    theTableView.frame = chatContentFrame;
    messageText.frame = CGRectMake(messageText.frame.origin.x, 9 + attachmentHeight, messageText.frame.size.width, height - 18);
    bottomBar.frame = CGRectMake(bottomBar.frame.origin.x, theTableView.frame.size.height + 44, self.view.frame.size.width, (height + attachmentHeight)); // 44 pixels to offset the top toggle
    bottomMessageBackground.frame = CGRectMake(0, 0, CGRectGetWidth(bottomBar.frame), CGRectGetHeight(bottomBar.frame));
    [UIView commitAnimations];
    
        //NSLog(@"frameheight: %f and height: %f and bottom bar height: %f and attachmenth %f", chatContentFrame.size.height, height, CGRectGetHeight(bottomBar.frame), attachmentHeight);
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Set up left nav button
    UIButton *closeGroupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [closeGroupButton setBackgroundImage:[UIImage imageNamed:@"gc_blankbtn.png"] forState:UIControlStateNormal];
    [closeGroupButton setTitle:@"Cancel" forState:UIControlStateNormal];
    closeGroupButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    closeGroupButton.titleLabel.shadowColor = [UIColor blackColor];
    closeGroupButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [closeGroupButton addTarget:self action:@selector(cancelNameEdit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBut = [[UIBarButtonItem alloc] initWithCustomView:closeGroupButton];
    [self.navigationItem setLeftBarButtonItem:leftBut animated:YES];
    [leftBut release];
    [closeGroupButton release];
    
    // Set up right nav button
    UIButton *saveGroupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [saveGroupButton setBackgroundImage:[UIImage imageNamed:@"gc_blankbtn.png"] forState:UIControlStateNormal];
    [saveGroupButton setTitle:@"Save" forState:UIControlStateNormal];
    saveGroupButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    saveGroupButton.titleLabel.shadowColor = [UIColor blackColor];
    saveGroupButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [saveGroupButton addTarget:self action:@selector(saveGroupName) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithCustomView:saveGroupButton];
    [self.navigationItem setRightBarButtonItem:but animated:YES];
    [but release];
    [saveGroupButton release];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Not necessary at this point
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self saveGroupName];
    
    return YES;
}

#pragma mark - TKContactsMultiPickerControllerDelegate
//for when inviting friends to the group...
- (void)tkPeoplePickerController:(gc_TKPeoplePickerController*)picker didFinishPickingDataWithInfo:(NSArray*)contacts
{
    [self dismissModalViewControllerAnimated:YES];
    
    if ([contacts count]) {
        
        // Get the groupcentric object
        NSMutableArray *friendsToAdd = [[NSMutableArray alloc] init];
        
        // Iterate through the selected friends, and add them to the array
        ABAddressBookRef addressBook = ABAddressBookCreate();
        [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
            
            gc_TKAddressBook *ab = (gc_TKAddressBook*)obj;
            //NSNumber *personID = [NSNumber numberWithInt:ab.recordID];
            //ABRecordID abRecordID = (ABRecordID)[personID intValue];
            //ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);
            
            if (!ab.name || [ab.name length] == 0) {
                NSLog(@"Can't add friend without name");
            } else if (!ab.tel || [ab.tel length] == 0) {
                NSLog(@"Can't add friend without a phone number");
            } else {
                [friendsToAdd addObject:[GCFriend friendWithName:ab.name andPhone:ab.tel andImage:nil]];
            }
            
            [pool drain];
        }];
        
        CFRelease(addressBook);
        
        // Set activity indicator in right of navigation bar to show loading
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [activityIndicator startAnimating];
        UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator release];
        self.navigationItem.rightBarButtonItem = activityItem;
        [activityItem release];
        
        self.title = @"Adding...";
        
        [groupcentric addFriendsToGroup:myGroup.groupId withFriends:friendsToAdd result:^(BOOL success, NSError *error) {
            
            // Show that the API call has ended
            self.navigationItem.rightBarButtonItem = nil;
            self.title = myGroup.groupName;
            
            if (success) {
                
                // Refresh the group to include these new friends
                [self getGroupDetails];
                
            } else {
                if (error) {
                    // Log the error
                    NSLog(@"GroupDetails: Error adding friends: %@", error);
                }
                // Alert the user
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error Adding Friends" message:@"Your friends were not added to this group successfully. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [al show];
                [al release];
                
            }
            
        }];
        
        [friendsToAdd release];
        
    }
    
}

- (void)tkPeoplePickerControllerDidCancel:(gc_TKPeoplePickerController*)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Action Sheet Delegate
//list of objects a user can attach to a message by default
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == TAG_ACTION_UPLOAD_CAMERA) {
        switch (buttonIndex) {
            case 0: {
                // camera
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentModalViewController:imagePicker animated:NO];
                [imagePicker release];
                
                shouldNotReload = YES;
                
                break;
            }
            case 1: {
                // existing
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:imagePicker animated:YES];
                [imagePicker release];
                
                shouldNotReload = YES;
                
                break;
            }
            default:
                break;
        }
        
    } else if (actionSheet.tag == TAG_ACTION_UPLOAD_NO_CAMERA) {
        switch (buttonIndex) {
            case 0: {
                // existing
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:imagePicker animated:YES];
                [imagePicker release];
                
                shouldNotReload = YES;
                
                break;
            }
        }
    } else if (actionSheet.tag == TAG_ACTION_ATTACHMENT_CAMERA) {
        switch (buttonIndex) {
            case 0: {
                // camera
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentModalViewController:imagePicker animated:NO];
                [imagePicker release];
                
                shouldNotReload = YES;
                
                break;
            }
            case 1: {
                // existing
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:imagePicker animated:YES];
                [imagePicker release];
                
                shouldNotReload = YES;
                
                break;
            }
            case 2: {
                // location
                
                [self attachLocation];
                
                break;
            }
            default:
                break;
        }
        
    } else if (actionSheet.tag == TAG_ACTION_ATTACHMENT_NO_CAMERA) {
        switch (buttonIndex) {
            case 0: {
                // existing
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:imagePicker animated:YES];
                [imagePicker release];
                
                shouldNotReload = YES;
                
                break;
            }
            case 1: {
                // location
                
                [self attachLocation];
                
                break;
            }
        }
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_ALERT_CONFIRM_DELETE) {
        if (buttonIndex) {
            [groupcentric removeGroup:myGroup.groupId result:^(BOOL success, NSError *error) {
                if (success) {
                    // Leave the group
                    [self goBack];
                } else {
                    if (error) {
                        // Log the error
                        NSLog(@"GroupDetails: Error deleting group: %@", error);
                    }
                    // Alert the user
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error removing group" message:@"Your group was not removed successfully. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [al show];
                    [al release];
                }
            }];
        }
    }
}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
		case kCLAuthorizationStatusAuthorized:
            locationButton.enabled = YES;
			NSLog(@"kCLAuthorizationStatusAuthorized");
			break;
		case kCLAuthorizationStatusDenied:
        {
            NSLog(@"kCLAuthorizationStatusDenied");
            
            locationButton.enabled = NO;
            /*
             UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Location Access Denied" message:@"You need to enable access to your location. Go into Settings > Location Services to give Groupcentric access to your location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [al show];
             [al release];
             */
        }
			break;
		case kCLAuthorizationStatusNotDetermined:
            locationButton.enabled = YES;
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
            locationButton.enabled = NO;
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // Unable to get the location, so alert the user
    
    if (error.code == kCLErrorDenied) {
        // User denied access to location
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Location Access Denied" message:@"To share your location on Groupcentric, please go to Settings > Privacy > Location and enable access" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
    } else {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Couldn't Find Location" message:@"Your location was not able to be determined." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
    }
    
    locationButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // Got user location
    
    // No need to keep updating. We only update when prompted
    [locationManager stopUpdatingLocation];
    
    // Set button image appropriately
    [locationButton setBackgroundImage:[UIImage imageNamed:@"gc_groupfooter_location_pressed.png"] forState:UIControlStateNormal];
    // Set the attachment
    attachingLocation = YES;
    
    locationButton.enabled = YES;
    
    MKMapView *locationMap = [[[MKMapView alloc] initWithFrame:CGRectMake(CGRectGetMinX(messageText.frame) + 10, 13, 160, 50)] autorelease];
    locationMap.showsUserLocation = YES;
    locationMap.layer.cornerRadius = 5.0f;
    locationMap.tag = TAG_MESSAGE_LOCATION_MAP;
    
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = newLocation.coordinate.latitude;
    newRegion.center.longitude = newLocation.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.005;
    newRegion.span.longitudeDelta = 0.007;
	
    [locationMap setRegion:newRegion animated:YES];
    [bottomBar addSubview:locationMap];
    
    UIButton *deleteButton = [[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(messageText.frame) + 5, 8, 24, 24)] autorelease];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"gc_cancelattachment.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(removeLocationAttachment) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = TAG_MESSAGE_REMOVE_BUTTON;
    [bottomBar addSubview:deleteButton];
    
    [messageText becomeFirstResponder];
    
    // Fix weird bug where doesn't update with no text
    if ([messageText.text length]) {
        previousContentHeight = -9.0f;
    }
    
    [self updateTextViewContentSize:messageText];
    
}

#pragma mark - Image Picker Delegation

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    float actualHeight = img.size.height;
    float actualWidth = img.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 320.0/480.0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 480.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 480.0;
        }
        else{
            imgRatio = 320.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 320.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [img drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (selectedButton == topDetailsButton) {
        // Details are selected, and this means that this photo should be uploaded as the group image
        NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
        
        // setting up the URL to post to
        NSString *urlString = @"http://www.groupcentric.com/mobileImageUpload.ashx";
        
        NSURL *url = [NSURL URLWithString: urlString];
        
        // convert to base64
        const uint8_t* input = (const uint8_t*)[imageData bytes];
        NSInteger length = [imageData length];
        
        static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        
        NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
        uint8_t* output = (uint8_t*)data.mutableBytes;
        
        NSInteger i;
        for (i=0; i < length; i += 3) {
            NSInteger value = 0;
            NSInteger j;
            for (j = i; j < (i + 3); j++) {
                value <<= 8;
                
                if (j < length) {
                    value |= (0xFF & input[j]);
                }
            }
            
            NSInteger theIndex = (i / 3) * 4;
            output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
            output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
            output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
            output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
        }
        // After that magical code created a base64 version of the image, we're ready to send it off
        
        NSString *imageDataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        // Set up the request
        gc_ASIFormDataRequest *request = [gc_ASIFormDataRequest requestWithURL:url];
        
        [request setPostValue:[NSNumber numberWithInt:myGroup.groupId] forKey:@"groupid"];
        [request setPostValue:[NSNumber numberWithInt:groupcentric.userId] forKey:@"userid"];
        [request setPostValue:[NSString stringWithFormat:@"G"] forKey:@"imagetype"];
        [request setPostValue:imageDataString forKey:@"image"];
        
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(uploadRequestFinished:)];
        [request setDidFailSelector:@selector(uploadRequestFailed:)];
        
        [request startAsynchronous];
        
        [imageDataString release];
        
        // Indicate that loading has started
        // Set activity indicator in right of navigation bar to show loading
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [activityIndicator startAnimating];
        UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator release];
        self.navigationItem.rightBarButtonItem = activityItem;
        [activityItem release];
        
        self.title = @"Uploading...";
        
    } else if (selectedButton == topChatButton) {
        [self removePhotoAttachment]; // Remove old photo attachment
        
        // Chat is selected, so this button should be set as the photo in a chat message
        attachingImage = YES;
        
        [imageToAttach release];
        imageToAttach = [image retain];
        
        // Add a preview of the image and a button to remove it to the text field
        UIImageView *imageViewAttached = [[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(messageText.frame) + 10, 13, 50, 50)] autorelease];
        imageViewAttached.clipsToBounds = YES;
        imageViewAttached.contentMode = UIViewContentModeScaleAspectFill;
        imageViewAttached.image = imageToAttach;
        imageViewAttached.tag = TAG_MESSAGE_PHOTO_IMAGE;
        [bottomBar addSubview:imageViewAttached];
        
        UIButton *deleteButton = [[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(messageText.frame) + 5, 8, 24, 24)] autorelease];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"gc_cancelattachment.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(removePhotoAttachment) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = TAG_MESSAGE_REMOVE_BUTTON;
        [bottomBar addSubview:deleteButton];
        
        // After adding an image, you want to start editing the message field to send a message
        
        if ([messageText.text length]) {
            // Reset content height
            previousContentHeight = -8.0f;
        }
        
        [self updateTextViewContentSize:messageText];
        
        sendButton.enabled = YES;
        
        
    }
}


- (void)uploadRequestFinished:(gc_ASIHTTPRequest *)request{
    // Upload finished, check response
    NSString *responseString = [request responseString];
    NSLog(@"Upload response %@", responseString);
    
    // Loading has ended
    self.title = myGroup.groupName;
    self.navigationItem.rightBarButtonItem = nil;
    
    if ([responseString isEqualToString:@"1"]) {
        // Success
        [self getGroupDetails];
    } else {
        
        NSLog(@" Error - Statistics file upload failed: \"%@\"",[[request error] localizedDescription]);
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error uploading your image. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
    }
}

- (void)uploadRequestFailed:(gc_ASIHTTPRequest *)request{
    // Uploading the image failed
    
    NSLog(@" Error - Statistics file upload failed: \"%@\"",[[request error] localizedDescription]);
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error uploading your image. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [al show];
    [al release];
    
}



@end
