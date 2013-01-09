//
//  Music.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 6/28/11.
//  Copyright (c) 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile;

@interface Music : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Profile * profile;

@end
