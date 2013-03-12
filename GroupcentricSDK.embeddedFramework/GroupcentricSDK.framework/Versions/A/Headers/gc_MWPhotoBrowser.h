//
//  gc_MWPhotoBrowser.h
//  gc_MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gc_MWPhoto.h"
//#import "gc_SBJSON.h"

@class gc_ZoomingScrollView;

@interface gc_MWPhotoBrowser : UIViewController <UIScrollViewDelegate, gc_MWPhotoDelegate> {
	
	// Photos
	NSArray *photos;
    NSArray *photoStrings;
	
	// Views
	UIScrollView *pagingScrollView;
	
	// Paging
	NSMutableSet *visiblePages, *recycledPages;
	NSUInteger currentPageIndex;
	NSUInteger pageIndexBeforeRotation;
	
	// Navigation & controls
	UIToolbar *toolbar;
	NSTimer *controlVisibilityTimer;
	UIBarButtonItem *previousButton, *nextButton;

    // Misc
	BOOL performingLayout;
	BOOL rotating;
    
    // Facebook
    NSString *planTitle;
	
}

// Init
- (id)initWithPhotos:(NSArray *)photosArray andStrings:(NSArray *)photoStringsArray andName:(NSString *)name;

// Photos
- (UIImage *)imageAtIndex:(NSUInteger)index;

// Layout
- (void)performLayout;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (gc_ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (gc_ZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(gc_ZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden;
- (void)toggleControls;

// Properties
- (void)setInitialPageIndex:(NSUInteger)index;

@end

