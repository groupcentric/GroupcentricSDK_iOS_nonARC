#import "gc_LoadImageRequest.h"



@implementation gc_LoadImageRequest

@synthesize delegate;



#pragma mark -
#pragma mark Memory Management

-(id)init {
	NSLog(@"-(id)init is not a valid method for LoadImageRequest.");
	return nil;
}

-(id)initWithResourceString:(NSString*)string {
	//if (!string || ![string length]) {
	//	return nil;
	//}
    
    if (!string || ![string length]) {
        string = @"http://images1.wikia.nocookie.net/__cb20090901163013/uncyclopedia/images/e/eb/Blank.jpg";
    }
	
	if ((self = [super init])) {
		if ([string characterAtIndex:0] == '/') {
			// we have a local resource
			resultImage = [[UIImage imageNamed:[string lastPathComponent]] retain];
			resultData = nil;
			theConnection = nil;
			finished = YES;
			success = YES;
		} else {
			// we have a remote resource
			finished = NO;
			success = NO;
			resultData = nil;
			resultImage = nil;
			
			NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:string]];
			
			theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
			if (!theConnection){
				NSLog(@"LoadImageRequest: theConnection is NULL");
				finished = YES;
			}
			
			[request release];
		}
	}
	
	return self;
}

-(void)dealloc {
	[theConnection release];
	[resultData release];
	[resultImage release];
	[super dealloc];
}

-(void)cancel {
	canceled = YES;
	finished = YES;
	success = NO;
	
	[theConnection cancel];
	[delegate release];
	delegate = nil;
}



#pragma mark -
#pragma mark NSURLConnection Delegation

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
	if (!canceled) {
		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
		if ( ([httpResponse statusCode]/100) == 2 ) {
			resultData = [[NSMutableData alloc] init];
		} else {
			NSLog(@"LoadImageRequest: Connection response status %d.", [httpResponse statusCode]);
			finished = YES;
			[delegate release];
			delegate = nil;
			[theConnection release];
			theConnection = nil;
		}
	}
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
	if (!canceled) {
		[resultData appendData:data];
	}
}

//- (NSCachedURLResponse*)connection:(NSURLConnection*)connection
//				 willCacheResponse:(NSCachedURLResponse*)cachedResponse {
//	return cachedResponse;
//}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
	if (!canceled) {
		finished = YES;
		success = YES;
		resultImage = [[UIImage alloc] initWithData:resultData];
		
		// if the delegate is a legal object,
		// than we can just pass the image to it and release it
		// we have no work with that object
//		if ([delegate respondsToSelector:@selector(setImage:)]) {
//			[delegate setImage:resultImage];
//		}
		if (!delegate.highlighted) {
			[delegate setImage:resultImage];
			[delegate setHighlightedImage:resultImage];
			delegate.highlighted = YES;
		}
	}
	
	[delegate release];
	delegate = nil;
	[resultData release];
	resultData = nil;
	[theConnection release];
	theConnection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
	if (!canceled) {
		NSLog(@"LoadImageRequest: %@", [error description]);
		finished = YES;
	}
	
	[delegate release];
	delegate = nil;
	[resultData release];
	resultData = nil;
	[theConnection release];
	theConnection = nil;
}



#pragma mark -
#pragma mark Property Methods

-(void)setDelegate:(UIImageView *)imageView {
	if (!canceled) {
		[delegate release];
		delegate = [imageView retain];
		
		if (success) {
			// if the delegate is a legal object and we have finished downloading the data successfully
			// we can set the image and release the data
			if (!delegate.highlighted) {
				[delegate setImage:resultImage];
				[delegate setHighlightedImage:resultImage];
				delegate.highlighted = YES;
			}
		}
	}
}

-(void)cancelDelegate:(UIImageView *)object {
	if (!canceled) {
		if (object == delegate) {
			[delegate release];
			delegate = nil;
		}
	}
}

@end
