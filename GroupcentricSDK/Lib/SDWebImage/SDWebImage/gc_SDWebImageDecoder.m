/*
 * This file is part of the gc_SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * Created by james <https://github.com/mystcolor> on 9/28/11.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "gc_SDWebImageDecoder.h"

#define DECOMPRESSED_IMAGE_KEY @"decompressedImage"
#define DECODE_INFO_KEY @"decodeInfo"

#define IMAGE_KEY @"image"
#define DELEGATE_KEY @"delegate"
#define USER_INFO_KEY @"userInfo"

@implementation gc_SDWebImageDecoder
static gc_SDWebImageDecoder *sharedInstance;

- (void)notifyDelegateOnMainThreadWithInfo:(NSDictionary *)dict
{
    gc_SDWIRetain(dict);
    NSDictionary *decodeInfo = [dict objectForKey:DECODE_INFO_KEY];
    UIImage *decodedImage = [dict objectForKey:DECOMPRESSED_IMAGE_KEY];

    id <gc_SDWebImageDecoderDelegate> delegate = [decodeInfo objectForKey:DELEGATE_KEY];
    NSDictionary *userInfo = [decodeInfo objectForKey:USER_INFO_KEY];

    [delegate imageDecoder:self didFinishDecodingImage:decodedImage userInfo:userInfo];
    gc_SDWIRelease(dict);
}

- (void)decodeImageWithInfo:(NSDictionary *)decodeInfo
{
    UIImage *image = [decodeInfo objectForKey:IMAGE_KEY];

    UIImage *decompressedImage = [UIImage decodedImageWithImage:image];
    if (!decompressedImage)
    {
        // If really have any error occurs, we use the original image at this moment
        decompressedImage = image;
    }

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          decompressedImage, DECOMPRESSED_IMAGE_KEY,
                          decodeInfo, DECODE_INFO_KEY, nil];

    [self performSelectorOnMainThread:@selector(notifyDelegateOnMainThreadWithInfo:) withObject:dict waitUntilDone:NO];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Initialization code here.
        imageDecodingQueue = [[NSOperationQueue alloc] init];
    }

    return self;
}

- (void)decodeImage:(UIImage *)image withDelegate:(id<gc_SDWebImageDecoderDelegate>)delegate userInfo:(NSDictionary *)info
{
    NSDictionary *decodeInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                image, IMAGE_KEY,
                                delegate, DELEGATE_KEY,
                                info, USER_INFO_KEY, nil];

    NSOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(decodeImageWithInfo:) object:decodeInfo];
    [imageDecodingQueue addOperation:operation];
    gc_SDWIRelease(operation);
}

- (void)dealloc
{
    gc_SDWISafeRelease(imageDecodingQueue);
    gc_SDWISuperDealoc;
}

+ (gc_SDWebImageDecoder *)sharedImageDecoder
{
    if (!sharedInstance)
    {
        sharedInstance = [[gc_SDWebImageDecoder alloc] init];
    }
    return sharedInstance;
}

@end


@implementation UIImage (ForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);

    BOOL imageHasAlphaInfo = (alphaInfo != kCGImageAlphaNone &&
                              alphaInfo != kCGImageAlphaNoneSkipFirst &&
                              alphaInfo != kCGImageAlphaNoneSkipLast);

    int bytesPerPixel = imageHasAlphaInfo ? 4 : 3;
    CGBitmapInfo bitmapInfo = imageHasAlphaInfo ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNone;

    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(imageRef),
                                                 CGImageGetHeight(imageRef),
                                                 8,
                                                 // Just always return width * bytesPerPixel will be enough
                                                 CGImageGetWidth(imageRef) * bytesPerPixel,
                                                 // System only supports RGB, set explicitly
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;

    CGRect rect = (CGRect){CGPointZero,{CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)}};
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return gc_SDWIReturnAutoreleased(decompressedImage);
}

@end
