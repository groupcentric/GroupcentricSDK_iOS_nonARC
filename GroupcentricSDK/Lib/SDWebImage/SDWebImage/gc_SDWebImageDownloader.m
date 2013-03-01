/*
 * This file is part of the gc_SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "gc_SDWebImageDownloader.h"
#import "gc_SDWebImageDecoder.h"
#import <ImageIO/ImageIO.h>

@interface gc_SDWebImageDownloader (ImageDecoder) <gc_SDWebImageDecoderDelegate>
@end

NSString *const gc_SDWebImageDownloadStartNotification = @"gc_SDWebImageDownloadStartNotification";
NSString *const gc_SDWebImageDownloadStopNotification = @"gc_SDWebImageDownloadStopNotification";

@interface gc_SDWebImageDownloader ()
@property (nonatomic, retain) NSURLConnection *connection;
@end

@implementation gc_SDWebImageDownloader
@synthesize url, delegate, connection, imageData, userInfo, lowPriority, progressive;

#pragma mark Public Methods

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<gc_SDWebImageDownloaderDelegate>)delegate
{
    return [self downloaderWithURL:url delegate:delegate userInfo:nil];
}

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<gc_SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo
{
    return [self downloaderWithURL:url delegate:delegate userInfo:userInfo lowPriority:NO];
}

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<gc_SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo lowPriority:(BOOL)lowPriority
{
    // Bind gc_SDNetworkActivityIndicator if available (download it here: http://github.com/rs/gc_SDNetworkActivityIndicator )
    // To use it, just add #import "gc_SDNetworkActivityIndicator.h" in addition to the gc_SDWebImage import
    if (NSClassFromString(@"gc_SDNetworkActivityIndicator"))
    {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id activityIndicator = [NSClassFromString(@"gc_SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
#pragma clang diagnostic pop

        // Remove observer in case it was previously added.
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:gc_SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:gc_SDWebImageDownloadStopNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:gc_SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:gc_SDWebImageDownloadStopNotification object:nil];
    }

    gc_SDWebImageDownloader *downloader = gc_SDWIReturnAutoreleased([[gc_SDWebImageDownloader alloc] init]);
    downloader.url = url;
    downloader.delegate = delegate;
    downloader.userInfo = userInfo;
    downloader.lowPriority = lowPriority;
    [downloader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    return downloader;
}

+ (void)setMaxConcurrentDownloads:(NSUInteger)max
{
    // NOOP
}

- (void)start
{
    // In order to prevent from potential duplicate caching (NSURLCache + gc_SDImageCache) we disable the cache for image requests
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    self.connection = gc_SDWIReturnAutoreleased([[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO]);

    // If not in low priority mode, ensure we aren't blocked by UI manipulations (default runloop mode for NSURLConnection is NSEventTrackingRunLoopMode)
    if (!lowPriority)
    {
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    [connection start];
    gc_SDWIRelease(request);

    if (connection)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:gc_SDWebImageDownloadStartNotification object:nil];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
        {
            [delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:nil];
        }
    }
}

- (void)cancel
{
    if (connection)
    {
        [connection cancel];
        self.connection = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:gc_SDWebImageDownloadStopNotification object:nil];
    }
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
    if (![response respondsToSelector:@selector(statusCode)] || [((NSHTTPURLResponse *)response) statusCode] < 400)
    {
        expectedSize = response.expectedContentLength > 0 ? (NSUInteger)response.expectedContentLength : 0;
        self.imageData = gc_SDWIReturnAutoreleased([[NSMutableData alloc] initWithCapacity:expectedSize]);
    }
    else
    {
        [aConnection cancel];

        [[NSNotificationCenter defaultCenter] postNotificationName:gc_SDWebImageDownloadStopNotification object:nil];

        if ([delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
        {
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:[((NSHTTPURLResponse *)response) statusCode]
                                                    userInfo:nil];
            [delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:error];
            gc_SDWIRelease(error);
        }

        self.connection = nil;
        self.imageData = nil;
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [imageData appendData:data];

    if (CGImageSourceCreateImageAtIndex == NULL)
    {
        // ImageIO isn't present in iOS < 4
        self.progressive = NO;
    }

    if (self.progressive && expectedSize > 0 && [delegate respondsToSelector:@selector(imageDownloader:didUpdatePartialImage:)])
    {
        // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
        // Thanks to the author @Nyx0uf

        // Get the total bytes downloaded
        const NSUInteger totalSize = [imageData length];

        // Update the data source, we must pass ALL the data, not just the new bytes
        CGImageSourceRef imageSource = CGImageSourceCreateIncremental(NULL);
#if __has_feature(objc_arc)
        CGImageSourceUpdateData(imageSource, (__bridge  CFDataRef)imageData, totalSize == expectedSize);
#else
        CGImageSourceUpdateData(imageSource, (CFDataRef)imageData, totalSize == expectedSize);
#endif

        if (width + height == 0)
        {
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
            if (properties)
            {
                CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
                if (val) CFNumberGetValue(val, kCFNumberLongType, &height);
                val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
                if (val) CFNumberGetValue(val, kCFNumberLongType, &width);
                CFRelease(properties);
            }
        }

        if (width + height > 0 && totalSize < expectedSize)
        {
            // Create the image
            CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

#ifdef TARGET_OS_IPHONE
            // Workaround for iOS anamorphic image
            if (partialImageRef)
            {
                const size_t partialHeight = CGImageGetHeight(partialImageRef);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
                CGColorSpaceRelease(colorSpace);
                if (bmContext)
                {
                    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = partialHeight}, partialImageRef);
                    CGImageRelease(partialImageRef);
                    partialImageRef = CGBitmapContextCreateImage(bmContext);
                    CGContextRelease(bmContext);
                }
                else
                {
                    CGImageRelease(partialImageRef);
                    partialImageRef = nil;
                }
            }
#endif

            if (partialImageRef)
            {
                UIImage *image = gc_SDScaledImageForPath(url.absoluteString, [UIImage imageWithCGImage:partialImageRef]);
                [[gc_SDWebImageDecoder sharedImageDecoder] decodeImage:image
                                                       withDelegate:self
                                                           userInfo:[NSDictionary dictionaryWithObject:@"partial" forKey:@"type"]];

                CGImageRelease(partialImageRef);
            }
        }

        CFRelease(imageSource);
    }
}

#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    self.connection = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:gc_SDWebImageDownloadStopNotification object:nil];

    if ([delegate respondsToSelector:@selector(imageDownloaderDidFinish:)])
    {
        [delegate performSelector:@selector(imageDownloaderDidFinish:) withObject:self];
    }

    if ([delegate respondsToSelector:@selector(imageDownloader:didFinishWithImage:)])
    {
        UIImage *image = gc_SDScaledImageForPath(url.absoluteString, imageData);
        [[gc_SDWebImageDecoder sharedImageDecoder] decodeImage:image withDelegate:self userInfo:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:gc_SDWebImageDownloadStopNotification object:nil];

    if ([delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
    {
        [delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:error];
    }

    self.connection = nil;
    self.imageData = nil;
}

#pragma mark gc_SDWebImageDecoderDelegate

- (void)imageDecoder:(gc_SDWebImageDecoder *)decoder didFinishDecodingImage:(UIImage *)image userInfo:(NSDictionary *)aUserInfo
{
    if ([[aUserInfo valueForKey:@"type"] isEqualToString:@"partial"])
    {
        [delegate imageDownloader:self didUpdatePartialImage:image];
    }
    else
    {
        [delegate performSelector:@selector(imageDownloader:didFinishWithImage:) withObject:self withObject:image];
    }
}

#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    gc_SDWISafeRelease(url);
    gc_SDWISafeRelease(connection);
    gc_SDWISafeRelease(imageData);
    gc_SDWISafeRelease(userInfo);
    gc_SDWISuperDealoc;
}


@end
