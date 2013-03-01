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
//  SignupOrLoginVC.m
//  Groupcentric SDK
//


#import "GCSignupOrLoginVC.h"

@interface GCSignupOrLoginVC ()

@end

@implementation GCSignupOrLoginVC

- (id)initInSignupMode:(BOOL)signingUp {
    if ((self = [super init])) {
        
        // Determines if the screen is for signing up for logging in
        isSigningUp = signingUp;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the navigation bar to a custom image - black header
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"gc_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    // Set up the navigation buttons
    
    // Left button
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
    
    if (isSigningUp) {
        
        // Right button
        UIButton *verifyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
        [verifyButton setBackgroundImage:[UIImage imageNamed:@"gc_blackbtn.png"] forState:UIControlStateNormal];
        [verifyButton setTitle:@"Done" forState:UIControlStateNormal];
        verifyButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        verifyButton.titleLabel.shadowColor = [UIColor blackColor];
        verifyButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [verifyButton addTarget:self action:@selector(continueToVerification) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithCustomView:verifyButton];
        self.navigationItem.rightBarButtonItem = rightBut;
        [rightBut release];
        [verifyButton release];
        
        // Add the custom view created in the nib for signup
        [self.view addSubview:signupView];
        
        // Start editing the name field
        [signupNameField becomeFirstResponder];
        
        self.title = @"Signin";
        
    } else {
        
        // Right button
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"topbigbtn.png"] forState:UIControlStateNormal];
        [loginButton setTitle:@"Login" forState:UIControlStateNormal];
        loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        loginButton.titleLabel.shadowColor = [UIColor blackColor];
        loginButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [loginButton addTarget:self action:@selector(loginFinish) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithCustomView:loginButton];
        self.navigationItem.rightBarButtonItem = rightBut;
        [rightBut release];
        [loginButton release];
        
        // Add the custom view created in the nib for login
        [self.view addSubview:loginView];
        
        // Start editing the phone field
        [loginPhoneField becomeFirstResponder];
        
        self.title = @"Login";
        
    }
    
    signupNameField.tag = 1;
    signupPhoneField.tag = 2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)goBack {
   // [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)forgotPassword {
    // Open the forgot password controller to enter their phone number and be texted a new passcode
    GCForgotPasswordVC *controller = [[GCForgotPasswordVC alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)privacyAndTOS {
    // Open a web browser to view the terms of service and privacy policy
    GCWebBrowserVC *controller = [[GCWebBrowserVC alloc] initWithURLString:@"http://www.groupcentric.com/m/privacytos.html"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)continueToVerification {
    
    // If registering, this will send them to the verification screen to confirm their phone number
    
    if ([signupNameField.text length]) {
        
        // They have filled out their name, now check if they filled out their phone
        if ([signupPhoneField.text length] == 10) {
            
            // Let the user know that the API call has started
            self.title = @"Registering...";
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            // All good to go, so start the signup process by sending the verification number to their phone
            [[Groupcentric sharedInstance] registerStartWithPhone:signupPhoneField.text result:^(BOOL success, NSError *error) {
                
                self.title = @"Register";
                self.navigationItem.rightBarButtonItem.enabled = YES;
                
                if (success) {
                    
                    // The phone number will automatically be stored on the groupcentric object
                    // Save the user's name onto the object
                    [[Groupcentric sharedInstance] setUserFullName:signupNameField.text];
                    
                    // Finish the signup process by confirming the user's phone number
                    GCSignupConfirmationVC *controller = [[GCSignupConfirmationVC alloc] init];
                    [self.navigationController pushViewController:controller animated:YES];
                    [controller release];
                    
                } else {
                    if (error) {
                        NSLog(@"Error: %@", error);
                    }
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error Signing Up" message:@"Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [al show];
                    [al release];
                }
                
            }];
            
            
        } else if ([signupNameField.text length] == 11 && [[signupNameField.text substringToIndex:1] isEqualToString:@"1"]) {
            // User put in leading "1" into their number
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"Please do not include a leading \"1\" in your phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
            
        } else {
            
            // Need to enter a phone number
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"Before registering, please enter a valid phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
        }
        
    } else {
        
        // Need to enter a name
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Please Enter Name" message:@"Before registering, please enter your full name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [al show];
        [al release];
    }
}

- (void)loginFinish {
    
    // If logging in, this will finish the login procedure and send them along to the home screen
    // Let the user know that the API call has started
    self.title = @"Logging in...";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Make the api call
    [[Groupcentric sharedInstance] login:loginPhoneField.text password:loginPasswordField.text result:^(int result, NSError *error) {
        
        // Set nav bar back to default
        self.title = @"Login";
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (result > 0 && !error) {
            // Successful login
            // Result is the user's id
            // Set data and dismiss the view
            [self dismissModalViewControllerAnimated:YES];
            
        } else {
            if (error) {
                // Log the error
                NSLog(@"Groupcentric login error: %@", error);
            }
            
            // Alert of failed login attempt
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please check your credentials and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
        }
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == signupNameField) {
        
        [signupNameField resignFirstResponder];
        [signupPhoneField becomeFirstResponder];
    }
    else
        [textField resignFirstResponder];
	return YES;
}

@end
