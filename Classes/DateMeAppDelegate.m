//
//  DateMeAppDelegate.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "DateMeAppDelegate.h"
#import "CustomHTTPRequest.h"
#import "Constants.h"
#import "ChatPageViewController.h"
#import "Appirater.h" // v2

@implementation DateMeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize chatView;
@synthesize navController;
@synthesize newDevToken;
@synthesize request;
/*v2 start*/
@synthesize facebook;
/*v2 end*/

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Override point for customization after application launch.
    
 	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
		NSLog(@"Unresolved error (no context)");
		exit(-1);  // Fail
	}
   [self.chatView setManagedObjectContext:self.managedObjectContext];
 
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    int userId = [prefs integerForKey:@"userId"] ;
    if ((userId > 0 && [CustomHTTPRequest loggedIn])) {
        
        [self.chatView pollForNewMessages];
        [self.window addSubview:tabBarController.view];
    }
    else{
        [self.window addSubview:navController.view];
    }

    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    int newMessageCount = [prefs integerForKey:@"newMessageCount"] ;
    if (newMessageCount > 0) {
        [[[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", newMessageCount]];
        
    }
 
    application.applicationIconBadgeNumber = 0;
    // Appirater Integration v2
    [Appirater setAppId:APPID];
    [Appirater appLaunched:YES];
    [Appirater setDaysUntilPrompt:20];//20
    [Appirater setUsesUntilPrompt:10];//10
     
    //This instance is used to invoke FB SSO, as well as the Graph API and Platform Dialogs from within the app.
    facebook = [[Facebook alloc] initWithAppId:@"434149259962925" andDelegate:self];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self.chatView saveNewMessageCount];
    [self.chatView stopPollingForMessages];
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    //Restart polling for new messages
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int userId = [prefs integerForKey:@"userId"] ;
    if (userId > 0 && [CustomHTTPRequest loggedIn]) {
        
        [self.chatView pollForNewMessages];
       
    }
    
    //In the unlikely scenario where the devicetoken was not registered on server side on initial launch
    NSString *newToken = [prefs valueForKey:@"pushDeviceToken"];
    if (userId > 0 && [CustomHTTPRequest loggedIn] && ![prefs boolForKey:@"registered"] && newToken != nil) {
        [self sendProviderDeviceToken:newToken];
    }
    application.applicationIconBadgeNumber = 0;
    // Appirater Integration v2
    [Appirater appEnteredForeground:YES];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    
   [self.chatView saveNewMessageCount];
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Profiles.sqlite"];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Profile" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark - Push Notification

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
  
    NSString *newToken = [devToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
   
    self.newDevToken = newToken;
    //Set the values in NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *currentDeviceToken = [prefs stringForKey:@"pushDeviceToken"];
    
    if ([newToken isEqualToString:currentDeviceToken] && [prefs boolForKey:@"registered"]) {
        return;
    }
   
    int userId = [prefs integerForKey:@"userId"] ;
    if (userId > 0 && [CustomHTTPRequest loggedIn]) {
        [self sendProviderDeviceToken:newToken];
    }    
    [prefs setValue:newToken forKey:@"pushDeviceToken"];
    [prefs synchronize];
    
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	//NSLog(@"Received notification: %@", userInfo);
   // [self.chatView pollForNewMessages];
 	//[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

#pragma mark - Login/Logout methods

- (void) login
{
    [self.navController.view removeFromSuperview];
    [navController release]; navController = nil;
   // UITabBarController *tabBarCtrl = [[UITabBarController alloc] init]
    [self.window addSubview:self.tabBarController.view];
}
- (void) logout
{
    for (UINavigationController* ctrl in self.tabBarController.viewControllers) {
        //     NSLog(@"nav controller %@", ctrl);
        [ctrl popToRootViewControllerAnimated:NO];
        //   NSLog(@"visible controller %@", ctrl.visibleViewController);
        //  if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        //{
        ctrl.visibleViewController.view = nil;
       // [ctrl.visibleViewController release];
        //[ctrl release];
        //}
        //else
        //{
        //  ctrl.visibleViewController.view = nil;
        //[[ctrl viewControllers] objectAtIndex:0]
        //}
        
        
        
    }
    
    [self.tabBarController.view removeFromSuperview];
    [tabBarController release]; tabBarController = nil;
    [self.window addSubview:navController.view];
    self.tabBarController.selectedIndex = 0;
    

}

- (void) sendProviderDeviceToken:(NSString*) token
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.request clearDelegatesAndCancel]; 
    NSNumber* userId = [[NSNumber alloc ] initWithInt:[prefs integerForKey:@"userId"]];
    
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:NO] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:userId forKey:@"userid"];
    [params setValue:token forKey:@"token"];
    [userId release]; userId = nil;
    [params setValue:@"registerdevicetoken" forKey:@"script"];
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_DEVICE_TOKEN_REGISTRATION;
    [self.request setPostValues:params];
    
}

- (void) providerDeviceTokenSent
{
     //Set the values in NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"registered"];
    [prefs synchronize];
    //[prefs setValue:self.newDevToken forKey:@"pushDeviceToken"];
    
}

/*v2 start facebook integration */
// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FBLoginComplete" object:nil];
    
}
- (void)fbDidNotLogin:(BOOL)cancelled
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FBDidNotLogin" object:nil];
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    
}
- (void)fbDidLogout
{
    
}

- (void)fbSessionInvalidated
{
    
}
/* v2 end facebook integration*/

- (void)dealloc {
    [tabBarController release]; tabBarController = nil;
    [navController release]; navController = nil;
    [window release]; window= nil;
	
	[managedObjectContext release]; managedObjectContext = nil;
    [managedObjectModel release]; managedObjectModel = nil;
    [persistentStoreCoordinator release]; persistentStoreCoordinator = nil;
	[newDevToken release]; newDevToken = nil;
    
    [self.request clearDelegatesAndCancel];
    self.request.customHTTPDelegate = nil;
    [request release]; request = nil;
    /*v2 start*/
    [facebook release]; facebook = nil;
    /*v2 end*/

    [super dealloc];
}

@end

