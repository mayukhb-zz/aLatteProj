//
//  LoginViewController.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/14/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "LoginViewController.h"
#import "NewUserTableView.h"
#import "CurrentUserTableView.h"
#import "Common.h"
#import "DateMeAppDelegate.h"

@implementation LoginViewController

@synthesize signupButton, loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) login
{
    CurrentUserTableView *currUser = [[CurrentUserTableView alloc] initWithNibName:@"CurrentUserTableView" bundle:nil];
    [self.navigationController pushViewController:currUser animated:YES];
    [currUser release]; currUser = nil;
}

- (void) signup
{
    NewUserTableView *newUser = [[NewUserTableView alloc] initWithNibName:@"NewUserTableView" bundle:nil];
    [self.navigationController pushViewController:newUser animated:YES];
    [newUser release]; newUser = nil;
}

- (void)dealloc
{
    [loginButton release]; loginButton = nil;
    [signupButton release]; signupButton = nil;
     [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *themeImg =  @"login.png";
    
    self.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:themeImg]];
   // [self.signupButton setImage:[UIImage imageNamed:@"launchbutton.png"] forState:UIControlStateNormal];
    //[self.loginButton setImage:[UIImage imageNamed:@"launchbutton.png"] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
   // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //int theme = [prefs integerForKey:@"theme"] ;
    //NSString *themeImg = theme == 1? @"Big-Water-Drops.jpg" : @"snow.jpg";
    //themeImg = @"cover.jpg";
    //self.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:themeImg]];
    

}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES]; 
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int userId = [prefs integerForKey:@"userId"] ;
    
    if (userId > 0 ) {
        self.signupButton.hidden = YES;
        self.loginButton.hidden = YES;
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
