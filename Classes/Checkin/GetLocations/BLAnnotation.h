//
//  BLAnnotation.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface BLAnnotation : NSObject <MKAnnotation> {
@private
    CLLocationCoordinate2D _coordinate;
    NSString *_title;
	NSString *_subtitle;
}

@property (nonatomic, retain) NSString *_title;
@property (nonatomic, retain) NSString *_subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subtitle:(NSString *)subtitle;

@end
