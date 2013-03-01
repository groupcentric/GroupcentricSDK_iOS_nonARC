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
//  gc_ProfileVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

#define PROFILE_TOP_IMAGE_HEIGHT 119
#define PROFILE_USER_IMAGE_HEIGHT 64

#define TAG_PROFILE_IMAGE 10
#define TAG_PROFILE_NAME_LABEL 11

#define TAG_ACTION_UPLOAD_CAMERA 20
#define TAG_ACTION_UPLOAD_NO_CAMERA 21

@interface GCProfileVC ()

@end

@implementation GCProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the navigation bar to a custom image
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"gc_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
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
    
    self.title = @"My Groupcentric Profile";
    
    // Set up table view parameters
    theTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTableView.backgroundColor = [UIColor clearColor];
    //theTableView.contentInset = UIEdgeInsetsMake(5, 0, 10, 0); // add insets for nicer spacing, and for dealing with overlapping bottom button
    
    // Check to see if there is a logged in user. If not, show the login/signup screen
    // Lack of user id indicates no user
    // ID less than 1 indicates an error in the signup process
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    
    
}

- (void)uploadUserImage {
    
    // Upload a photo as a new user image
    // Check if there is a camera available, and present an action sheet
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
        ac.tag = TAG_ACTION_UPLOAD_CAMERA;
        [ac showInView:self.view];
        [ac release];
    } else {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing", nil];
        ac.tag = TAG_ACTION_UPLOAD_NO_CAMERA;
        [ac showInView:self.view];
        [ac release];
    }
}

- (void)logout {
    // Logout of the groupcentric object
    [[Groupcentric sharedInstance] logout];
    [self close];
   
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getProfile];
}

- (void)getProfile {
    [[Groupcentric sharedInstance] getProfile:^(BOOL success, NSError *error) {
        if (success) {
            // Profile loaded successfully
            // Refresh if profile is shown
            [theTableView reloadData];
            
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
            // Top of the profile, includes a cover photo, user image, and name
            return PROFILE_TOP_IMAGE_HEIGHT + (PROFILE_USER_IMAGE_HEIGHT / 2) + 5;
    }
        // The profile view should be one cell containing a web view that fills the table
    return 50.0;
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Cell id for profile title
    static NSString *profileTitleID = @"profileTitleID";
    // Cell id for profile details
    static NSString *profileDetailsID = @"profileDetailsID";
    
    
        // This should be the profile view
        
        UITableViewCell *cell;
        
       
            
            if (indexPath.row == 0) {
                // Title
                cell = [tableView dequeueReusableCellWithIdentifier:profileTitleID];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileTitleID] autorelease];
                    
                    // Add the background images
                    UIImageView *backgroundHeaderImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, PROFILE_TOP_IMAGE_HEIGHT)];
                    backgroundHeaderImage.image = [UIImage imageNamed:@"gc_profiletop.png"];
                    backgroundHeaderImage.contentMode = UIViewContentModeCenter;
                    backgroundHeaderImage.clipsToBounds = YES;
                    [cell.contentView addSubview:backgroundHeaderImage];
                    
                    // Add user image
                    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, PROFILE_TOP_IMAGE_HEIGHT - (PROFILE_USER_IMAGE_HEIGHT / 2), PROFILE_USER_IMAGE_HEIGHT, PROFILE_USER_IMAGE_HEIGHT)];
                    userImage.tag = TAG_PROFILE_IMAGE;
                    userImage.layer.cornerRadius = (float)(PROFILE_USER_IMAGE_HEIGHT / 2);
                    userImage.layer.borderColor = [[UIColor whiteColor] CGColor];
                    userImage.layer.borderWidth = 4.0f;
                    userImage.clipsToBounds = YES;
                    userImage.image = [UIImage imageNamed:@"gc_blankuser.png"];
                    userImage.contentMode = UIViewContentModeScaleAspectFill;
                    [cell.contentView addSubview:userImage];
                    
                    // Add a camera icon to indicate the user can change their profile image
                    UIImageView *cameraIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(userImage.frame) + 5, CGRectGetMaxY(userImage.frame) - 22, 19, 16)] autorelease];
                    cameraIcon.image = [UIImage imageNamed:@"gc_profilecameraicon.png"];
                    [cell.contentView addSubview:cameraIcon];
                    
                    // Add a blank button for editing the image
                    UIButton *editButton = [[UIButton alloc] initWithFrame:userImage.frame];
                    [editButton addTarget:self action:@selector(uploadUserImage) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:editButton];
                    
                    // Add background image for name label
                    UIImageView *backName = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userImage.frame) + 10, CGRectGetMaxY(backgroundHeaderImage.frame) + 4, 220, 29)];
                    backName.image = [UIImage imageNamed:@"gc_profilenamebg.png"];
                    [cell.contentView addSubview:backName];
                    
                    // Add user name label
                    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(backName.frame) + 10, CGRectGetMinY(backName.frame), 200, 29)];
                    userName.textColor = [UIColor blackColor];
                    userName.backgroundColor = [UIColor clearColor];
                    userName.font = [UIFont boldSystemFontOfSize:17];
                    userName.tag = TAG_PROFILE_NAME_LABEL;
                    [cell.contentView addSubview:userName];
                    
                    [backgroundHeaderImage release];
                    [userImage release];
                    [editButton release];
                    [backName release];
                    [userName release];
                    
                    // No other cell characteristics should be shown
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                // Recheck title and image for updating
                // This should be saved directly on the Groupcentric object
                Groupcentric *groupcentric = [Groupcentric sharedInstance];
                
                UIImageView *usrImg = (UIImageView *)[cell.contentView viewWithTag:TAG_PROFILE_IMAGE];
                if ([groupcentric.userProfileImage length]) {
                    // Check for user profile image. If GetProfile hasn't been called yet, the image will not be saved
                    [usrImg setImageWithURL:[NSURL URLWithString:groupcentric.userProfileImage] placeholderImage:[UIImage imageNamed:@"gc_blankuser.png"]];
                }
                
                UILabel *usrNm = (UILabel *)[cell.contentView viewWithTag:TAG_PROFILE_NAME_LABEL];
                usrNm.text = groupcentric.userFullName;
                
            } else {
                // Details
                cell = [tableView dequeueReusableCellWithIdentifier:profileDetailsID];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:profileDetailsID] autorelease];
                    
                    // No other cell characteristics should be shown
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                if (indexPath.row == 1) {
                    cell.textLabel.text = @"Settings";
                    cell.detailTextLabel.text = @"Name, Profile, Password, Picture";
                    cell.imageView.image = [UIImage imageNamed:@"gc_settingsicon.png"];
                    
                    cell.textLabel.textAlignment = UITextAlignmentLeft;
                    
                } else if (indexPath.row == 2) {
                    cell.textLabel.text = @"Feedback";
                    cell.detailTextLabel.text = @"Tell us what you really think";
                    cell.imageView.image = [UIImage imageNamed:@"gc_feedbackicon.png"];
                    
                    cell.textLabel.textAlignment = UITextAlignmentLeft;
                    
                } else if (indexPath.row == 3) {
                    cell.textLabel.text = @"About";
                    cell.detailTextLabel.text = @"Oh just a little something about us";
                    cell.imageView.image = [UIImage imageNamed:@"gc_abouticon.png"];
                    
                    cell.textLabel.textAlignment = UITextAlignmentLeft;
                    
                } else if (indexPath.row == 4) {
                    cell.textLabel.text = @"TOS / Privacy";
                    cell.detailTextLabel.text = @"Some light Sunday reading";
                    cell.imageView.image = [UIImage imageNamed:@"gc_privacyicon.png"];
                    
                    cell.textLabel.textAlignment = UITextAlignmentLeft;
                    
                } else if (indexPath.row == 5) {
                    cell.textLabel.text = @"Logout";
                    cell.detailTextLabel.text = nil;
                    cell.imageView.image = nil;
                    
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    
                }
                
            }
            
            NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"gc_cell-back" ofType:@"png"];
            UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
            cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            return cell;
            
        
    
    
    
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        // Open appropriate web page for settings
        NSString *link = @"";
    
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    int userId = groupcentric.userId;
    
        if (indexPath.row == 1) {
            // settings
            
            link = [NSString stringWithFormat:@"%@%@", @"http://www.groupcentric.com/m/profile.html?uid=", [NSString stringWithFormat:@"%d",userId]];
        } else if (indexPath.row == 2) {
            // feedback
            link = [NSString stringWithFormat:@"%@%@", @"http://www.groupcentric.com/m/feedback.html?uid=", [NSString stringWithFormat:@"%d",userId]];
        } else if (indexPath.row == 3) {
            // about
            link = @"http://groupcentric.com/m/about.html";
        } else if (indexPath.row == 4) {
            // tos/privacy
            link = @"http://groupcentric.com/m/privacytos.html";
        } else if (indexPath.row == 5) {
            // Logout
            [self logout];
        }
        
        if ([link length]) {
            // Open web browser
            GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:link];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
        
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Sheet Delegate

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
                
                break;
            }
            case 1: {
                // existing
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:imagePicker animated:YES];
                [imagePicker release];
                
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
                
                break;
            }
        }
    }
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
    
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    [request setPostValue:[NSNumber numberWithInt:groupcentric.userId] forKey:@"userid"];
    [request setPostValue:[NSString stringWithFormat:@"U"] forKey:@"imagetype"];
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
}


- (void)uploadRequestFinished:(gc_ASIHTTPRequest *)request{
    // Upload finished, check response
    NSString *responseString = [request responseString];
    NSLog(@"Upload response %@", responseString);
    
    // Loading has ended
    
    self.navigationItem.rightBarButtonItem = nil;
    
    if ([responseString isEqualToString:@"1"]) {
        // Success
        [self getProfile];
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
