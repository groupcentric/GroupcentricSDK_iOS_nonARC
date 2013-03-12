//
//  TKNoContactViewController.h
//  Qnote
//
//  Created by Jongtae Ahn on 12. 9. 20..
//  Copyright (c) 2012년 Tabko Inc. All rights reserved.
//
#import <UIKit/UIKit.h>

@class gc_TKNoContactViewController;
@protocol gc_TKNoContactViewControllerDelegate <NSObject>
@required

- (void)tkNoContactViewControllerDidCancel:(gc_TKNoContactViewController*)controller;

@end

@interface gc_TKNoContactViewController : UIViewController

@property (nonatomic, assign) id<gc_TKNoContactViewControllerDelegate> delegate;

@end
