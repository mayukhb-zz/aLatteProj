//
//  CachedProfileVO.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 7/18/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CachedProfileVO : NSObject {
    
    NSString *name;
    NSString *face;
    UIImage *faceImg;
    NSString *schools;
	NSString *works;
	NSString *musics;
	NSString *books;
	NSString *movies;
	NSString *hobbies;
	NSString *tvshows;
	NSArray *photos;

}

@property (nonatomic, retain) NSString *schools;
@property (nonatomic, retain) NSString *works;
@property (nonatomic, retain) NSString *musics;
@property (nonatomic, retain) NSString *books;
@property (nonatomic, retain) NSString *movies;
@property (nonatomic, retain) NSString *hobbies;
@property (nonatomic, retain) NSString *tvshows;
@property (nonatomic, retain) NSArray *photos;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *face;
@property (nonatomic, retain) UIImage *faceImg;

@end
