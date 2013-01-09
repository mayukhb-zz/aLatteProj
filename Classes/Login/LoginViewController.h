//
//  LoginViewController.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/14/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LoginViewController : UIViewController {
    
    IBOutlet UIButton *signupButton;
    IBOutlet UIButton *loginButton;
 
}

@property (nonatomic, retain) IBOutlet UIButton *signupButton;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

- (IBAction) login;
- (IBAction) signup;

@end
