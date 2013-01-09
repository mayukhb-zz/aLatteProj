//
//  ErrorHandler.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 10/28/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ErrorHandler : NSObject {
    
}


+ (void) displayError: (NSError *) error forDelegate:(id) del;
+ (void) displayString: (NSString *) error forDelegate:(id) del;
+ (void) displayInfoString: (NSString *) info forDelegate:(id) del;
+ (void) displayString:(NSString *)error forDelegate:(id)del otherButton:(NSString*) otherButtonTitle;

@end
