//
//  MyPhotoSource.m
//  EGOPhotoViewerDemo_iPad
//
//  Created by Devin Doty on 7/3/10July3.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyPhotoSource.h"


@implementation MyPhotoSource

@synthesize photos=_photos;
@synthesize numberOfPhotos=_numberOfPhotos;


- (id)initWithPhotos:(NSMutableArray*)photos{
	
	if (self = [super init]) {
		
		_photos = [photos retain];
		_numberOfPhotos = [_photos count];
		
	}
	
	return self;

}

- (id <EGOPhoto>)photoAtIndex:(NSInteger)index{
	
	return [_photos objectAtIndex:index];
	
}

- (void) addPhoto:(MyPhoto *)photo{
	
	[_photos addObject:photo];
	_numberOfPhotos += 1;
}

//Code addition by Mayukh start
- (void) deletePhotoAtIndex:(NSInteger)index
{
    [_photos removeObjectAtIndex:index];
    _numberOfPhotos -= 1;
}

/*- (void) addPhoto:(MyPhoto *)photo atIndex:(NSInteger) index{
	
	[_photos insertObject:photo atIndex:index];
	_numberOfPhotos += 1;
}
*/
//Code addition my Mayukh end

- (void)dealloc{
	
	[_photos release], _photos=nil;
	[super dealloc];
}

@end
