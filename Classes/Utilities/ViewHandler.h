//
//  ViewHandler.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 10/19/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ViewHandler : NSObject {
    
}

+ (void) removeSubviewsFrom: (UIView *) view;
+ (void) removeSubviewsFrom:(UIView *)view withTag: (NSInteger) tag;
@end
