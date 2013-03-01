/*
 * This file is part of the gc_SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "gc_SDWebImageCompat.h"
#import "gc_SDWebImageDownloaderDelegate.h"
#import "gc_SDWebImageManagerDelegate.h"
#import "gc_SDImageCacheDelegate.h"

typedef enum
{
    gc_SDWebImageRetryFailed = 1 << 0,
    gc_SDWebImageLowPriority = 1 << 1,
    gc_SDWebImageCacheMemoryOnly = 1 << 2,
    gc_SDWebImageProgressiveDownload = 1 << 3
} gc_SDWebImageOptions;

#if NS_BLOCKS_AVAILABLE
typedef void(^gc_SDWebImageSuccessBlock)(UIImage *image, BOOL cached);
typedef void(^gc_SDWebImageFailureBlock)(NSError *error);
#endif

/**
 * The gc_SDWebImageManager is the class behind the UIImageView+WebCache category and likes.
 * It ties the asynchronous downloader (gc_SDWebImageDownloader) with the image cache store (gc_SDImageCache).
 * You can use this class directly to benefit from web image downloading with caching in another context than
 * a UIView.
 *
 * Here is a simple example of how to use gc_SDWebImageManager:
 *
 *  gc_SDWebImageManager *manager = [gc_SDWebImageManager sharedManager];
 *  [manager downloadWithURL:imageURL
 *                  delegate:self
 *                   options:0
 *                   success:^(UIImage *image, BOOL cached)
 *                   {
 *                       // do something with image
 *                   }
 *                   failure:nil];
 */
@interface gc_SDWebImageManager : NSObject <gc_SDWebImageDownloaderDelegate, gc_SDImageCacheDelegate>
{
    NSMutableArray *downloadInfo;
    NSMutableArray *downloadDelegates;
    NSMutableArray *downloaders;
    NSMutableArray *cacheDelegates;
    NSMutableArray *cacheURLs;
    NSMutableDictionary *downloaderForURL;
    NSMutableArray *failedURLs;
}

#if NS_BLOCKS_AVAILABLE
typedef NSString *(^CacheKeyFilter)(NSURL *url);

/**
 * The cache filter is a block used each time gc_SDWebManager need to convert an URL into a cache key. This can
 * be used to remove dynamic part of an image URL.
 *
 * The following example sets a filter in the application delegate that will remove any query-string from the
 * URL before to use it as a cache key:
 *
 * 	[[gc_SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url)
 *	{
 *	    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
 *	    return [url absoluteString];
 *	}];
 */
@property (strong) CacheKeyFilter cacheKeyFilter;
#endif


/**
 * Returns global gc_SDWebImageManager instance.
 *
 * @return gc_SDWebImageManager shared instance
 */
+ (id)sharedManager;

- (UIImage *)imageWithURL:(NSURL *)url __attribute__ ((deprecated));

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @see [gc_SDWebImageManager downloadWithURL:delegate:options:userInfo:]
 * @see [gc_SDWebImageManager downloadWithURL:delegate:options:userInfo:success:failure:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @see [gc_SDWebImageManager downloadWithURL:delegate:options:userInfo:]
 * @see [gc_SDWebImageManager downloadWithURL:delegate:options:userInfo:success:failure:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate options:(gc_SDWebImageOptions)options;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @param info An Ngc_SDictionnary passed back to delegate if provided
 * @see [gc_SDWebImageManager downloadWithURL:delegate:options:success:failure:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate options:(gc_SDWebImageOptions)options userInfo:(NSDictionary *)info;

// use options:gc_SDWebImageRetryFailed instead
- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed __attribute__ ((deprecated));
// use options:gc_SDWebImageRetryFailed|gc_SDWebImageLowPriority instead
- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority __attribute__ ((deprecated));

#if NS_BLOCKS_AVAILABLE
/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @param success A block called when image has been retrived successfuly
 * @param failure A block called when couldn't be retrived for some reason
 * @see [gc_SDWebImageManager downloadWithURL:delegate:options:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id)delegate options:(gc_SDWebImageOptions)options success:(gc_SDWebImageSuccessBlock)success failure:(gc_SDWebImageFailureBlock)failure;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @param info An Ngc_SDictionnary passed back to delegate if provided
 * @param success A block called when image has been retrived successfuly
 * @param failure A block called when couldn't be retrived for some reason
 * @see [gc_SDWebImageManager downloadWithURL:delegate:options:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id)delegate options:(gc_SDWebImageOptions)options userInfo:(NSDictionary *)info success:(gc_SDWebImageSuccessBlock)success failure:(gc_SDWebImageFailureBlock)failure;
#endif

/**
 * Cancel all pending download requests for a given delegate
 *
 * @param delegate The delegate to cancel requests for
 */
- (void)cancelForDelegate:(id<gc_SDWebImageManagerDelegate>)delegate;

@end
