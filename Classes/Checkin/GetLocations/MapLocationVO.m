//
//  MapLocationVO.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "MapLocationVO.h"


@implementation MapLocationVO

@synthesize locationTitle, locationSnippet, mapLocation, distance; 
@synthesize type; //v2

- (void)dealloc
{
	
	[locationTitle release]; locationTitle = nil;
	[locationSnippet release]; locationSnippet = nil;
	[mapLocation release]; mapLocation = nil;
    [type release]; type = nil; //v2
    [super dealloc];
}

@end
