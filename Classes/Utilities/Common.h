//
//  Common.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 6/30/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Common : NSObject {
    
    NSString *locTitle;
    CLLocation *loc;
    NSNumber *userid;
}

+ (Common *) sharedInstance;
+ (void) setTheme:(UIViewController*) vc forTableView: (UITableView *) t;
+ (void) setUIViewTheme:(UIView*) vc forTableView: (UITableView *) t;
+ (void) setSearchViewTheme: (UITableView *) t;
+ (void) setTheme:(UIViewController*) vc ;
/*v2 start */
+ (NSString*) generateRandomString;
/*v2 end */

@property (nonatomic, retain) NSNumber *userid;  
@property (nonatomic, assign) int tabBarHeight;
@property (nonatomic, assign) int navBarHeight;

@end
