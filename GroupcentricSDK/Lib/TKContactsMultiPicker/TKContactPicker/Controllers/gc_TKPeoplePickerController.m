//
//  TKPeoplePickerController.m
//  Qnote
//
//  Created by Jongtae Ahn on 12. 9. 3..
//  Copyright (c) 2012년 Tabko Inc. All rights reserved.
//

#import "gc_TKPeoplePickerController.h"
#define IOS_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface gc_TKPeoplePickerController ()

- (void)presentNoContactViewController;
- (void)presentContactsMultiPickerController;
- (void)presentContactsMultiPickerWithContacts:(NSArray *)contacts;

@end

@implementation gc_TKPeoplePickerController
@synthesize actionDelegate = _actionDelegate;
@synthesize groupController = _groupController;
@synthesize contactController = _contactController;

#pragma mark -
#pragma mark External contacts changed callback

//void addressBookListenerCallback(ABAddressBookRef abRef, CFDictionaryRef dicRef, void *context);
//void addressBookListenerCallback(ABAddressBookRef abRef, CFDictionaryRef dicRef, void *context)
//{
//    NSLog(@"!!!!! Address Book Changed !!!!!");
//    [ABContactsHelper setAddressBook:abRef];
//    [[(TKPeoplePickerController*)context groupController] reloadData];
//    [[(TKPeoplePickerController*)context contactController] reloadData];
//}

- (void)presentNoContactViewController
{
    gc_TKNoContactViewController *noContactController = [[gc_TKNoContactViewController alloc] initWithNibName:NSStringFromClass([gc_TKNoContactViewController class]) bundle:nil];
    noContactController.delegate = self;
    [self pushViewController:noContactController animated:NO];
    [noContactController release];
}

- (void)presentContactsMultiPickerController
{
    gc_TKContactsMultiPickerController *contactMultiController = [[gc_TKContactsMultiPickerController alloc] initWithNibName:NSStringFromClass([gc_TKContactsMultiPickerController class]) bundle:nil];
    contactMultiController.delegate = self;
    [self pushViewController:contactMultiController animated:NO];
    self.contactController = contactMultiController;
    [contactMultiController release];
}

- (void)presentContactsMultiPickerWithContacts:(NSArray *)contacts
{
    gc_TKContactsMultiPickerController *contactMultiController = [[gc_TKContactsMultiPickerController alloc] initWithSelectedContacts:contacts];
    contactMultiController.delegate = self;
    [self pushViewController:contactMultiController animated:NO];
    self.contactController = contactMultiController;
    [contactMultiController release];
}

- (id)initPeoplePicker
{
    self.groupController = [[[gc_TKGroupPickerController alloc] initWithNibName:NSStringFromClass([gc_TKGroupPickerController class]) bundle:nil] autorelease];
    self.groupController.delegate = self;
    self = [super initWithRootViewController:self.groupController];
    if (self) {
        if (!IOS_VERSION_LESS_THAN(@"6.0")) {
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            switch (ABAddressBookGetAuthorizationStatus()) {
                case kABAuthorizationStatusNotDetermined: {
                    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                        if (granted) {
                            [self presentContactsMultiPickerController];
                        } else {
                            [self presentNoContactViewController];
                        }
                    });
                } break;
                case kABAuthorizationStatusAuthorized: {
                    [self presentContactsMultiPickerController];
                } break;
                case kABAuthorizationStatusDenied: {
                    [self presentNoContactViewController];
                } break;
                case kABAuthorizationStatusRestricted: {
                    [self presentNoContactViewController];
                } break;
                    
                default: {
                } break;
            }
        } else {
            [self presentContactsMultiPickerController];
        }
    }
    
    return self;
}

- (id)initPeoplePickerWithContacts:(NSArray *)contacts {
    self.groupController = [[[gc_TKGroupPickerController alloc] initWithNibName:NSStringFromClass([gc_TKGroupPickerController class]) bundle:nil] autorelease];
    self.groupController.delegate = self;
    self = [super initWithRootViewController:self.groupController];
    if (self) {
        if (!IOS_VERSION_LESS_THAN(@"6.0")) {
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            switch (ABAddressBookGetAuthorizationStatus()) {
                case kABAuthorizationStatusNotDetermined: {
                    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                        if (granted) {
                            [self presentContactsMultiPickerWithContacts:contacts];
                        } else {
                            [self presentNoContactViewController];
                        }
                    });
                } break;
                case kABAuthorizationStatusAuthorized: {
                    [self presentContactsMultiPickerWithContacts:contacts];
                } break;
                case kABAuthorizationStatusDenied: {
                    [self presentNoContactViewController];
                } break;
                case kABAuthorizationStatusRestricted: {
                    [self presentNoContactViewController];
                } break;
                    
                default: {
                } break;
            }
        } else {
            [self presentContactsMultiPickerController];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_groupController release];
    [_contactController release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    ABAddressBookRegisterExternalChangeCallback([ABContactsHelper addressBook], addressBookListenerCallback, self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    ABAddressBookUnregisterExternalChangeCallback([ABContactsHelper addressBook], addressBookListenerCallback, self);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveAction:(NSArray*)data
{
    if ([self.actionDelegate respondsToSelector:@selector(tkPeoplePickerController:didFinishPickingDataWithInfo:)])
        [self.actionDelegate tkPeoplePickerController:self didFinishPickingDataWithInfo:data];
}

- (void)dismissAction
{
    if ([self.actionDelegate respondsToSelector:@selector(tkPeoplePickerControllerDidCancel:)])
        [self.actionDelegate tkPeoplePickerControllerDidCancel:self];
}

#pragma mark -
#pragma mark TKNoContactViewControllerDelegate

- (void)tkNoContactViewControllerDidCancel:(gc_TKNoContactViewController *)picker
{
    [self dismissAction];
}

#pragma mark -
#pragma mark TKGroupPickerControllerDelegate

- (void)tkGroupPickerControllerDidCancel:(gc_TKGroupPickerController *)picker
{
    [self dismissAction];
}

#pragma mark -
#pragma mark TKContactsMultiPickerControllerDelegate

- (void)tkContactsMultiPickerController:(gc_TKContactsMultiPickerController *)picker didFinishPickingDataWithInfo:(NSArray *)contacts
{
    [self saveAction:contacts];
}

- (void)tkContactsMultiPickerControllerDidCancel:(gc_TKContactsMultiPickerController *)picker
{
    [self dismissAction];
}

@end
