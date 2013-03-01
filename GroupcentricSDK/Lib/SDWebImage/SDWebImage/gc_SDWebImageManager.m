/*
 * This file is part of the gc_SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "gc_SDWebImageManager.h"
#import "gc_SDImageCache.h"
#import "gc_SDWebImageDownloader.h"
#import <objc/message.h>

static gc_SDWebImageManager *instance;

@implementation gc_SDWebImageManager

#if NS_BLOCKS_AVAILABLE
@synthesize cacheKeyFilter;
#endif

- (id)init
{
    if ((self = [super init]))
    {
        downloadInfo = [[NSMutableArray alloc] init];
        downloadDelegates = [[NSMutableArray alloc] init];
        downloaders = [[NSMutableArray alloc] init];
        cacheDelegates = [[NSMutableArray alloc] init];
        cacheURLs = [[NSMutableArray alloc] init];
        downloaderForURL = [[NSMutableDictionary alloc] init];
        failedURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    gc_SDWISafeRelease(downloadInfo);
    gc_SDWISafeRelease(downloadDelegates);
    gc_SDWISafeRelease(downloaders);
    gc_SDWISafeRelease(cacheDelegates);
    gc_SDWISafeRelease(cacheURLs);
    gc_SDWISafeRelease(downloaderForURL);
    gc_SDWISafeRelease(failedURLs);
    gc_SDWISuperDealoc;
}


+ (id)sharedManager
{
    if (instance == nil)
    {
        instance = [[gc_SDWebImageManager alloc] init];
    }

    return instance;
}

- (NSString *)cacheKeyForURL:(NSURL *)url
{
#if NS_BLOCKS_AVAILABLE
    if (self.cacheKeyFilter)
    {
        return self.cacheKeyFilter(url);
    }
    else
    {
        return [url absoluteString];
    }
#else
    return [url absoluteString];
#endif
}

/*
 * @deprecated
 */
- (UIImage *)imageWithURL:(NSURL *)url
{
    return [[gc_SDImageCache sharedImageCache] imageFromKey:[self cacheKeyForURL:url]];
}

/*
 * @deprecated
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed
{
    [self downloadWithURL:url delegate:delegate options:(retryFailed ? gc_SDWebImageRetryFailed : 0)];
}

/*
 * @deprecated
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority
{
    gc_SDWebImageOptions options = 0;
    if (retryFailed) options |= gc_SDWebImageRetryFailed;
    if (lowPriority) options |= gc_SDWebImageLowPriority;
    [self downloadWithURL:url delegate:delegate options:options];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate
{
    [self downloadWithURL:url delegate:delegate options:0];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate options:(gc_SDWebImageOptions)options
{
    [self downloadWithURL:url delegate:delegate options:options userInfo:nil];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<gc_SDWebImageManagerDelegate>)delegate options:(gc_SDWebImageOptions)options userInfo:(NSDictionary *)userInfo
{
    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class])
    {
        url = [NSURL URLWithString:(NSString *)url];
    }
    else if (![url isKindOfClass:NSURL.class])
    {
        url = nil; // Prevent some common crashes due to common wrong values passed like NSNull.null for instance
    }

    if (!url || !delegate || (!(options & gc_SDWebImageRetryFailed) && [failedURLs containsObject:url]))
    {
        return;
    }

    // Check the on-disk cache async so we don't block the main thread
    [cacheDelegates addObject:delegate];
    [cacheURLs addObject:url];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          delegate, @"delegate",
                          url, @"url",
                          [NSNumber numberWithInt:options], @"options",
                          userInfo ? userInfo : [NSNull null], @"userInfo",
                          nil];
    [[gc_SDImageCache sharedImageCache] queryDiskCacheForKey:[self cacheKeyForURL:url] delegate:self userInfo:info];
}

#if NS_BLOCKS_AVAILABLE
- (void)downloadWithURL:(NSURL *)url delegate:(id)delegate options:(gc_SDWebImageOptions)options success:(gc_SDWebImageSuccessBlock)success failure:(gc_SDWebImageFailureBlock)failure
{
    [self downloadWithURL:url delegate:delegate options:options userInfo:nil success:success failure:failure];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id)delegate options:(gc_SDWebImageOptions)options userInfo:(NSDictionary *)userInfo success:(gc_SDWebImageSuccessBlock)success failure:(gc_SDWebImageFailureBlock)failure
{
    // repeated logic from above due to requirement for backwards compatability for iOS versions without blocks
    
    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class])
    {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    if (!url || !delegate || (!(options & gc_SDWebImageRetryFailed) && [failedURLs containsObject:url]))
    {
        return;
    }
    
    // Check the on-disk cache async so we don't block the main thread
    [cacheDelegates addObject:delegate];
    [cacheURLs addObject:url];
    gc_SDWebImageSuccessBlock successCopy = [success copy];
    gc_SDWebImageFailureBlock failureCopy = [failure copy];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          delegate, @"delegate",
                          url, @"url",
                          [NSNumber numberWithInt:options], @"options",
                          userInfo ? userInfo : [NSNull null], @"userInfo",
                          successCopy, @"success",
                          failureCopy, @"failure",
                          nil];
    gc_SDWIRelease(successCopy);
    gc_SDWIRelease(failureCopy);
    [[gc_SDImageCache sharedImageCache] queryDiskCacheForKey:[self cacheKeyForURL:url] delegate:self userInfo:info];
}
#endif

- (void)cancelForDelegate:(id<gc_SDWebImageManagerDelegate>)delegate
{
    NSUInteger idx;
    while ((idx = [cacheDelegates indexOfObjectIdenticalTo:delegate]) != NSNotFound)
    {
        [cacheDelegates removeObjectAtIndex:idx];
        [cacheURLs removeObjectAtIndex:idx];
    }

    while ((idx = [downloadDelegates indexOfObjectIdenticalTo:delegate]) != NSNotFound)
    {
        gc_SDWebImageDownloader *downloader = gc_SDWIReturnRetained([downloaders objectAtIndex:idx]);

        [downloadInfo removeObjectAtIndex:idx];
        [downloadDelegates removeObjectAtIndex:idx];
        [downloaders removeObjectAtIndex:idx];

        if (![downloaders containsObject:downloader])
        {
            // No more delegate are waiting for this download, cancel it
            [downloader cancel];
            [downloaderForURL removeObjectForKey:downloader.url];
        }

        gc_SDWIRelease(downloader);
    }
}

#pragma mark gc_SDImageCacheDelegate

- (NSUInteger)indexOfDelegate:(id<gc_SDWebImageManagerDelegate>)delegate waitingForURL:(NSURL *)url
{
    // Do a linear search, simple (even if inefficient)
    NSUInteger idx;
    for (idx = 0; idx < [cacheDelegates count]; idx++)
    {
        if ([cacheDelegates objectAtIndex:idx] == delegate && [[cacheURLs objectAtIndex:idx] isEqual:url])
        {
            return idx;
        }
    }
    return NSNotFound;
}

- (void)imageCache:(gc_SDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info
{
    NSURL *url = [info objectForKey:@"url"];
    id<gc_SDWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];

    NSUInteger idx = [self indexOfDelegate:delegate waitingForURL:url];
    if (idx == NSNotFound)
    {
        // Request has since been canceled
        return;
    }

    if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:)])
    {
        [delegate performSelector:@selector(webImageManager:didFinishWithImage:) withObject:self withObject:image];
    }
    if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:forURL:)])
    {
        objc_msgSend(delegate, @selector(webImageManager:didFinishWithImage:forURL:), self, image, url);
    }
    if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:forURL:userInfo:)])
    {
        NSDictionary *userInfo = [info objectForKey:@"userInfo"];
        if ([userInfo isKindOfClass:NSNull.class])
        {
            userInfo = nil;
        }
        objc_msgSend(delegate, @selector(webImageManager:didFinishWithImage:forURL:userInfo:), self, image, url, userInfo);
    }
#if NS_BLOCKS_AVAILABLE
    if ([info objectForKey:@"success"])
    {
        gc_SDWebImageSuccessBlock success = [info objectForKey:@"success"];
        success(image, YES);
    }
#endif

    [cacheDelegates removeObjectAtIndex:idx];
    [cacheURLs removeObjectAtIndex:idx];
}

- (void)imageCache:(gc_SDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info
{
    NSURL *url = [info objectForKey:@"url"];
    id<gc_SDWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];
    gc_SDWebImageOptions options = [[info objectForKey:@"options"] intValue];

    NSUInteger idx = [self indexOfDelegate:delegate waitingForURL:url];
    if (idx == NSNotFound)
    {
        // Request has since been canceled
        return;
    }

    [cacheDelegates removeObjectAtIndex:idx];
    [cacheURLs removeObjectAtIndex:idx];

    // Share the same downloader for identical URLs so we don't download the same URL several times
    gc_SDWebImageDownloader *downloader = [downloaderForURL objectForKey:url];

    if (!downloader)
    {
        downloader = [gc_SDWebImageDownloader downloaderWithURL:url delegate:self userInfo:info lowPriority:(options & gc_SDWebImageLowPriority)];
        [downloaderForURL setObject:downloader forKey:url];
    }
    else
    {
        // Reuse shared downloader
        downloader.lowPriority = (options & gc_SDWebImageLowPriority);
    }

    if ((options & gc_SDWebImageProgressiveDownload) && !downloader.progressive)
    {
        // Turn progressive download support on demand
        downloader.progressive = YES;
    }

    [downloadInfo addObject:info];
    [downloadDelegates addObject:delegate];
    [downloaders addObject:downloader];
}

#pragma mark gc_SDWebImageDownloaderDelegate

- (void)imageDownloader:(gc_SDWebImageDownloader *)downloader didUpdatePartialImage:(UIImage *)image
{
    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[downloaders count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        gc_SDWebImageDownloader *aDownloader = [downloaders objectAtIndex:uidx];
        if (aDownloader == downloader)
        {
            id<gc_SDWebImageManagerDelegate> delegate = [downloadDelegates objectAtIndex:uidx];
            gc_SDWIRetain(delegate);
            gc_SDWIAutorelease(delegate);

            if ([delegate respondsToSelector:@selector(webImageManager:didProgressWithPartialImage:forURL:)])
            {
                objc_msgSend(delegate, @selector(webImageManager:didProgressWithPartialImage:forURL:), self, image, downloader.url);
            }
            if ([delegate respondsToSelector:@selector(webImageManager:didProgressWithPartialImage:forURL:userInfo:)])
            {
                NSDictionary *userInfo = [[downloadInfo objectAtIndex:uidx] objectForKey:@"userInfo"];
                if ([userInfo isKindOfClass:NSNull.class])
                {
                    userInfo = nil;
                }
                objc_msgSend(delegate, @selector(webImageManager:didProgressWithPartialImage:forURL:userInfo:), self, image, downloader.url, userInfo);
            }
        }
    }
}

- (void)imageDownloader:(gc_SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    gc_SDWIRetain(downloader);
    gc_SDWebImageOptions options = [[downloader.userInfo objectForKey:@"options"] intValue];

    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[downloaders count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        gc_SDWebImageDownloader *aDownloader = [downloaders objectAtIndex:uidx];
        if (aDownloader == downloader)
        {
            id<gc_SDWebImageManagerDelegate> delegate = [downloadDelegates objectAtIndex:uidx];
            gc_SDWIRetain(delegate);
            gc_SDWIAutorelease(delegate);

            if (image)
            {
                if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:)])
                {
                    [delegate performSelector:@selector(webImageManager:didFinishWithImage:) withObject:self withObject:image];
                }
                if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:forURL:)])
                {
                    objc_msgSend(delegate, @selector(webImageManager:didFinishWithImage:forURL:), self, image, downloader.url);
                }
                if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:forURL:userInfo:)])
                {
                    NSDictionary *userInfo = [[downloadInfo objectAtIndex:uidx] objectForKey:@"userInfo"];
                    if ([userInfo isKindOfClass:NSNull.class])
                    {
                        userInfo = nil;
                    }
                    objc_msgSend(delegate, @selector(webImageManager:didFinishWithImage:forURL:userInfo:), self, image, downloader.url, userInfo);
                }
#if NS_BLOCKS_AVAILABLE
                if ([[downloadInfo objectAtIndex:uidx] objectForKey:@"success"])
                {
                    gc_SDWebImageSuccessBlock success = [[downloadInfo objectAtIndex:uidx] objectForKey:@"success"];
                    success(image, NO);
                }
#endif
            }
            else
            {
                if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:)])
                {
                    [delegate performSelector:@selector(webImageManager:didFailWithError:) withObject:self withObject:nil];
                }
                if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:forURL:)])
                {
                    objc_msgSend(delegate, @selector(webImageManager:didFailWithError:forURL:), self, nil, downloader.url);
                }
                if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:forURL:userInfo:)])
                {
                    NSDictionary *userInfo = [[downloadInfo objectAtIndex:uidx] objectForKey:@"userInfo"];
                    if ([userInfo isKindOfClass:NSNull.class])
                    {
                        userInfo = nil;
                    }
                    objc_msgSend(delegate, @selector(webImageManager:didFailWithError:forURL:userInfo:), self, nil, downloader.url, userInfo);
                }
#if NS_BLOCKS_AVAILABLE
                if ([[downloadInfo objectAtIndex:uidx] objectForKey:@"failure"])
                {
                    gc_SDWebImageFailureBlock failure = [[downloadInfo objectAtIndex:uidx] objectForKey:@"failure"];
                    failure(nil);
                }
#endif
            }

            [downloaders removeObjectAtIndex:uidx];
            [downloadInfo removeObjectAtIndex:uidx];
            [downloadDelegates removeObjectAtIndex:uidx];
        }
    }

    if (image)
    {
        // Store the image in the cache
        [[gc_SDImageCache sharedImageCache] storeImage:image
                                          imageData:downloader.imageData
                                             forKey:[self cacheKeyForURL:downloader.url]
                                             toDisk:!(options & gc_SDWebImageCacheMemoryOnly)];
    }
    else if (!(options & gc_SDWebImageRetryFailed))
    {
        // The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
        // (do this only if gc_SDWebImageRetryFailed isn't activated)
        [failedURLs addObject:downloader.url];
    }


    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
    gc_SDWIRelease(downloader);
}

- (void)imageDownloader:(gc_SDWebImageDownloader *)downloader didFailWithError:(NSError *)error;
{
    gc_SDWIRetain(downloader);

    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[downloaders count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        gc_SDWebImageDownloader *aDownloader = [downloaders objectAtIndex:uidx];
        if (aDownloader == downloader)
        {
            id<gc_SDWebImageManagerDelegate> delegate = [downloadDelegates objectAtIndex:uidx];
            gc_SDWIRetain(delegate);
            gc_SDWIAutorelease(delegate);

            if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:)])
            {
                [delegate performSelector:@selector(webImageManager:didFailWithError:) withObject:self withObject:error];
            }
            if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:forURL:)])
            {
                objc_msgSend(delegate, @selector(webImageManager:didFailWithError:forURL:), self, error, downloader.url);
            }
            if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:forURL:userInfo:)])
            {
                NSDictionary *userInfo = [[downloadInfo objectAtIndex:uidx] objectForKey:@"userInfo"];
                if ([userInfo isKindOfClass:NSNull.class])
                {
                    userInfo = nil;
                }
                objc_msgSend(delegate, @selector(webImageManager:didFailWithError:forURL:userInfo:), self, error, downloader.url, userInfo);
            }
#if NS_BLOCKS_AVAILABLE
            if ([[downloadInfo objectAtIndex:uidx] objectForKey:@"failure"])
            {
                gc_SDWebImageFailureBlock failure = [[downloadInfo objectAtIndex:uidx] objectForKey:@"failure"];
                failure(error);
            }
#endif

            [downloaders removeObjectAtIndex:uidx];
            [downloadInfo removeObjectAtIndex:uidx];
            [downloadDelegates removeObjectAtIndex:uidx];
        }
    }

    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
    gc_SDWIRelease(downloader);
}

@end
