//
//  DateMeAppDelegate.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CustomHTTPRequest.h"
/*v2 start*/
#import "FBConnect.h"
/*v2 end */
@class ChatPageViewController;


@interface DateMeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, CustomHTTPRequestDelegate/*v2 start*/,FBSessionDelegate/*v2 end*/> {
    UIWindow *window;
    UITabBarController *tabBarController;
    UINavigationController *navController;

    ChatPageViewController *chatView;

	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	
    
    CustomHTTPRequest *request;
    NSString *newDevToken;
    
    /*v2 start*/
    Facebook *facebook;
    /*v2 end*/
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet ChatPageViewController *chatView;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, retain) CustomHTTPRequest *request;
@property (nonatomic, retain) NSString *newDevToken;
/*v2 start*/
@property (nonatomic, retain) Facebook *facebook;
/*v2 end */

- (void) login;
- (void) logout;
- (void) sendProviderDeviceToken:(NSString*) token;
//-(IBAction)saveAction:sender;
@end
