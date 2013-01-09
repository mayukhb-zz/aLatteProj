//
//  MapLocationVO.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapLocationVO : NSObject {
	NSMutableString *locationTitle;
	NSMutableString *locationSnippet;
	CLLocation *mapLocation;
	float distance;
    NSString *type; //v2
	
}

@property (nonatomic, retain) NSMutableString *locationTitle;
@property (nonatomic, retain) NSMutableString *locationSnippet;
@property (nonatomic, retain) CLLocation *mapLocation;
@property  float distance;
@property (nonatomic, retain) NSString *type; //v2


//- (id)initWith:(MapLocationVO*) map;

@end
