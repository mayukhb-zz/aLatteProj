//
//  Profile.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/27/11.
//  Copyright (c) 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book, Hobby, Movie, Music, Photo, School, Tvshow, Work;

@interface Profile : NSManagedObject

@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSNumber * dob;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * face;
@property (nonatomic, retain) NSData * faceImg;
@property (nonatomic, retain) NSSet *schools;
@property (nonatomic, retain) NSSet *movies;
@property (nonatomic, retain) NSSet *tvshows;
@property (nonatomic, retain) NSSet *hobbies;
@property (nonatomic, retain) NSSet *books;
@property (nonatomic, retain) NSSet *musics;
@property (nonatomic, retain) NSSet *works;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Profile (CoreDataGeneratedAccessors)

- (void)addSchoolsObject:(School *)value;
- (void)removeSchoolsObject:(School *)value;
- (void)addSchools:(NSSet *)values;
- (void)removeSchools:(NSSet *)values;
- (void)addMoviesObject:(Movie *)value;
- (void)removeMoviesObject:(Movie *)value;
- (void)addMovies:(NSSet *)values;
- (void)removeMovies:(NSSet *)values;
- (void)addTvshowsObject:(Tvshow *)value;
- (void)removeTvshowsObject:(Tvshow *)value;
- (void)addTvshows:(NSSet *)values;
- (void)removeTvshows:(NSSet *)values;
- (void)addHobbiesObject:(Hobby *)value;
- (void)removeHobbiesObject:(Hobby *)value;
- (void)addHobbies:(NSSet *)values;
- (void)removeHobbies:(NSSet *)values;
- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;
- (void)addMusicsObject:(Music *)value;
- (void)removeMusicsObject:(Music *)value;
- (void)addMusics:(NSSet *)values;
- (void)removeMusics:(NSSet *)values;
- (void)addWorksObject:(Work *)value;
- (void)removeWorksObject:(Work *)value;
- (void)addWorks:(NSSet *)values;
- (void)removeWorks:(NSSet *)values;
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end
