/*
 * This file is part of the gc_SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "gc_SDWebImageCompat.h"

@class gc_SDWebImageDownloader;

/**
 * Delegate protocol for gc_SDWebImageDownloader
 */
@protocol gc_SDWebImageDownloaderDelegate <NSObject>

@optional

- (void)imageDownloaderDidFinish:(gc_SDWebImageDownloader *)downloader;

/**
 * Called repeatedly while the image is downloading when [gc_SDWebImageDownloader progressive] is enabled.
 *
 * @param downloader The gc_SDWebImageDownloader instance
 * @param image The partial image representing the currently download portion of the image
 */
- (void)imageDownloader:(gc_SDWebImageDownloader *)downloader didUpdatePartialImage:(UIImage *)image;

/**
 * Called when download completed successfuly.
 *
 * @param downloader The gc_SDWebImageDownloader instance
 * @param image The downloaded image object
 */
- (void)imageDownloader:(gc_SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image;

/**
 * Called when an error occurred
 *
 * @param downloader The gc_SDWebImageDownloader instance
 * @param error The error details
 */
- (void)imageDownloader:(gc_SDWebImageDownloader *)downloader didFailWithError:(NSError *)error;

@end
