//
//  TKGroupPickerController.m
//  Thumb+
//
//  Created by Jongtae Ahn on 12. 9. 1..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import "gc_TKPeoplePickerController.h"
#import "gc_TKGroupPickerController.h"
#import "gc_TKContactsMultiPickerController.h"

@interface gc_TKGroupPickerController ()

@end

@implementation gc_TKGroupPickerController
@synthesize groups = _groups;

- (void)reloadGroups
{

}

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Groups", nil);
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissAction:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"All Contacts", nil);
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    gc_TKPeoplePickerController *peoplePicker = (gc_TKPeoplePickerController*)self.navigationController;
    gc_TKContactsMultiPickerController *controller = [[gc_TKContactsMultiPickerController alloc] initWithNibName:NSStringFromClass([gc_TKContactsMultiPickerController class]) bundle:nil];
    [controller setDelegate:peoplePicker];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark -
#pragma mark Barbutton action

- (IBAction)addGroup:(id)sender
{

}

- (IBAction)dismissAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tkGroupPickerControllerDidCancel:)])
        [self.delegate tkGroupPickerControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (void)dealloc
{
    [_groups release];
    [_tableView release];
	[super dealloc];
}

@end
