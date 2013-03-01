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
//  WebBrowserVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>


@implementation GCWebBrowserVC

@synthesize theWeb;

- (id)initWithURLString:(NSString *)url {
    if ((self = [super init])) {
        urlString = [url retain];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [theWeb release];
    [urlString release];
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
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if(!ok) { NSLog(@"%s setCategoryError=%@",__PRETTY_FUNCTION__, setCategoryError);
    }
    
    
    
    theWeb.delegate = self;
    // Do any additional setup after loading the view from its nib.
    
    NSURL *_url = [NSURL URLWithString:urlString];
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
    //Load the request in the UIWebView.
    [theWeb loadRequest:requestObj];
    
    //self.title = @"Loading...";
    CGRect frame = CGRectMake(0,2,200,44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.shadowColor =  [UIColor colorWithWhite:0.0 alpha:0.2];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[[UIColor alloc] initWithRed:49.0f/255.0f green:112.0f/255.0f blue:98.0f/255.0f alpha:1.0];
    label.text = @"Loading...";
    self.navigationItem.titleView = label;
    [label release];
    
    // Left button
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.theWeb = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Web View

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // Set activity indicator in the right of navigation bar
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //self.title = [theWeb stringByEvaluatingJavaScriptFromString:@"document.title"];
    CGRect frame = CGRectMake(0,2,200,44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    /*label.shadowColor =  [UIColor colorWithWhite:0.0 alpha:0.2];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[[UIColor alloc] initWithRed:49.0f/255.0f green:112.0f/255.0f blue:98.0f/255.0f alpha:1.0];*/
    label.shadowColor =  [[UIColor alloc] initWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    
    label.text = [theWeb stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.titleView = label;
    [label release];
    
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.navigationItem.rightBarButtonItem = nil;
    self.title = @"Error loading page";
    
    // Could also use alert view for user, or log the error
}

#pragma mark - Actions

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)otherAction {
	UIActionSheet *manageActionSheet = [[UIActionSheet alloc]
										initWithTitle:nil
										delegate:self
										cancelButtonTitle:@"Cancel"
										destructiveButtonTitle:nil
										otherButtonTitles:	@"Open in Safari",
										nil];
	
    manageActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[manageActionSheet showInView:self.view];
	[manageActionSheet release];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex)
	{
		case 0:
		{
			[[UIApplication sharedApplication] openURL:theWeb.request.URL];
			break;
		}
		default:
		{
			break;
		}
	}
}

@end
