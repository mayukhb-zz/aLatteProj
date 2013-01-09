//
//  IconDownloader.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 1/9/12.
//  Copyright (c) 2012 Individual. All rights reserved.
//

#import "IconDownloader.h"
#import "UIImage+Thumbnail.h"

#define kAppIconHeight 48


@implementation IconDownloader

@synthesize dateIcon;
@synthesize imgURLString;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize imageRequest;
@synthesize smallThumbnail;

#pragma mark

- (void)dealloc
{
    [dateIcon release];
    [imgURLString release];
    [indexPathInTableView release];

    [self.imageRequest clearDelegatesAndCancel];
    [imageRequest release];
    
    [super dealloc];
}

- (void)startDownload
{
    // alloc+init and start an CustomHttpRequest; release on completion/failure
    [self.imageRequest clearDelegatesAndCancel]; 
    self.imageRequest = [CustomHTTPRequest requestWithURL:[NSURL URLWithString:self.imgURLString]];
    [self.imageRequest setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [self.imageRequest setShouldContinueWhenAppEntersBackground:YES];
#endif
    //[request setUploadProgressDelegate:progressIndicator];
    [self.imageRequest setDelegate:self];
    [self.imageRequest setDidFailSelector:@selector(uploadFailed:)];
    [self.imageRequest setDidFinishSelector:@selector(uploadFinished:)];
    [self.imageRequest startAsynchronous];
    //[self retain];

}

- (void)cancelDownload
{
    //[self.imageRequest clearDelegatesAndCancel];
    self.imageRequest = nil;
    self.delegate = nil;

}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
    // Release the connection now that it's finished
   // [self.imageRequest clearDelegatesAndCancel];
    self.imageRequest = nil;
    self.delegate = nil;
    
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
    UIImage *image = [[UIImage alloc] initWithData:[theRequest responseData]];
    /*if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
	{
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.dateIcon = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else
    {*/
    if (self.smallThumbnail) {
        self.dateIcon = [image makeThumbnailOfSizeWithAspectFill:CGSizeMake(88, 88)];
    }
    else {
        self.dateIcon = image;
    }
        
    
    //}
    
    [image release];
    
    // Release the connection now that it's finished
    self.imageRequest = nil;
    
    // call our delegate and tell it that our icon is ready for display
    [self.delegate dateImageDidLoad:self.indexPathInTableView];
    self.delegate = nil;

    
}

@end

