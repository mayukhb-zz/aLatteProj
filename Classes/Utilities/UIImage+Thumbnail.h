//
//  UIImage+Thumbnail.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/24/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImage_Thumbnail)

- (UIImage *) makeThumbnailOfSize:(CGSize)size;
- (UIImage *) makeThumbnailOfSizeWithAspectFill:(CGSize)targetSize;
//- (UIImage*) makeThumbnailForImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

@end
