//
//  TKNoContactViewController.m
//  Qnote
//
//  Created by Jongtae Ahn on 12. 9. 20..
//  Copyright (c) 2012년 Tabko Inc. All rights reserved.
//

#import "gc_TKNoContactViewController.h"

@interface gc_TKNoContactViewController ()

@end

@implementation gc_TKNoContactViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"All Contacts", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissAction:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    UIAlertView *contactAlert = [[UIAlertView alloc] initWithTitle:@"Contact Access Denied" message:@"To add friends, please go to Settings > Privacy > Contacts and enable access for this app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [contactAlert show];
    [contactAlert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tkNoContactViewControllerDidCancel:)])
        [self.delegate tkNoContactViewControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

@end
