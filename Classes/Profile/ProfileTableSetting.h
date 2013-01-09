//
//  ProfileTableSetting.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/2/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Profile.h"
#import "CustomHTTPRequest.h"

@interface ProfileTableSetting : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, CustomHTTPRequestDelegate> {
    
    NSArray *sectionTitle;
    NSManagedObjectContext *managedObjectContext;
	Profile *profile;
    CustomHTTPRequest *request;
    NSString *passwd;
    UITextField *cellText;
    BOOL passwdChanged;
    BOOL revealByDefault;
    BOOL revealSettingChanged;
   
}

@property (nonatomic, retain) NSArray *sectionTitle;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	
@property (nonatomic, retain) Profile *profile;
@property (retain, nonatomic) CustomHTTPRequest *request;
@property (retain, nonatomic) NSString* passwd;
@property (nonatomic, retain) UITextField *cellText;
@property (nonatomic, assign) BOOL passwdChanged;
@property (nonatomic, assign) BOOL revealByDefault;
@property (nonatomic, assign) BOOL revealSettingChanged;

- (void) updateSoundPref: (id)sender;
- (void) updateRevealPref:(id)sender;
- (void) updateRangePref:(id)sender;
//- (void) logout;
//- (void) actionButtonHit: (id) sender;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (BOOL) validatePassword: (NSString*) password;
- (void) uploadToServer;

@end
