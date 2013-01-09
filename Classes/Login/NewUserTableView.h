//
//  NewUserTableView.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/14/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHTTPRequest.h"
#import <CoreData/CoreData.h>
#import "Profile.h"
#import "MBProgressHUD.h"
/*v2 start*/
#import "FBConnect.h"
#import "SBJSON.h"
/*v2 end*/

@interface NewUserTableView : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate, CustomHTTPRequestDelegate/*v2 start*/, FBRequestDelegate/*v2 end*/> {
    
    UIDatePicker *pickerView;
    UIPickerView *sexPickerView;
	NSDateFormatter *dateFormatter;
    
    NSManagedObjectContext *managedObjectContext;
	CustomHTTPRequest *request;
    Profile *profile;
    NSString *name;
    NSString *email;
    NSString *sex;
    NSNumber *dob;
    NSString *passwd;
    NSString *rePasswd;
    NSArray *sectionFooter;
   // UITapGestureRecognizer *gestureRecognizer;
    
    UITextField *cellText;
    MBProgressHUD *spinner;
    /*v2 start*/
    int numSections;
    /*v2 end*/
}

@property (nonatomic, retain) NSDateFormatter *dateFormatter; 
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, retain) IBOutlet UIPickerView *sexPickerView;

@property (nonatomic, retain) UITextField *cellText;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	
@property (retain, nonatomic) CustomHTTPRequest *request;
@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) NSString* passwd;
@property (nonatomic, retain) NSString* rePasswd;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *sex;
@property (nonatomic, retain) NSNumber *dob;

@property (nonatomic, retain) NSArray *sectionFooter;
//@property (nonatomic, retain) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic, retain) MBProgressHUD *spinner;
/*v2 start*/
- (void) fbButtonClicked;
/*v2 end */
- (void) doneAction;
//- (void) okAction;
- (void) slideDownDidStop;
- (void) clearPickerView;
- (void) uploadProfileToServer:(BOOL) fbook;
- (BOOL) validateEmailWithString: (NSString*) email;
- (BOOL) validateDob: (NSNumber*) dob;
- (BOOL) validateProfile;
- (BOOL) validatePassword: (NSString*) password;
- (BOOL) validatePassword: (NSString*) password withConfirm: (NSString*) rePassword;
- (void) datePicked;
- (void)backgroundTap;
- (void) initializeGender:(NSIndexPath *)indexPath;
- (void) termsClicked;
- (void) stopSpinner;
@end
