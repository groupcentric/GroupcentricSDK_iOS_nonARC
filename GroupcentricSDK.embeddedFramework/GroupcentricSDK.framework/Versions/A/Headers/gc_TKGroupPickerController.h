//
//  TKGroupPickerController.h
//  Thumb+
//
//  Created by Jongtae Ahn on 12. 9. 1..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//
#import <UIKit/UIKit.h>

@class gc_TKGroupPickerController;
@protocol gc_TKGroupPickerControllerDelegate <NSObject>
@required
- (void)tkGroupPickerControllerDidCancel:(gc_TKGroupPickerController*)picker;
@end

@interface gc_TKGroupPickerController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    id _delegate;
}

@property (nonatomic, assign) id<gc_TKGroupPickerControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *groups;

- (void)reloadGroups;

@end
