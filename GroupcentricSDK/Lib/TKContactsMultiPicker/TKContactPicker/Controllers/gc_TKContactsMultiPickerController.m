//
//  gc_TKContactsMultiPickerController.m
//  gc_TKContactsMultiPicker
//
//  Created by Jongtae Ahn on 12. 8. 31..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import "gc_TKContactsMultiPickerController.h"
#import "gc_NSString+TKUtilities.h"
#import "gc_UIImage+TKUtilities.h"

@interface gc_TKContactsMultiPickerController(PrivateMethod)

- (IBAction)doneAction:(id)sender;
- (IBAction)dismissAction:(id)sender;

@end

@implementation gc_TKContactsMultiPickerController
@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize searchWasActive = _searchWasActive;
@synthesize searchBar = _searchBar;

#pragma mark -
#pragma mark Create addressbook ref

- (void)reloadAddressBook
{
    // Create addressbook data model
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    ABAddressBookRef addressBooks = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    
    for (NSInteger i = 0; i < nPeople; i++)
    {
        gc_TKAddressBook *addressBook = [[gc_TKAddressBook alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        CFStringRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFStringRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        
        /*
         Save thumbnail image - performance decreasing
         UIImage *personImage = nil;
         if (person != nil && ABPersonHasImageData(person)) {
         if ( &ABPersonCopyImageDataWithFormat != nil ) {
         // iOS >= 4.1
         CFDataRef contactThumbnailData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
         personImage = [[UIImage imageWithData:(NSData*)contactThumbnailData] thumbnailImage:CGSizeMake(44, 44)];
         CFRelease(contactThumbnailData);
         CFDataRef contactImageData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
         CFRelease(contactImageData);
         
         } else {
         // iOS < 4.1
         CFDataRef contactImageData = ABPersonCopyImageData(person);
         personImage = [[UIImage imageWithData:(NSData*)contactImageData] thumbnailImage:CGSizeMake(44, 44)];
         CFRelease(contactImageData);
         }
         }
         [addressBook setThumbnail:personImage];
         */
        
        NSString *nameString = (NSString *)abName;
        NSString *lastNameString = (NSString *)abLastName;
        
        if ((id)abFullName != nil) {
            nameString = (NSString *)abFullName;
        } else {
            if ((id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        
        addressBook.name = nameString;
        addressBook.recordID = (int)ABRecordGetRecordID(person);;
        addressBook.rowSelected = NO;
        
        ABMultiValueRef multival = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSArray *arrayPhone = (NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
        
        addressBook.phoneArray = arrayPhone;
        
        if ([initialArray count]) {
            for (NSString *phone in initialArray) {
                for (NSString *phn in arrayPhone) {
                    if ([phn isEqualToString:phone]) {
                        addressBook.rowSelected = YES;
                        _selectedCount++;
                        
                        break;
                    }
                }
            }
        }
        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        addressBook.tel = [(NSString*)value telephoneWithReformat];
                        break;
                    }
                    case 1: {// Email
                        addressBook.email = (NSString*)value;
                        break;
                    }
                }
                CFRelease(value);
            }
            CFRelease(valuesRef);
        }
        
        [addressBookTemp addObject:addressBook];
        [addressBook release];
        
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    
    CFRelease(allPeople);
    CFRelease(addressBooks);
    
    // Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    for (gc_TKAddressBook *addressBook in addressBookTemp) {
        NSInteger sect = [theCollation sectionForObject:addressBook
                                collationStringSelector:@selector(name)];
        addressBook.sectionNumber = sect;
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i=0; i<=highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (gc_TKAddressBook *addressBook in addressBookTemp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:addressBook.sectionNumber] addObject:addressBook];
    }
    
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(name)];
        [_listContent addObject:sortedSection];
    }
    
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _selectedCount = 0;
        _listContent = [NSMutableArray new];
        _filteredListContent = [NSMutableArray new];
        
        initialArray = [[NSArray alloc] init];
    }
    return self;
}

- (id)initWithSelectedContacts:(NSArray *)contacts {
    if (self = [super initWithNibName:NSStringFromClass([gc_TKContactsMultiPickerController class]) bundle:nil]) {
        _selectedCount = 0;
        _listContent = [NSMutableArray new];
        _filteredListContent = [NSMutableArray new];
        
        initialArray = [contacts retain];
        
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setTitle:NSLocalizedString(@"Contacts", nil)];
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)] autorelease]];
    
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    indexPathForSelection = [NSIndexPath retain];
	
	self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
	self.searchDisplayController.searchBar.showsCancelButton = NO;
    
    for(UIView *subView in self.searchDisplayController.searchBar.subviews) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType:UIReturnKeyDone];
        }
    }
    
    [self reloadAddressBook];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
	} else {
        return [_listContent count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[_listContent objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 0;
    return [[_listContent objectAtIndex:section] count] ? tableView.sectionHeaderHeight : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filteredListContent count];
    } else {
        return [[_listContent objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCustomCellID = @"QBPeoplePickerControllerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	gc_TKAddressBook *addressBook = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
        addressBook = (gc_TKAddressBook *)[_filteredListContent objectAtIndex:indexPath.row];
	else
        addressBook = (gc_TKAddressBook *)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([[addressBook.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        cell.textLabel.text = addressBook.name;
    } else {
        cell.textLabel.font = [UIFont italicSystemFontOfSize:cell.textLabel.font.pointSize];
        cell.textLabel.text = @"No Name";
    }
	
  
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(30.0, 0.0, 28, 28)];
	[button setBackgroundImage:[UIImage imageNamed:@"gc_uncheckBox.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"gc_checkBox.png"] forState:UIControlStateSelected];
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    [button setSelected:addressBook.rowSelected];
    
	cell.accessoryView = button;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		[self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	gc_TKAddressBook *addressBook = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
		addressBook = (gc_TKAddressBook*)[_filteredListContent objectAtIndex:indexPath.row];
	else
        addressBook = (gc_TKAddressBook*)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    /*
     
     Previously working
     
     BOOL checked = !addressBook.rowSelected;
     addressBook.rowSelected = checked;
     
     // Enabled rightButtonItem
     if (checked) _selectedCount++;
     else _selectedCount--;
     
     */
    
    BOOL checked = !addressBook.rowSelected;
    
    if (!checked) {
        addressBook.rowSelected = NO;
        _selectedCount--;
        
        UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = (UIButton *)cell.accessoryView;
        [button setSelected:checked];
        
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    } else {
        
        if ([addressBook.phoneArray count]) {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"Select a Number" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
            
            for(int index = 0; index < [addressBook.phoneArray count]; index++)
            {
                [ac addButtonWithTitle:[NSString stringWithFormat:@"%@", [addressBook.phoneArray objectAtIndex:index]]];
            }
            
            [ac addButtonWithTitle:@"Cancel"];
            ac.cancelButtonIndex = ac.numberOfButtons;
            
            [indexPathForSelection release];
            indexPathForSelection = [indexPath retain];
            
            ac.tag = indexPath.row;
            [ac showInView:self.view];
            [ac release];
            
        } else {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"No Phone Number" message:@"Contacts need to have a phone number in order to be sent messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [al show];
            [al release];
        }
        
    }
    
    if (_selectedCount > 0 || ([initialArray count] && _selectedCount != [initialArray count])) {
        [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease]];
        
        [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)] autorelease]];
        
        self.title = [NSString stringWithFormat:@"Add (%i)", _selectedCount];
        
    } else {
        [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)] autorelease]];
        
        [self.navigationItem setLeftBarButtonItem:nil];
        
        self.title = @"Contacts";
        
    }
    
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	
	if (indexPath != nil)
	{
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Save action

- (IBAction)doneAction:(id)sender
{
	NSMutableArray *objects = [NSMutableArray new];
    for (NSArray *section in _listContent) {
        for (gc_TKAddressBook *addressBook in section)
        {
            if (addressBook.rowSelected)
                [objects addObject:addressBook];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(tkContactsMultiPickerController:didFinishPickingDataWithInfo:)])
        [self.delegate tkContactsMultiPickerController:self didFinishPickingDataWithInfo:objects];
    
	[objects release];
}

- (IBAction)dismissAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tkContactsMultiPickerControllerDidCancel:)])
        [self.delegate tkContactsMultiPickerControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
    
    searching = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
    
    searching = NO;
    
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
    
    searching = NO;
    
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ContentFiltering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredListContent removeAllObjects];
    for (NSArray *section in _listContent) {
        for (gc_TKAddressBook *addressBook in section)
        {
            NSComparisonResult result = [addressBook.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
            {
                [_filteredListContent addObject:addressBook];
            }
        }
    }
}

#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    gc_TKAddressBook *addressBook = nil;
    
	if (searching) {
		addressBook = (gc_TKAddressBook*)[_filteredListContent objectAtIndex:indexPathForSelection.row];
    }
	else {
        addressBook = (gc_TKAddressBook*)[[_listContent objectAtIndex:indexPathForSelection.section] objectAtIndex:indexPathForSelection.row];
    }
    
    if (buttonIndex < [addressBook.phoneArray count]) {
        addressBook.tel = [addressBook.phoneArray objectAtIndex:buttonIndex];
        
        addressBook.rowSelected = YES;
        
        _selectedCount++;
        
        if (_selectedCount > 0) {
            [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease]];
            
            [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)] autorelease]];
            
            self.title = [NSString stringWithFormat:@"Add (%i)", _selectedCount];
            
        } else {
            [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)] autorelease]];
            
            [self.navigationItem setLeftBarButtonItem:nil];
            
            self.title = @"Contacts";
            
        }
        
        if (searching)
        {
            UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPathForSelection];
            UIButton *button = (UIButton *)cell.accessoryView;
            [button setSelected:YES];
        } else {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPathForSelection];
            UIButton *button = (UIButton *)cell.accessoryView;
            [button setSelected:YES];
        }
    }
    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[_filteredListContent release];
    [_listContent release];
    [_tableView release];
    [_searchBar release];
    
    [initialArray release];
    
    [indexPathForSelection release];
	[super dealloc];
}

@end