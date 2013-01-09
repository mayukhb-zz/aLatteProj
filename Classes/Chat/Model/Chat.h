//
//  Chat.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 9/19/11.
//  Copyright (c) 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chat : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * sentDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * inBound;

@end
