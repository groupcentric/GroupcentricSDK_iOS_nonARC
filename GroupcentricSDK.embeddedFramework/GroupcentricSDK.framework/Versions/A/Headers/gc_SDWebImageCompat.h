/*
 * This file is part of the gc_SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Jamie Pinkham
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#ifndef UIImage
#define UIImage NSImage
#endif
#ifndef UIImageView
#define UIImageView NSImageView
#endif
#else
#import <UIKit/UIKit.h>
#endif

#if ! __has_feature(objc_arc)
#define gc_SDWIAutorelease(__v) ([__v autorelease]);
#define gc_SDWIReturnAutoreleased gc_SDWIAutorelease

#define gc_SDWIRetain(__v) ([__v retain]);
#define gc_SDWIReturnRetained gc_SDWIRetain

#define gc_SDWIRelease(__v) ([__v release]);
#define gc_SDWISafeRelease(__v) ([__v release], __v = nil);
#define gc_SDWISuperDealoc [super dealloc];

#define gc_SDWIWeak
#else
// -fobjc-arc
#define gc_SDWIAutorelease(__v)
#define gc_SDWIReturnAutoreleased(__v) (__v)

#define gc_SDWIRetain(__v)
#define gc_SDWIReturnRetained(__v) (__v)

#define gc_SDWIRelease(__v)
#define gc_SDWISafeRelease(__v) (__v = nil);
#define gc_SDWISuperDealoc

#define gc_SDWIWeak __unsafe_unretained
#endif


NS_INLINE UIImage *gc_SDScaledImageForPath(NSString *path, NSObject *imageOrData)
{
    if (!imageOrData)
    {
        return nil;
    }

    UIImage *image = nil;
    if ([imageOrData isKindOfClass:[NSData class]])
    {
        image = [[UIImage alloc] initWithData:(NSData *)imageOrData];
    }
    else if ([imageOrData isKindOfClass:[UIImage class]])
    {
        image = gc_SDWIReturnRetained((UIImage *)imageOrData);
    }
    else
    {
        return nil;
    }

    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        CGFloat scale = 1.0;
        if (path.length >= 8)
        {
            // Search @2x. at the end of the string, before a 3 to 4 extension length (only if key len is 8 or more @2x. + 4 len ext)
            NSRange range = [path rangeOfString:@"@2x." options:0 range:NSMakeRange(path.length - 8, 5)];
            if (range.location != NSNotFound)
            {
                scale = 2.0;
            }
        }

        UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
        gc_SDWISafeRelease(image)
        image = scaledImage;
    }

    return gc_SDWIReturnAutoreleased(image);
}
