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
//  GCMapVC.m
//  Groupcentric SDK
//


#import <GroupcentricSDK/GroupcentricSDK.h>


@implementation GCMapVC

@synthesize theMap;
@synthesize locationManager;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(id)initWithLatitude:(double)lat andLongitude:(double)lon {
	if ((self = [self init])) {
        theLat = lat;
        theLong = lon;
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//self.title = @"Map";
    CGRect frame = CGRectMake(0,2,200,44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14.0];
    /*label.shadowColor =  [UIColor colorWithWhite:0.0 alpha:0.2];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[[UIColor alloc] initWithRed:49.0f/255.0f green:112.0f/255.0f blue:98.0f/255.0f alpha:1.0];*/
    label.shadowColor =  [[UIColor alloc] initWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    
    label.text = @"Map";
    self.navigationItem.titleView = label;
    [label release];
    
	MKCoordinateRegion newRegion;
    newRegion.center.latitude = theLat;
    newRegion.center.longitude = theLong;
    newRegion.span.latitudeDelta = 0.005;
    newRegion.span.longitudeDelta = 0.007;
	
    [theMap setRegion:newRegion animated:YES];
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location-white.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(action:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	MKPlacemark *pin = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(theLat, theLong) addressDictionary:nil];
	[theMap addAnnotation:pin];
	[pin release];
	
    // Set left nav button
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
	
    [super viewDidLoad];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	NSLog(@"Location found");
	
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(action:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	location = newLocation.coordinate;
	MKCoordinateRegion region;
	region.center = location;
	region.span.latitudeDelta = 0.002849;
	region.span.longitudeDelta = 0.0031025;
	[theMap setRegion:region animated:YES];
	theMap.showsUserLocation = YES;
	[locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location-white.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(action:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Finding Location" message:@"Your location was unable to be determined. Please check your internet connection or network settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	NSLog(@"Location manager error");
	[locationManager stopUpdatingLocation];
}

- (void)action:(id)sender
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
    
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.locationManager = nil;
	self.theMap = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[locationManager release];
	[theMap release];
    [super dealloc];
}


@end
