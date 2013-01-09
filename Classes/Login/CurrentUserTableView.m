//
//  CurrentUserTableView.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/14/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "CurrentUserTableView.h"
#import "Common.h"
#import "Constants.h"
#import "ErrorHandler.h"
#import "DateMeAppDelegate.h"
#import "Tvshow.h"
#import "School.h"
#import "Book.h"
#import "Movie.h"
#import "Hobby.h"
#import "Music.h"
#import "Work.h"
#import "Photo.h"
#import "Revelations.h"

@implementation CurrentUserTableView

@synthesize cellText, request, request2;
@synthesize email, passwd;
@synthesize profile, managedObjectContext;
@synthesize spinner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        if (!self.managedObjectContext) {
            self.managedObjectContext = [(DateMeAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        }
        
    }
    return self;
}

- (void)dealloc
{
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel];
    [request release]; request = nil;
    [email release]; email = nil;
    [passwd release]; passwd = nil;
    [profile release]; profile = nil;
    [managedObjectContext release]; managedObjectContext = nil;
    [request2 release]; request2 = nil;
    [spinner release]; spinner = nil;
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
    [self.navigationController setNavigationBarHidden:NO animated:YES]; 
    self.navigationItem.title = @"Sign In"; 
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	[rightBarButtonItem release];
    
    [Common setTheme:self.parentViewController forTableView:self.tableView];
    
    //MBProgressHUD start
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [HUD setCenter:CGPointMake(160.0, 200.0)];
    //HUD.delegate = self;
	
    self.spinner = HUD;
    [HUD release]; HUD = nil;
	[self.view addSubview:self.spinner];
	
    //MBProgressHUD end
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.spinner = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4; /*v2 start changed from 3 v2 end*/
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    //Need to clear any settings before
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
	cell.textLabel.textColor = [UIColor colorWithRed:.1 green:0.4 blue:0.5 alpha:1];
	cell.textLabel.shadowColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.7];
    cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"";
        UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fbButton.clearsContextBeforeDrawing = NO;
        fbButton.frame =  CGRectMake(15, 0, 311, 50);
        UIImage *sendButtonBackground = [UIImage imageNamed:@"Facebook.png"];
        [fbButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
        
        [fbButton addTarget:self action:@selector(fbButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = fbButton;


    }
    else if (indexPath.section == 1) {
	
            
            UITextField *emailAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
            emailAccessoryView.delegate = self;
          //  emailAccessoryView.text = @"katy.perry@alatte.com";
        //self.email = @"katy.perry@alatte.com";
            emailAccessoryView.keyboardType = UIKeyboardTypeEmailAddress;
            emailAccessoryView.placeholder = @"Email";
            emailAccessoryView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            emailAccessoryView.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.accessoryView = emailAccessoryView;
            [emailAccessoryView release]; emailAccessoryView = nil;
    }
    else if (indexPath.section == 2)
    {
        
        UITextField *passwdAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
        passwdAccessoryView.delegate = self;
        passwdAccessoryView.placeholder = @"Password";
        passwdAccessoryView.secureTextEntry = YES;
        cell.accessoryView = passwdAccessoryView;
        [passwdAccessoryView release]; passwdAccessoryView = nil;   
    }
    else {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
     
        cell.textLabel.text = @"Forgot Password?";
        //add a logout button
        cell.backgroundColor = [UIColor clearColor];
        UIButton *resetPasswdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resetPasswdButton.clearsContextBeforeDrawing = NO;
        resetPasswdButton.frame = CGRectMake(0, 0, 80, 30);
        UIImage *sendButtonBackground = [UIImage imageNamed:@"SendButton.png"];
        [resetPasswdButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
        resetPasswdButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        resetPasswdButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [resetPasswdButton setTitle:@"Reset" forState:UIControlStateNormal];
        UIColor *shadowColor = [[UIColor alloc] initWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
        [resetPasswdButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
        [shadowColor release]; shadowColor = nil;
        
        [resetPasswdButton addTarget:self action:@selector(resetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = resetPasswdButton;
        //self.passwd = @"kperry";
    }
  
			
	cell.textLabel.backgroundColor = [UIColor clearColor];
	return cell;

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
		
	UITableViewCell *cell = (UITableViewCell *)[textField superview];
	NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    
    if(indexPath.section == 1){
        self.email = textField.text;
       
    }
    else if(indexPath.section == 2){
        self.passwd = textField.text;
    }
		return YES;
}	

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    // deselect the current table row
    [self.tableView deselectRowAtIndexPath:path animated:NO];
    self.cellText = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;	
}


- (void) doneAction
{
    //Resign textfield as firs responder
    if ([self.cellText isFirstResponder]) {
        [self.cellText resignFirstResponder];
    }
 
    //Send request to server to check for correct login
    [self sendLoginCredentialsToServer:NO];
    [self.spinner show:YES];
}

- (void) sendLoginCredentialsToServer:(BOOL) fb  //v2 added fb as parameter
{
    
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PUBLICPATH presentDialog:YES] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    /*v2 start*/
    if (fb) {
        [params setValue:@"Y" forKey:@"facebook"];
        self.passwd = [Common generateRandomString];
        [params setValue:self.passwd forKey:@"password"];
    }
    else {
        [params setValue:self.passwd forKey:@"password"];
    }
    /*v2 end*/
    
    [params setValue:self.email forKey:@"email"];
    [params setValue:@"login" forKey:@"script"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int userId = [prefs integerForKey:@"userId"] ;
    
    //NSString* userEmail = [prefs objectForKey:@"userEmail"]; v2
    if (userId == 0 /*![userEmail isEqualToString:self.email]*/) {
        [self.request setPostValue:@"download_profile" forKey:@"mode"];
        /*if (userId > 0) {
            [self cleanCoreData];
        }*/
    }
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_CURRENT_USER;
    [self.request setPostValues:params];
}


- (void)doneLoginCurrentUser:(BOOL) login profile:(NSArray*)profileArray school:(NSArray*) schoolArray work:(NSArray*) workArray music:(NSArray*) musicArray movie:(NSArray*) movieArray book:(NSArray*) bookArray hobby:(NSArray*) hobbyArray tvshow:(NSArray*) tvshowArray photo:(NSArray*) photoArray revelation:(NSArray *)revelationArray
{
    [CustomHTTPRequest storeUsername:self.email password:self.passwd];
    
    if (login) 
    {
        //This wont happen in V1 -- Mayukh
        [((DateMeAppDelegate *)[UIApplication sharedApplication].delegate) login];
        // [((DateMeAppDelegate *)[UIApplication sharedApplication].delegate).window addSubview:((DateMeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view];
        
        [self.spinner hide:YES];
        return;
    }
  
        //Remove any previously created entity - v2
        [self.managedObjectContext rollback]; 
        [self cleanCoreData];
        
        self.profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
          
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.email forKey:@"userEmail"];
        self.profile.email = self.email;
        [prefs setInteger:[[profileArray objectAtIndex:0] intValue] forKey:@"userId"];
        self.profile.userid = [prefs objectForKey:@"userId"];
        [prefs setObject:[profileArray objectAtIndex:1] forKey:@"userName"];
        self.profile.name = [prefs objectForKey:@"userName"];
        
       [prefs setInteger:25 forKey:@"range"];
        if ([ [profileArray objectAtIndex:2] isEqualToString:@"Male"]) {
            [prefs setBool:NO forKey:@"userSex"];
            self.profile.sex = @"Male";
            
            //Set reveal by default to Yes in NSUserDefaults for males
            [prefs setBool:YES forKey:@"revealByDefault"];
        }
        else
        {
            [prefs setBool:YES forKey:@"userSex"];
            self.profile.sex = @"Female";
            
            //Set reveal by default to No in NSUserDefaults for females
            [prefs setBool:NO forKey:@"revealByDefault"];
        }
    
        //Set sound preferences to YES
        [prefs setBool:YES forKey:@"sound"];
    
        //Set date of logging in for chat message download
        [prefs setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"messageStartDate"];
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:[profileArray objectAtIndex:3]];
        [dateFormatter release]; dateFormatter = nil;
        
        self.profile.dob = [NSNumber numberWithDouble:[date timeIntervalSince1970]]  ;
        self.profile.face = [profileArray objectAtIndex:4];
        [prefs setObject:self.profile.face forKey:@"userThumbnail"];
        if (![self.profile.face isEqualToString:@"null"]) { 
           
            [self.request clearDelegatesAndCancel];
            self.request = [CustomHTTPRequest requestWithURL:[NSURL URLWithString:self.profile.face]];
            [self.request addBasicAuthenticationHeaderWithUsername:CustomHTTPRequest.username
                                                  andPassword:CustomHTTPRequest.passwd];
            [self.request startSynchronous];
            NSError *error = [self.request error];
           
            if (!error) {
                self.profile.faceImg = [self.request responseData];
            }
             
        }
        //Update reveal by default in prefs
        [prefs setBool:[[profileArray objectAtIndex:5] boolValue] forKey:@"revealByDefault"];
        //Populate Coredata school objects
        for (NSString* obj in schoolArray) {
            if ([obj length] > 0) {
                School *school = [NSEntityDescription insertNewObjectForEntityForName:@"School" inManagedObjectContext:self.managedObjectContext];
                school.name = obj;
                [self.profile addSchoolsObject:school];
            }
        }
       
        //Populate Coredata work objects
        for (NSString* obj in workArray) {
            if ([obj length] > 0) {
            Work *work = [NSEntityDescription insertNewObjectForEntityForName:@"Work" inManagedObjectContext:self.managedObjectContext];
            work.name = obj;
			[self.profile addWorksObject:work];
            }
        }

        //Populate Coredata music objects
        for (NSString* obj in musicArray) {
            if ([obj length] > 0) {
            Music *music = [NSEntityDescription insertNewObjectForEntityForName:@"Music" inManagedObjectContext:self.managedObjectContext];
            music.name = obj;
			[self.profile addMusicsObject:music];
            }
        }

        //Populate Coredata movie objects
        for (NSString* obj in movieArray) {
            if ([obj length] > 0) {
            Movie *movie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.managedObjectContext];
            movie.name = obj;
			[self.profile addMoviesObject:movie];
            }
        }

        //Populate Coredata book objects
        for (NSString* obj in bookArray) {
            if ([obj length] > 0) {
            Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
            book.name = obj;
			[self.profile addBooksObject:book];
            }
        }

        //Populate Coredata hobby objects
        for (NSString* obj in hobbyArray) {
            if ([obj length] > 0) {
            Hobby *hobby = [NSEntityDescription insertNewObjectForEntityForName:@"Hobby" inManagedObjectContext:self.managedObjectContext];
            hobby.name = obj;
			[self.profile addHobbiesObject:hobby];
            }
        }

        //Populate Coredata tvshow objects
        for (NSString* obj in tvshowArray) {
            if ([obj length] > 0) {
            Tvshow *tvshow = [NSEntityDescription insertNewObjectForEntityForName:@"Tvshow" inManagedObjectContext:self.managedObjectContext];
            tvshow.name = obj;
			[self.profile addTvshowsObject:tvshow];
            }
        }

        //Populate Coredata photo objects
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        for (NSString* obj in photoArray) {
            if ([obj length] > 0) {
              
                NSArray* photoMetaData = [[NSArray alloc] initWithArray:[obj componentsSeparatedByString:@","]];
                
                Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                photo.serverPhotoId = [f numberFromString:[photoMetaData objectAtIndex:0]];
                photo.path = [photoMetaData objectAtIndex:1];
                photo.thumbnail = [f numberFromString:[photoMetaData objectAtIndex:2]];
                [self.profile addPhotosObject:photo];
                
                [photoMetaData release]; photoMetaData = nil;
            }
           
        }
        
        //Populate Coredata revelations objects
        for (NSString* obj in revelationArray) {
            if ([obj length] > 0) {
                
                Revelations *reveal = [NSEntityDescription insertNewObjectForEntityForName:@"Revelations" inManagedObjectContext:self.managedObjectContext];
                reveal.revealerUserId = self.profile.userid;
                reveal.revealedToUserId = [f numberFromString:obj];
                
            }
        }
        [f release]; f = nil;
    
        //Save data to Core Data as well
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
            [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
            exit(-1);  // Fail
        }
        [prefs synchronize];
        [self.spinner hide:YES];
        [((DateMeAppDelegate *)[UIApplication sharedApplication].delegate) login];        
      
}

- (void) cleanCoreData
{
    NSError *error = nil;
    NSFetchRequest *requestProfile = [[NSFetchRequest alloc] init];
    [requestProfile setEntity:[NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext]];
    [requestProfile setResultType:NSManagedObjectIDResultType];
   
    NSArray *profileObj = [self.managedObjectContext executeFetchRequest:requestProfile error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@", [error localizedDescription]); 
    
    NSManagedObjectID *profileId = [profileObj lastObject]; 
    
    if (profileId != nil) {

    [self.managedObjectContext deleteObject:[self.managedObjectContext objectWithID:profileId]];
    }

    [requestProfile release]; requestProfile = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} else  
    {
		[self resetPassword];
    }
	
}

- (void) resetButtonClicked{
	
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset password",  nil];
    
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	
	[actionSheet showInView:self.parentViewController.view];
	[actionSheet release];
    
}
- (void) resetPassword
{
    BOOL isEmailValid = [self validateEmailWithString:self.email];
    if (!isEmailValid) {
        [ErrorHandler displayString:@"Email is invalid" forDelegate:nil]; 
        return;
    }
    
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PUBLICPATH presentDialog:NO] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [CustomHTTPRequest storeUsername:self.email password:self.passwd];
    if (self.email) {
        [params setValue:self.email forKey:@"email"];
    }
    else {
        [params setValue:@"" forKey:@"email"];
    }
    [params setValue:@"resetpasswd" forKey:@"script"];
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_RESET_PASSWD;
    [self.request setPostValues:params];
    [self.spinner show:YES];
}

/*v2 start*/
- (void) fbButtonClicked
{
    DateMeAppDelegate *appDelegate = (DateMeAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //check for previously saved access token information
    if ([prefs objectForKey:@"FBAccessTokenKey"] 
        && [prefs objectForKey:@"FBExpirationDateKey"]) {
        appDelegate.facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
        appDelegate.facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
    }   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbLoginCurrentUser:) name:@"FBLoginComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLoginCurrentUser:) name:@"FBDidNotLogin" object:nil];
    [appDelegate.facebook authorize:nil];
   
}


- (void)fbLoginCurrentUser:(NSNotification *) notification {
    
    [self.spinner show:YES];
    // get email about the currently logged in user
    DateMeAppDelegate *appDelegate = (DateMeAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.facebook requestWithGraphPath:@"me/?fields=email" andDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)fbDidNotLoginCurrentUser:(NSNotification *) notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) request:(FBRequest *)request didFailWithError:(NSError *)error
{
    [ErrorHandler displayString:@"Cannot connect to Facebook. Please try later." forDelegate:nil];
    [self.spinner hide:YES];
    
}
- (void)request:(FBRequest *)request didLoad:(id)result
{
    [self parseJSONResult:result];
}

- (void) parseJSONResult:(id) result
{
    SBJSON *parser = [[SBJSON alloc] init];
    NSString *jsonString = [NSString stringWithString:[result JSONRepresentation]];
    NSDictionary *fbData = (NSDictionary *) [parser objectWithString:jsonString error:nil];  
    
    self.email = (NSString *) [fbData objectForKey:@"email"];
    
    //Send request to server 
    [parser release]; parser = nil;
    [self sendLoginCredentialsToServer:YES];

}
/*v2 end */

- (BOOL)validateEmailWithString:(NSString*)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:emailStr];
}

- (void) stopSpinner
{
    [self.spinner hide:YES];
}

@end
