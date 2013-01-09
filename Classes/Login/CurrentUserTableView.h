//
//  CurrentUserTableView.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/14/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHTTPRequest.h"
#import "ASIHTTPRequest.h"
#import "Profile.h"
#import "MBProgressHUD.h"
/*v2 start*/
#import "FBConnect.h"
#import "SBJSON.h"
/*v2 end*/

@interface CurrentUserTableView : UITableViewController<UITextFieldDelegate, CustomHTTPRequestDelegate, UIActionSheetDelegate/*v2 start*/, FBRequestDelegate/*v2 end*/> {
    
    UITextField *cellText;
    CustomHTTPRequest *request;
    ASIHTTPRequest * request2;
    NSString *email;
    NSString *passwd;
    Profile *profile;
    NSManagedObjectContext *managedObjectContext;
	MBProgressHUD *spinner;

}

@property (nonatomic, retain) UITextField *cellText;
@property (retain, nonatomic) CustomHTTPRequest *request;
@property (retain, nonatomic) ASIHTTPRequest *request2;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *passwd;
@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MBProgressHUD *spinner;
/*v2 start*/
- (void) fbButtonClicked;
/*v2 end */
- (void) doneAction;

- (void) sendLoginCredentialsToServer:(BOOL)fb; //v2 added fb and email as parameter
- (void) cleanCoreData;
- (void) resetPassword;
- (void) resetButtonClicked;
- (void) stopSpinner;

@end
