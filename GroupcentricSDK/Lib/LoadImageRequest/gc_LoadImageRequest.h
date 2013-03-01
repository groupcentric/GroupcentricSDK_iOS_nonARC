#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface gc_LoadImageRequest : NSObject {
	UIImageView *delegate;
	
	BOOL finished;
	BOOL success;
	BOOL canceled;
	
	NSURLConnection *theConnection;
	NSMutableData *resultData;
	UIImage *resultImage;
}

@property (nonatomic, assign) UIImageView *delegate;

-(id)initWithResourceString:(NSString*)string;
-(id)init;

-(void)cancel;
-(void)cancelDelegate:(UIImageView*)object;

@end
