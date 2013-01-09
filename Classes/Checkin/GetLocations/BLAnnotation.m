//
//  BLAnnotation.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//
#import "BLAnnotation.h"


@implementation BLAnnotation

@synthesize coordinate = _coordinate;
@synthesize _title;
@synthesize _subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subtitle:(NSString *)subtitle
{
    if ((self = [super init]))
	{
        
		_coordinate = coordinate;
        self._title = title;
		self._subtitle = subtitle;
    }
    return self;
}

- (NSString *)title {
    return self._title;
}

- (NSString *)subtitle
{
    return self._subtitle;
}

- (void)dealloc {
    [_title release]; _title = nil;
	[_subtitle release]; _subtitle = nil;
    [super dealloc];
}

@end
