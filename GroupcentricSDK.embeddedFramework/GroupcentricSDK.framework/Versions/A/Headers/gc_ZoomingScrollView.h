//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gc_UIImageViewTap.h"
#import "gc_UIViewTap.h"

@class gc_MWPhotoBrowser;

@interface gc_ZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate> {
	
	// Browser
	gc_MWPhotoBrowser *photoBrowser;
	
	// State
	NSUInteger index;
	
	// Views
	gc_UIViewTap *tapView; // for background taps
	gc_UIImageViewTap *photoImageView;
	UIActivityIndicatorView *spinner;
	
}

// Properties
@property (nonatomic) NSUInteger index;
@property (nonatomic, assign) gc_MWPhotoBrowser *photoBrowser;

// Methods
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end
