//
//  TKContactsMultiPickerController.h
//  TKContactsMultiPicker
//
//  Created by Jongtae Ahn on 12. 8. 31..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <malloc/malloc.h>
#import "gc_TKAddressBook.h"

@class gc_TKAddressBook, gc_TKContactsMultiPickerController;
@protocol gc_TKContactsMultiPickerControllerDelegate <NSObject>
@required
- (void)tkContactsMultiPickerController:(gc_TKContactsMultiPickerController*)picker didFinishPickingDataWithInfo:(NSArray*)contacts;
- (void)tkContactsMultiPickerControllerDidCancel:(gc_TKContactsMultiPickerController*)picker;
@end


@interface gc_TKContactsMultiPickerController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate>
{
	id _delegate;
    
    NSIndexPath *indexPathForSelection;
    
    BOOL searching;
    
@private
    NSUInteger _selectedCount;
    NSMutableArray *_listContent;
	NSMutableArray *_filteredListContent;
    
    NSArray *initialArray;
}

@property (nonatomic, retain) id<gc_TKContactsMultiPickerControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

- (id)initWithSelectedContacts:(NSArray *)contacts;


@end
