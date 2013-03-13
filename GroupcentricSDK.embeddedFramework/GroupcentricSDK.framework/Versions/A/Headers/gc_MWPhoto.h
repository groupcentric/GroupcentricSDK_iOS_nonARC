//
//  gc_MWPhoto.h
//  gc_MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Class
@class gc_MWPhoto;

// Delegate
@protocol gc_MWPhotoDelegate <NSObject>
- (void)photoDidFinishLoading:(gc_MWPhoto *)photo;
- (void)photoDidFailToLoad:(gc_MWPhoto *)photo;
@end

// gc_MWPhoto
@interface gc_MWPhoto : NSObject {
	
	// Image
	NSString *photoPath;
	NSURL *photoURL;
	UIImage *photoImage;
	
	// Flags
	BOOL workingInBackground;
	
}

// Class
+ (gc_MWPhoto *)photoWithImage:(UIImage *)image;
+ (gc_MWPhoto *)photoWithFilePath:(NSString *)path;
+ (gc_MWPhoto *)photoWithURL:(NSURL *)url;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

// Public methods
- (BOOL)isImageAvailable;
- (UIImage *)image;
- (UIImage *)obtainImage;
- (void)obtainImageInBackgroundAndNotify:(id <gc_MWPhotoDelegate>)notifyDelegate;
- (void)releasePhoto;

@end
