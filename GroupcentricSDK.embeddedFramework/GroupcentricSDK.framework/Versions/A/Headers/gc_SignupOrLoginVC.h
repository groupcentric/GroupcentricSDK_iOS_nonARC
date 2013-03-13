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
//  SignupOrLoginVC.h
//  Groupcentric SDK
//
//  This is the VC for users to signin to GC with their name and phone#

#import <UIKit/UIKit.h>
//#import "AppDelegate.h"
#import "gc_SignupConfirmationVC.h"
#import "gc_ForgotPasswordVC.h"
#import "gc_WebBrowserVC.h"

#import "LocalyticsSession.h"

@interface gc_SignupOrLoginVC : UIViewController {
    
    // YES if user is signing up, NO if user is logging in
    BOOL isSigningUp;
    
    // Outlets for signing up
    IBOutlet UIView *signupView;
    IBOutlet UITextField *signupNameField;
    IBOutlet UITextField *signupPhoneField;
    
    // Outlets for logging in
    IBOutlet UIView *loginView;
    IBOutlet UITextField *loginPhoneField;
    IBOutlet UITextField *loginPasswordField;
}

// Only valid initializer
- (id)initInSignupMode:(BOOL)signingUp;

- (void)goBack; // go back to welcome screen
- (void)continueToVerification; // if registering, this will send them to phone verification
- (void)loginFinish; // if logging in, this will log them in

- (IBAction)forgotPassword; // open up the forgot password screen
- (IBAction)privacyAndTOS; // read the privacy statement and terms of service

@end
