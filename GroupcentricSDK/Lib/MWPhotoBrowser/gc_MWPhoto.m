//
//  gc_MWPhoto.m
//  gc_MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "gc_MWPhoto.h"
#import "gc_UIImage+Decompress.h"

// Private
@interface gc_MWPhoto ()

// Properties
@property (retain) UIImage *photoImage;
@property () BOOL workingInBackground;

// Private Methods
- (void)doBackgroundWork:(id <gc_MWPhotoDelegate>)delegate;

@end


// gc_MWPhoto
@implementation gc_MWPhoto

// Properties
@synthesize photoImage, workingInBackground;

#pragma mark Class Methods

+ (gc_MWPhoto *)photoWithImage:(UIImage *)image {
	return [[[gc_MWPhoto alloc] initWithImage:image] autorelease];
}

+ (gc_MWPhoto *)photoWithFilePath:(NSString *)path {
	return [[[gc_MWPhoto alloc] initWithFilePath:path] autorelease];
}

+ (gc_MWPhoto *)photoWithURL:(NSURL *)url {
	return [[[gc_MWPhoto alloc] initWithURL:url] autorelease];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		self.photoImage = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		photoURL = [url copy];
	}
	return self;
}

- (void)dealloc {
	[photoPath release];
	[photoURL release];
	[photoImage release];
	[super dealloc];
}

#pragma mark Photo

// Return whether the image available
// It is available if the UIImage has been loaded and
// loading from file or URL is not required
- (BOOL)isImageAvailable {
	return (self.photoImage != nil);
}

// Return image
- (UIImage *)image {
	return self.photoImage;
}

// Get and return the image from existing image, file path or url
- (UIImage *)obtainImage {
	if (!self.photoImage) {
		
		// Load
		UIImage *img = nil;
		if (photoPath) { 
			
			// Read image from file
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfFile:photoPath options:NSDataReadingUncached error:&error];
			if (!error) {
				img = [[UIImage alloc] initWithData:data];
			} else {
				NSLog(@"Photo from file error: %@", error);
			}
			
		} else if (photoURL) { 
			
			// Read image from URL and return
			NSURLRequest *request = [[NSURLRequest alloc] initWithURL:photoURL];
			NSError *error = nil;
			NSURLResponse *response = nil;
			NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
			[request release];
			if (data) {
				img = [[UIImage alloc] initWithData:data];
			} else {
				NSLog(@"Photo from URL error: %@", error);
			}
			
		}

		// Force the loading and caching of raw image data for speed
		[img decompress];		
		
		// Store
		self.photoImage = img;
		[img release];
		
	}
	return [[self.photoImage retain] autorelease];
}

// Release if we can get it again from path or url
- (void)releasePhoto {
	if (self.photoImage && (photoPath || photoURL)) {
		self.photoImage = nil;
	}
}

// Obtain image in background and notify the browser when it has loaded
- (void)obtainImageInBackgroundAndNotify:(id <gc_MWPhotoDelegate>)delegate {
	if (self.workingInBackground == YES) return; // Already fetching
	self.workingInBackground = YES;
	[self performSelectorInBackground:@selector(doBackgroundWork:) withObject:delegate];
}

// Run on background thread
// Download image and notify delegate
- (void)doBackgroundWork:(id <gc_MWPhotoDelegate>)delegate {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Load image
	UIImage *img = [self obtainImage];
	
	// Notify delegate of success or fail
	if (img) {
		[(NSObject *)delegate performSelectorOnMainThread:@selector(photoDidFinishLoading:) withObject:self waitUntilDone:NO];
	} else {
		[(NSObject *)delegate performSelectorOnMainThread:@selector(photoDidFailToLoad:) withObject:self waitUntilDone:NO];		
	}

	// Finish
	self.workingInBackground = NO;
	
	[pool release];
}

@end
