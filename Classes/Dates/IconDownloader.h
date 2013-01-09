//
//  IconDownloader.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 1/9/12.
//  Copyright (c) 2012 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomHTTPRequest.h"

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    NSString *imgURLString;
    UIImage *dateIcon;
    NSIndexPath *indexPathInTableView;
    id <IconDownloaderDelegate> delegate;
    
    CustomHTTPRequest *imageRequest;
    BOOL smallThumbnail;
}

@property (nonatomic, retain) NSString *imgURLString;
@property (nonatomic, retain) UIImage *dateIcon;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, retain) id <IconDownloaderDelegate> delegate;
@property (nonatomic, assign) BOOL smallThumbnail;

@property (nonatomic, retain) CustomHTTPRequest *imageRequest;

- (void) startDownload;

@end

@protocol IconDownloaderDelegate 

- (void)dateImageDidLoad:(NSIndexPath *)indexPath;
@end
