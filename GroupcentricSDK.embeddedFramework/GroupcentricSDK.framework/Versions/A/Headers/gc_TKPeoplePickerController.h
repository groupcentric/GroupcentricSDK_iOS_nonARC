//
//  TKPeoplePickerController.h
//  Qnote
//
//  Created by Jongtae Ahn on 12. 9. 3..
//  Copyright (c) 2012년 Tabko Inc. All rights reserved.
//

#import "gc_TKGroupPickerController.h" // Future update
#import "gc_TKContactsMultiPickerController.h"
#import "gc_TKNoContactViewController.h"

@class gc_TKPeoplePickerController;
@protocol gc_TKPeoplePickerControllerDelegate <NSObject>
@required
- (void)tkPeoplePickerController:(gc_TKPeoplePickerController*)picker didFinishPickingDataWithInfo:(NSArray*)contacts;
- (void)tkPeoplePickerControllerDidCancel:(gc_TKPeoplePickerController*)picker;
@end

@interface gc_TKPeoplePickerController : UINavigationController <gc_TKGroupPickerControllerDelegate, gc_TKContactsMultiPickerControllerDelegate, gc_TKNoContactViewControllerDelegate>

@property (nonatomic, assign) id<gc_TKPeoplePickerControllerDelegate> actionDelegate;
@property (nonatomic, retain) gc_TKGroupPickerController *groupController;
@property (nonatomic, retain) gc_TKContactsMultiPickerController *contactController;

- (id)initPeoplePicker;

- (id)initPeoplePickerWithContacts:(NSArray *)contacts;

@end
