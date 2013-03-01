//
//  gc_ASIAuthenticationDialog.h
//  Part of gc_ASIHTTPRequest -> http://allseeing-i.com/gc_ASIHTTPRequest
//
//  Created by Ben Copsey on 21/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class gc_ASIHTTPRequest;

typedef enum _gc_ASIAuthenticationType {
	gc_ASIStandardAuthenticationType = 0,
    gc_ASIProxyAuthenticationType = 1
} gc_ASIAuthenticationType;

@interface gc_ASIAutorotatingViewController : UIViewController
@end

@interface gc_ASIAuthenticationDialog : gc_ASIAutorotatingViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	gc_ASIHTTPRequest *request;
	gc_ASIAuthenticationType type;
	UITableView *tableView;
	UIViewController *presentingController;
	BOOL didEnableRotationNotifications;
}
+ (void)presentAuthenticationDialogForRequest:(gc_ASIHTTPRequest *)request;
+ (void)dismiss;

@property (retain) gc_ASIHTTPRequest *request;
@property (assign) gc_ASIAuthenticationType type;
@property (assign) BOOL didEnableRotationNotifications;
@property (retain, nonatomic) UIViewController *presentingController;
@end
