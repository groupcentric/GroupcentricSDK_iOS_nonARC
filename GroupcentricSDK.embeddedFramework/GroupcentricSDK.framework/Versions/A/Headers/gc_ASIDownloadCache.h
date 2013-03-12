//
//  gc_ASIDownloadCache.h
//  Part of gc_ASIHTTPRequest -> http://allseeing-i.com/gc_ASIHTTPRequest
//
//  Created by Ben Copsey on 01/05/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gc_ASICacheDelegate.h"

@interface gc_ASIDownloadCache : NSObject <gc_ASICacheDelegate> {
	
	// The default cache policy for this cache
	// Requests that store data in the cache will use this cache policy if their cache policy is set to gc_ASIUseDefaultCachePolicy
	// Defaults to gc_ASIAskServerIfModifiedWhenStaleCachePolicy
	gc_ASICachePolicy defaultCachePolicy;
	
	// The directory in which cached data will be stored
	// Defaults to a directory called 'gc_ASIHTTPRequestCache' in the temporary directory
	NSString *storagePath;
	
	// Mediates access to the cache
	NSRecursiveLock *accessLock;
	
	// When YES, the cache will look for cache-control / pragma: no-cache headers, and won't reuse store responses if it finds them
	BOOL shouldRespectCacheControlHeaders;
}

// Returns a static instance of an gc_ASIDownloadCache
// In most circumstances, it will make sense to use this as a global cache, rather than creating your own cache
// To make gc_ASIHTTPRequests use it automatically, use [gc_ASIHTTPRequest setDefaultCache:[gc_ASIDownloadCache sharedCache]];
+ (id)sharedCache;

// A helper function that determines if the server has requested data should not be cached by looking at the request's response headers
+ (BOOL)serverAllowsResponseCachingForRequest:(gc_ASIHTTPRequest *)request;

@property (assign, nonatomic) gc_ASICachePolicy defaultCachePolicy;
@property (retain, nonatomic) NSString *storagePath;
@property (retain) NSRecursiveLock *accessLock;
@property (assign) BOOL shouldRespectCacheControlHeaders;
@end
