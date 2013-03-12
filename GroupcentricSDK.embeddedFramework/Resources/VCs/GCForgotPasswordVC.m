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
//  ForgotPasswordVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>

@interface GCForgotPasswordVC ()

@end

@implementation GCForgotPasswordVC

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
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Forgot Passcode";
    
    // Left button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 31)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"blankbtn.png"] forState:UIControlStateNormal];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    backButton.titleLabel.shadowColor = [UIColor blackColor];
    backButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = but;
    [but release];
    [backButton release];
    
    [phoneField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resendPin {
    // The user has forgotten their password, so resend their pin to their phone number as a text message
    
    // Disable send button to prevent overlapping API calls
    resendButton.enabled = NO;
    
    [[Groupcentric sharedInstance] forgotPasscodeForPhone:phoneField.text result:^(BOOL success, NSError *error) {
        
        // Reenable send button
        resendButton.enabled = YES;
        
        if (success) {
            // The passcode was sent, so send them back, and alert them of the success
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Passcode Sent" message:@"Your passcode was sent to your phone number as a text message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
            [errorAlert release];
            
            [self goBack];
            
        } else {
            // Alert the user
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Passcode Not Sent" message:@"There was an error sending your passcode. Please check your phone number and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
            [errorAlert release];
            
            // Can also log the error
        }
        
    }];
}

@end
