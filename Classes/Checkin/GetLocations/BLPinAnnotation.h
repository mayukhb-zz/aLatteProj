//
//  BLPinAnnotation.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BLPinAnnotation : MKAnnotationView {
	UIView *calloutView;
	UILabel *titleLabel;
	UILabel *subtitleLabel;
	UIImage *normalPin;
	UIImage *selectedPin;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;

-(void)setSelected:(BOOL)selected animated:(BOOL)animated;
-(CGPathRef) createRoundedRectPath:(CGRect)rect radius:(CGFloat)radius;

@end
