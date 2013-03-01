//
//  gc_SDImageCacheDelegate.h
//  Dailymotion
//
//  Created by Olivier Poitrey on 16/09/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "gc_SDWebImageCompat.h"

@class gc_SDImageCache;

/**
 * Delegate protocol for gc_SDImageCache
 */
@protocol gc_SDImageCacheDelegate <NSObject>

@optional

/**
 * Called when [gc_SDImageCache queryDiskCacheForKey:delegate:userInfo:] retrived the image from cache
 *
 * @param imageCache The cache store instance
 * @param image The requested image instance
 * @param key The requested image cache key
 * @param info The provided user info dictionary
 */
- (void)imageCache:(gc_SDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info;

/**
 * Called when [gc_SDImageCache queryDiskCacheForKey:delegate:userInfo:] did not find the image in the cache
 *
 * @param imageCache The cache store instance
 * @param key The requested image cache key
 * @param info The provided user info dictionary
 */
- (void)imageCache:(gc_SDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info;

@end
