/*
 * This file is part of the gc_SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "gc_SDWebImageManagerDelegate.h"
#import "gc_SDWebImageManager.h"

/**
 * Prefetch some URLs in the cache for future use. Images are downloaded in low priority.
 */
@interface gc_SDWebImagePrefetcher : NSObject <gc_SDWebImageManagerDelegate>
{
    NSArray *_prefetchURLs;
    NSUInteger _skippedCount;
    NSUInteger _finishedCount;
    NSUInteger _requestedCount;
    NSTimeInterval _startedTime;
}

/**
 * Maximum number of URLs to prefetch at the same time. Defaults to 3.
 */
@property (nonatomic, assign) NSUInteger maxConcurrentDownloads;

/**
 * gc_SDWebImageOptions for prefetcher. Defaults to gc_SDWebImageLowPriority.
 */
@property (nonatomic, assign) gc_SDWebImageOptions options;


/**
 * Return the global image prefetcher instance.
 */
+ (gc_SDWebImagePrefetcher *)sharedImagePrefetcher;

/**
 * Assign list of URLs to let gc_SDWebImagePrefetcher to queue the prefetching,
 * currently one image is downloaded at a time,
 * and skips images for failed downloads and proceed to the next image in the list
 *
 * @param urls list of URLs to prefetch
 */
- (void)prefetchURLs:(NSArray *)urls;


/**
 * Remove and cancel queued list
 */
- (void)cancelPrefetching;


@end
