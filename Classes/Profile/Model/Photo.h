//
//  Photo.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/27/11.
//  Copyright (c) 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * serverPhotoId;
@property (nonatomic, retain) NSNumber * thumbnail;
@property (nonatomic, retain) Profile *profile;

@end
