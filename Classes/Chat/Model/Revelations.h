//
//  Revelations.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 10/30/11.
//  Copyright (c) 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Revelations : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * revealerUserId;
@property (nonatomic, retain) NSNumber * revealedToUserId;

@end
