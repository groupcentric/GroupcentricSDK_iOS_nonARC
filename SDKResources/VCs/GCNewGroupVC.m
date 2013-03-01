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
//  NewGroupVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

@implementation GCNewGroupVC

#define TAG_ALERT_VIEW_CANCEL 10
#define TAG_TITLE_TEXT_FIELD 20
#define TAG_MESSAGE_TEXT_VIEW 21

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithSharedObject:(GCSharedObject *)sharedObj {
    if ((self = [super init])) {
        sharedObject = [[GCSharedObject alloc]initWithContent:sharedObj.type withTitle:sharedObj.varTitle withSubtitle:sharedObj.varSubtitle withImageURL:sharedObj.imageURL withURL:sharedObj.varURL withDate:sharedObj.varDateString withDetails:sharedObj.varDetails withMarkup:sharedObj.varMarkup];
        fromSharedSelector = true;
        
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
    // Do any additional setup after loading the view from its nib.

    
    // Set up the table to offset the size of the keyboard
    theTableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 216);
    
    // Set up the group title text field
    titleText = [[UITextField alloc] initWithFrame:CGRectMake(8, 15, 300, 31)];
	titleText.delegate = self;
    titleText.font = [UIFont systemFontOfSize:16];
	titleText.returnKeyType = UIReturnKeyNext;
	titleText.textAlignment = UITextAlignmentLeft;
	titleText.placeholder = @"Title";
    
    // set up the object being shared if thats the case
    sharedTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, 15, 300, 31)];
    sharedTitle.numberOfLines = 0;
    sharedTitle.backgroundColor = [UIColor clearColor];
    sharedTitle.font = [UIFont boldSystemFontOfSize:16];
    sharedTitle.textAlignment = UITextAlignmentLeft;
    sharedTitle.textColor = [UIColor colorWithRed:0.0f/256.0f green:51.0f/256.0f blue:102.0f/256.0f alpha:1.0];
    
    // Set up the group message text field
    messageText = [[UITextView alloc] initWithFrame:CGRectMake(0, 2, 320, CGRectGetHeight(self.view.frame) - 52 - 52 - 216)];
	messageText.delegate = self;
    messageText.font = [UIFont systemFontOfSize:16];
    messageText.backgroundColor = [UIColor clearColor];
	messageText.returnKeyType = UIReturnKeyDefault;
    messageText.textColor = [UIColor darkGrayColor]; // Make text look like placeholder text
    messageText.text = @"Message";
    
    // Set up the label of friend names
    // We want to display friend names, but when calling the API we are only concerned with the friend phone numbers
    friendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 16, 200, 20)];
    friendsLabel.numberOfLines = 0;
    friendsLabel.backgroundColor = [UIColor clearColor];
    friendsLabel.font = [UIFont boldSystemFontOfSize:16];
    friendsLabel.textColor = [UIColor colorWithRed:0.0f/256.0f green:51.0f/256.0f blue:102.0f/256.0f alpha:1.0];
    
    // Initialize the array of friends in the group
    friendsTable = [[NSMutableArray alloc] init];
    
    // Set up the navigation bar
    // Set the navigation bar to a custom image
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"gc_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    self.title = @"New Group";
    
    // Set up right nav button
    UIButton *saveGroupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [saveGroupButton setBackgroundImage:[UIImage imageNamed:@"gc_blackbtn.png"] forState:UIControlStateNormal];
    [saveGroupButton setTitle:@"Start" forState:UIControlStateNormal];
    saveGroupButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    saveGroupButton.titleLabel.shadowColor = [UIColor blackColor];
    saveGroupButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [saveGroupButton addTarget:self action:@selector(startGroup) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithCustomView:saveGroupButton];
    self.navigationItem.rightBarButtonItem = but;
    [but release];
    [saveGroupButton release];
    
    // Set up left nav button
    UIButton *closeGroupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [closeGroupButton setBackgroundImage:[UIImage imageNamed:@"gc_blackbtn.png"] forState:UIControlStateNormal];
    [closeGroupButton setTitle:@"Close" forState:UIControlStateNormal];
    closeGroupButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    closeGroupButton.titleLabel.shadowColor = [UIColor blackColor];
    closeGroupButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [closeGroupButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBut = [[UIBarButtonItem alloc] initWithCustomView:closeGroupButton];
    self.navigationItem.leftBarButtonItem = leftBut;
    [leftBut release];
    [closeGroupButton release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {    
    [titleText release];
    [messageText release];
    [friendsLabel release];
    [friendsTable release];
    
    [super dealloc];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // For the first row, it's simply the textfield and image, so the height will be static
    if (indexPath.section == 0) {
        return 52.0;
    }
    
    // For the second row, the cell should fit the size of the friend label
    if (indexPath.section == 1) {
        if ([friendsTable count]) {
            
            // If there are friends in the plan, use the frame height. The frame height of one line of text is 20, and we want it match at 52 pixels for a single line
            return friendsLabel.frame.size.height + 32;
            
        } else {
            
            // If there are no friends in the plan, let's just set it at 52
            return 52.0;
            
        }
        
    }
    
    // Last row is the message row, which should be the height of the message text view
    //if (messageText.frame.size.height == 20) {
    //    return self.view.frame.size.height - 52 - 52 - 216;
        
    //}
    return messageText.frame.size.height + 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCellID = @"messageCellID";
    static NSString *inputCellID = @"inputCellID";
    static NSString *friendsCellID = @"friendsCellID";
    
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:inputCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inputCellID] autorelease];
            
            if(fromSharedSelector)
            {
                UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 32)];
                NSString *sharetit = @"Sharing: ";
                sharetit = [sharetit stringByAppendingString:sharedObject.varTitle];
                lab.text = sharetit;
                
                lab.backgroundColor = [UIColor clearColor];
                lab.font = [UIFont systemFontOfSize:15];
                lab.textColor = [UIColor lightGrayColor];
                lab.highlightedTextColor = [UIColor whiteColor];
                [cell.contentView addSubview:lab];
                [lab release];
            }
            else{
                [cell.contentView addSubview:titleText];
                [titleText becomeFirstResponder];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:friendsCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendsCellID] autorelease];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 65, 32)];
            lab.text = @"Friends:";
            lab.backgroundColor = [UIColor clearColor];
            lab.font = [UIFont systemFontOfSize:17];
            lab.textColor = [UIColor lightGrayColor];
            lab.highlightedTextColor = [UIColor whiteColor];
            [cell.contentView addSubview:lab];
            [lab release];
            
            UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(287, 14, 25, 25)];
            [but setImage:[UIImage imageNamed:@"gc_plusbtn.png"] forState:UIControlStateNormal];
            [but addTarget:self action:@selector(pickFriends) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:but];
            [but release];
            
            [cell.contentView addSubview:friendsLabel];
        }
        
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:messageCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCellID] autorelease];
            
            [cell.contentView addSubview:messageText];
                        
        }
                
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        [self pickFriends];
    } else if (indexPath.section == 2) {
        
    }
    
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == titleText) {
        [messageText becomeFirstResponder];
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
}

#pragma mark - Text View Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == [UIColor darkGrayColor]) {
        
        // Text is being edited for the first time, so remove the pseudo-placeholder that was in there.
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
}

#pragma mark - Actions

- (void)pickFriends {
    
    if ([friendsTable count]) {
        
        // If there are already friends to add, make sure you include them as preselected in the contacts picker
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        for (GCFriend *friend in friendsTable) {
            [tempArray addObject:friend.phone];
        }
        
        gc_TKPeoplePickerController *controller = [[[gc_TKPeoplePickerController alloc] initPeoplePickerWithContacts:[NSArray arrayWithArray:tempArray]] autorelease];
        controller.actionDelegate = self;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:controller animated:YES];
        
    } else {
        
        // Otherwise, just open the contacts picker blank
        gc_TKPeoplePickerController *controller = [[[gc_TKPeoplePickerController alloc] initPeoplePicker] autorelease];
        controller.actionDelegate = self;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:controller animated:YES];
        
    }
}

- (void)reloadTheTableAnimated {
    //[theTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [theTableView reloadData];
}

- (void)close {
    if ([titleText.text length] || [friendsTable count]) {
        // If they've started entering stuff into the group, then prompt them with a confirmation
        
        UIAlertView *confirmCancelAlert = [[UIAlertView alloc] initWithTitle:@"Cancel Group?" message:@"Your group has not been created yet, and your changes will not be saved." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        confirmCancelAlert.tag = TAG_ALERT_VIEW_CANCEL;
        [confirmCancelAlert show];
        [confirmCancelAlert release];
        
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)startGroup {
    NSString *titleRaw = [titleText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([titleRaw length] || fromSharedSelector) {
        
        // Make the API call
        // If there's an image to upload, this should only be called after the image has been uploaded successfully
                
        // Let's set up the title and message variables
        // Keep in mind, if the message text has a text color of [UIColor darkGrayColor], then it hasn't been edited and should be considered a placeholder
        NSString *groupTitle = @"";
        if(!fromSharedSelector)
            groupTitle = titleText.text;
        
        NSString *groupMessage = messageText.text;
        if (messageText.textColor == [UIColor darkGrayColor]) {
            groupMessage = @"";
        }
        NSString *groupImage = @""; // could add an image url, but we're keeping it simple for now. uses a mash of the friends profile pics as default kinda cul
        if(fromSharedSelector)
        {
            GCObject *obj = [[GCObject alloc] init];
            obj.type = sharedObject.type;
            obj.varTitle = sharedObject.varTitle;
            obj.varSubtitle = sharedObject.varSubtitle;
            obj.imageURL = sharedObject.imageURL;
            obj.var1 = sharedObject.varURL;
            obj.varDateString = sharedObject.varDateString;
            NSString *tmp = [sharedObject.varDetails stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
            tmp = [tmp stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
            obj.varDetails = tmp;
            
            NSString *tmpM = [sharedObject.varMarkup stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
            tmpM = [tmpM stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
            tmpM = [tmpM stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
            obj.varMarkup = tmpM;
            
       
            [[Groupcentric sharedInstance] startGroupWithTitle:groupTitle andImage:groupImage andMessage:groupMessage andContacts:friendsTable andObject:obj result:^(GCGroup *group, NSError *error) {
                if (!error) {
                    // Success
                    [self openNewGroupDetails:group];
                     
                } else {
                    // Log the details of the error
                    NSLog(@"%@ %@", error, [error userInfo]);
                }
                [obj release];
            }];
        }
        else{
            [[Groupcentric sharedInstance] startGroupWithTitle:groupTitle andImage:groupImage andMessage:groupMessage andContacts:friendsTable result:^(GCGroup *group, NSError *error) {
                if (!error) {
                    // Success
                    [self openNewGroupDetails:group];
                    
                } else {
                    // Log the details of the error
                    NSLog(@"%@ %@", error, [error userInfo]);
                }
            }];
        }
        
    } else {
        // Alert them to enter a title
        UIAlertView *noTitleAlert = [[UIAlertView alloc] initWithTitle:@"Please Enter Title" message:@"A title is required to start a group." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noTitleAlert show];
        [noTitleAlert release];
        
        // Start entering text in the title
        [titleText becomeFirstResponder];
    }
}

- (void)openNewGroupDetails:(GCGroup *)group {
    
    // Now that the group is saved, show the new group details
    GCGroupDetailsVC *controller = [[GCGroupDetailsVC alloc] initWithGroup:group andShouldDismissModalViewController:YES];
    // We don't want the user going back to the NewGroupVC after the group has been created
        
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_ALERT_VIEW_CANCEL) {
        // This is deciding whether or not to cancel the creation of a group and close the screen
        
        if (buttonIndex == 1) {
            // Cancel, and dismiss the view controller
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

#pragma mark - TKContactsMultiPickerControllerDelegate

- (void)tkPeoplePickerController:(gc_TKPeoplePickerController*)picker didFinishPickingDataWithInfo:(NSArray*)contacts
{
    [self dismissModalViewControllerAnimated:YES];
    
    // Get ride of the old added friends
    [friendsTable removeAllObjects];
    
    // Iterate through the selected friends, and add them to the array
    ABAddressBookRef addressBook = ABAddressBookCreate();
    [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        
        gc_TKAddressBook *ab = (gc_TKAddressBook*)obj;
        
        if (!ab.name || [ab.name length] == 0) {
            NSLog(@"Can't add friend without name");
        } else if (!ab.tel || [ab.tel length] == 0) {
            NSLog(@"Can't add friend without a phone number");
        } else {
            [friendsTable addObject:[GCFriend friendWithName:ab.name andPhone:ab.tel andImage:nil]];
        }
        
        [pool drain];
    }];
    
    CFRelease(addressBook);
    
    
    // Now that the friends have been added, we need to update the sizes of our labels and text views
    
    // First, update the friend label
    if ([friendsTable count]) {

        // Create string of friend names
		NSMutableString *fids = [[NSMutableString alloc] init];
		for (GCFriend *friendEntry in friendsTable) {
			[fids appendString:friendEntry.name];
			[fids appendString:@", "];
		}
        
		if ([fids length]) {
            // Trim off the last ", "
			[fids deleteCharactersInRange:NSMakeRange([fids length] - 2, 2)];
		}
        
        friendsLabel.text = fids;
        
        [fids release];
        
        CGSize textViewSize = [friendsLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
                               
        friendsLabel.frame = CGRectMake(80, 16, 200, textViewSize.height);
        
    } else {
        
        // reset friendsLabel frame
        friendsLabel.frame = CGRectMake(80, 16, 200, 20);
    }
    
    // Now let's update the text view
    if (self.view.frame.size.height - friendsLabel.frame.size.height - 32 - 52 - 216 < 50) {
        
        // We want the message field to fill blank space at the bottom, but only if there is enough room to fit at least 50 pixels in
        messageText.frame = CGRectMake(0, 0, 320, 50);
        
    } else {
        
        // Otherwise, to fill last cell, subtract friend size, title cell size, keyboard size, and edge insets
        messageText.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - friendsLabel.frame.size.height - 32 - 52 - 216);
        
    }
    
    [self reloadTheTableAnimated];
    
    if (![titleText.text length]) {
        [titleText becomeFirstResponder];
    } else {
        [messageText becomeFirstResponder];
    }
}

- (void)tkPeoplePickerControllerDidCancel:(gc_TKPeoplePickerController*)picker
{
    [self dismissModalViewControllerAnimated:YES];
}



@end
