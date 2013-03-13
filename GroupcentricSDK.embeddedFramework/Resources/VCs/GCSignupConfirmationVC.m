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
//  SignupConfirmationVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

@interface GCSignupConfirmationVC ()

@end

@implementation GCSignupConfirmationVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithName:(NSString *)name andPhoneNumber:(NSString *)phone {
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the navigation bar to a custom image
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"gc_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.title = @"Enter PIN";
    
    // Set label for phone number
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    NSMutableString *phoneNumberRaw = [NSMutableString stringWithString:groupcentric.userPhoneNumber];
    
    if ([phoneNumberRaw length] == 10) {
        // Phone in format 5555555555
        [phoneNumberRaw insertString:@"-" atIndex:6];
        [phoneNumberRaw insertString:@") " atIndex:3];
        [phoneNumberRaw insertString:@"(" atIndex:0];
        
        phoneLabel.text = phoneNumberRaw;
    } else {
        phoneLabel.text = @"";
    }
    
    // Left nav button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"gc_blackbtn.png"] forState:UIControlStateNormal];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    backButton.titleLabel.shadowColor = [UIColor blackColor];
    backButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = but;
    [but release];
    [backButton release];
    
    // Right nav button
    UIButton *verifyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [verifyButton setBackgroundImage:[UIImage imageNamed:@"gc_blackbtn.png"] forState:UIControlStateNormal];
    [verifyButton setTitle:@"Verify" forState:UIControlStateNormal];
    verifyButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    verifyButton.titleLabel.shadowColor = [UIColor blackColor];
    verifyButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [verifyButton addTarget:self action:@selector(verifyFinish) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithCustomView:verifyButton];
    self.navigationItem.rightBarButtonItem = rightBut;
    [rightBut release];
    [verifyButton release];
    
    [pinField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)verifyFinish {
    // Make the API call to finish registering this user
    
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    [groupcentric registerFinishWithPhone:groupcentric.userPhoneNumber andUserName:groupcentric.userFullName andPasscode:[pinField.text intValue] result:^(int userIdResult, NSError *error) {
        
        // A successful registration will return a user ID that is greater than 0
        // Any id that is 0 or below will indicate an error
        if (!error && userIdResult > 0) {
            // Success!
            // The user is automatically saved on the Groupcentric object
            // Dismiss the controller to reveal their groups
            
            //[self.navigationController popViewControllerAnimated:YES];
            [self dismissModalViewControllerAnimated:YES];
            
        } else {
            // There was either an error, or the user id returned was not valid
            if (error) {
                NSLog(@"Signup error: %@", error);
            }
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Signing Up" message:@"Please check your credentials and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
            [errorAlert release];
            
        }
    }];
}

- (IBAction)resendPin {
    self.title = @"Sending...";
    
    // All good to go, so start the signup process by sending the verification number to their phone
    Groupcentric *groupcentric = [Groupcentric sharedInstance];
    [groupcentric registerStartWithPhone:groupcentric.userPhoneNumber result:^(BOOL success, NSError *error) {
        
        self.title = @"Enter PIN";
        
        if (success) {
            
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"PIN Sent" message:@"Please check your phone for a text message." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
            
        } else {
            if (error) {
                NSLog(@"Error: %@", error);
            }
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error Resending Pin" message:@"Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
        }
        
    }];
}

- (IBAction)incorrectNumber {
    [self goBack];
}

@end
