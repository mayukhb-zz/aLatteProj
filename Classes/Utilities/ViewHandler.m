//
//  ViewHandler.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 10/19/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ViewHandler.h"


@implementation ViewHandler


+ (void) removeSubviewsFrom: (UIView *) view
{
    for (UIView *subView in [view subviews]) {
        [subView removeFromSuperview];
    }
}

+ (void) removeSubviewsFrom:(UIView *)view withTag: (NSInteger) tag
{
    for (UIView *subView in [view subviews]) {
        //Only remove the subview with tag 
        if (subView.tag == tag) {
            [subView removeFromSuperview];
            break;
        }
    }
}

@end
