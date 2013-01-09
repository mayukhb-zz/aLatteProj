//
//  CustomBadge.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 9/23/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomBadge : UIView {
    
    NSString *badgeText;
    UIColor *badgeTextColor;
    UIColor *badgeInsetColor;
    UIColor *badgeFrameColor;
    BOOL badgeFrame;
    CGFloat badgeCornerRoundness;
    
}

@property(nonatomic,retain) NSString *badgeText;
@property(nonatomic,retain) UIColor *badgeTextColor;
@property(nonatomic,retain) UIColor *badgeInsetColor;
@property(nonatomic,retain) UIColor *badgeFrameColor;
@property(nonatomic,readwrite) BOOL badgeFrame;
@property(nonatomic,readwrite) CGFloat badgeCornerRoundness;

+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString;
+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString withStringColor:(UIColor*)stringColor withInsetColor:(UIColor*)insetColor withBadgeFrame:(BOOL)badgeFrameYesNo withBadgeFrameColor:(UIColor*)frameColor;
- (void) autoBadgeSizeWithString:(NSString *)badgeString;
@end
