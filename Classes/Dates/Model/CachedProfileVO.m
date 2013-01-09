//
//  CachedProfileVO.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 7/18/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "CachedProfileVO.h"


@implementation CachedProfileVO
@synthesize name, face, faceImg ;
@synthesize schools, works, musics, books, movies, hobbies, tvshows;
@synthesize photos;


- (void)dealloc
{
	
	[name release]; name = nil;
	[face release]; face = nil;
	[schools release]; schools = nil;
	[works release]; works = nil;
    [musics release]; musics = nil;
	[books release]; books = nil;
	[movies release]; movies = nil;
    [hobbies release]; hobbies = nil;
	[tvshows release]; tvshows = nil;
    [photos release]; photos = nil;
    [faceImg release]; faceImg = nil;
    [super dealloc];
	
}
@end
