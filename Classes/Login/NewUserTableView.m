//
//  NewUserTableView.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/14/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "NewUserTableView.h"
#import "DateMeAppDelegate.h"
#import "Common.h"
#import "Constants.h"
#import "ErrorHandler.h"
#import "TermsController.h"
#import "Tvshow.h"
#import "School.h"
#import "Book.h"
#import "Movie.h"
#import "Hobby.h"
#import "Music.h"
#import "Work.h"
#import "Photo.h"


@implementation NewUserTableView

@synthesize sexPickerView, dateFormatter, pickerView;
@synthesize cellText;
@synthesize request, managedObjectContext;
@synthesize profile, passwd, rePasswd, name, email, sex, dob;
@synthesize sectionFooter;
//@synthesize gestureRecognizer;
@synthesize spinner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

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
    [sexPickerView release]; sexPickerView = nil;
    [dateFormatter release]; dateFormatter = nil;
    [pickerView release]; pickerView = nil;
    
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel];
    [request release]; request = nil;
    [managedObjectContext release]; managedObjectContext = nil;
    [profile release]; profile = nil;
    [passwd release]; passwd = nil;
    [rePasswd release]; rePasswd = nil;
    [sectionFooter release]; sectionFooter = nil;
    //[gestureRecognizer release]; gestureRecognizer = nil;
    [name release]; name = nil;
    [email release]; email = nil;
    [sex release]; sex = nil;
    [dob release]; dob = nil;
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
    numSections = 2; // v2
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
       // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	[rightBarButtonItem release];
    self.navigationItem.title = @"Sign Up"; 
    

    NSArray *tempSectionFooter = [[NSArray alloc ] initWithObjects:@"",@"",@"To login and reset forgotten password", @"So that we can match you", @"We will keep this private",@"To secure your information",@"Terms of services", nil];
	self.sectionFooter = tempSectionFooter;
    [tempSectionFooter release]; tempSectionFooter = nil;
    
    [Common setTheme:self.parentViewController forTableView:self.tableView];
    
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    //MBProgressHUD start
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [HUD setCenter:CGPointMake(160.0, 200.0)];
	
    self.spinner = HUD;
    [HUD release]; HUD = nil;
	[self.view addSubview:self.spinner];
	
	 //MBProgressHUD end
    
    /*self.gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)] autorelease];
    self.gestureRecognizer.numberOfTapsRequired=1;
    self.gestureRecognizer.numberOfTouchesRequired=1;
    self.gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.gestureRecognizer];*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.pickerView = nil;
    self.sexPickerView = nil;
    self.cellText = nil;
    //self.gestureRecognizer = nil;
    self.spinner = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
		[self clearPickerView];
    } 
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
    return 7; //v2 earlier it was 7
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
   return 1;
    
  }

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
    if (section == 1) { //v2 was section == 0 before
        return 25; //v2 was 40 before
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	
    return [self.sectionFooter objectAtIndex:section];
}
/*
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (self.pickerView.superview != nil indexPath.section == 3 || indexPath.section == 4) {
        return NO;
    }
    else
        return YES;
    
    if ([touch.view isDescendantOfView:self.tableView]) {
        NSLog(@"descendant");
        return NO;
    }
   // return YES;
//}*/

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
        [self clearPickerView];
    }
}
- (void)backgroundTap{ 
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
        [self clearPickerView];
    }
}


-(CGFloat)tableView:(UITableView *)tv heightForFooterInSection:(NSInteger)section
{
    if (section >1) {
        return 17;
    }
    else
        return 0;
}


-(CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (indexPath.section == 0) {
        return 0;
    }*/
    return 40;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    if (section == 1){
       // return nil;
        /*v2 start */
        
        
        
        
       /* UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fbButton.clearsContextBeforeDrawing = NO;
        fbButton.frame = CGRectZero;
        UIImage *sendButtonBackground = [UIImage imageNamed:@"SendButton.png"];
        [fbButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
        fbButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        fbButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [fbButton setTitle:@"Facebook Login" forState:UIControlStateNormal];
        UIColor *shadowColor = [[UIColor alloc] initWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
        [fbButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
        [shadowColor release]; shadowColor = nil;
        
        [fbButton addTarget:self action:@selector(fbButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        */
        UILabel *headerView = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        
        headerView.text = @"Or tell us about yourself";
        headerView.textAlignment = UITextAlignmentCenter;
        headerView.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        headerView.textColor = [UIColor colorWithRed:.1 green:0.4 blue:0.5 alpha:1];
        headerView.shadowColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.7];
        headerView.shadowOffset = CGSizeMake(0, -1.0);
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
        //[facebookView addSubview:headerView];
        //return fbButton;
    }
    return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 6){
        UIButton *termsFooter = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        
        [termsFooter setTitle:@"Terms of services" forState:UIControlStateNormal];
        termsFooter.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [termsFooter setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [termsFooter addTarget:self action:@selector(termsClicked) forControlEvents:UIControlEventTouchUpInside];
        return termsFooter;
    }
    else {
        UIButton *dismissFooter = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        //bugfix-v1 start
        [dismissFooter setTitle:[self.sectionFooter objectAtIndex:section] forState:UIControlStateNormal];
        dismissFooter.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [dismissFooter setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        //bugfix-v1 end
        [dismissFooter addTarget:self action:@selector(backgroundTap) forControlEvents:UIControlEventTouchUpInside];
        return dismissFooter;
        
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *newUserTableCellId = @"NewUserTableCellId";
    
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:newUserTableCellId];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newUserTableCellId] autorelease];
	}
	
	//Need to clear any settings before
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    
    //Need to clear any settings set before
	//cell.userInteractionEnabled = YES;
	
    switch (indexPath.section)
	{
		case 0:
            cell.textLabel.text = @"";
            UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
            fbButton.clearsContextBeforeDrawing = NO;
            fbButton.frame =   CGRectMake(15, 0, 304, 44);
            UIImage *sendButtonBackground = [UIImage imageNamed:@"Facebook.png"];
            [fbButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
            
            [fbButton addTarget:self action:@selector(fbButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = fbButton;

            break;
        case 1:
			
                cell.textLabel.text = @"";
                UITextField *nameAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
                nameAccessoryView.delegate = self;
                nameAccessoryView.text = self.name;
                nameAccessoryView.placeholder = @"Name";
                nameAccessoryView.autocapitalizationType = UITextAutocapitalizationTypeWords;
                nameAccessoryView.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.accessoryView = nameAccessoryView;
                [nameAccessoryView release]; nameAccessoryView = nil; 
                
            break;
        case 2:   
            
                cell.textLabel.text = @"";
                UITextField *emailAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
                emailAccessoryView.delegate = self;
                emailAccessoryView.text = self.email;
                emailAccessoryView.keyboardType = UIKeyboardTypeEmailAddress;
                emailAccessoryView.autocapitalizationType = UITextAutocapitalizationTypeNone;
                emailAccessoryView.autocorrectionType = UITextAutocorrectionTypeNo;
                emailAccessoryView.placeholder = @"Email";
                cell.accessoryView = emailAccessoryView;
                [emailAccessoryView release]; emailAccessoryView = nil;
            
			break;
			
		case 3:
                cell.textLabel.text = @""; 
                UITextField *genderAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
                genderAccessoryView.text = self.sex;
                genderAccessoryView.placeholder = @"Gender";
                genderAccessoryView.enabled = NO;
                cell.accessoryView = genderAccessoryView;
                [genderAccessoryView release]; genderAccessoryView = nil;
               
         
            break;
        case 4:
                cell.textLabel.text = @"";
            
                UITextField *dobAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
                if (self.dob/*![self.dob isEqualToNumber:[NSNumber numberWithInt:0]]*/) {
                    dobAccessoryView.text  = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.dob doubleValue]]];
                }
                else{
                    dobAccessoryView.text = nil;
                }
                dobAccessoryView.placeholder = @"Birth Date";
                dobAccessoryView.enabled = NO;
                cell.accessoryView = dobAccessoryView;
                [dobAccessoryView release]; dobAccessoryView = nil;
             
        	break;
			
		case 5:
            cell.textLabel.text = @"";
             
            UITextField *passwdAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
            passwdAccessoryView.delegate = self;
            passwdAccessoryView.text = self.passwd;
            passwdAccessoryView.placeholder = @"Password";
            passwdAccessoryView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            passwdAccessoryView.autocorrectionType = UITextAutocorrectionTypeNo;
            passwdAccessoryView.secureTextEntry = YES;
            cell.accessoryView = passwdAccessoryView;
            [passwdAccessoryView release]; passwdAccessoryView = nil;       			
            break;
            
        case 6:
            cell.textLabel.text = @"";
            
            UITextField *repasswdAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 25)];
            repasswdAccessoryView.delegate = self;
            repasswdAccessoryView.text = self.rePasswd;
            repasswdAccessoryView.placeholder = @"Retype Password";
            repasswdAccessoryView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            repasswdAccessoryView.autocorrectionType = UITextAutocorrectionTypeNo;
            repasswdAccessoryView.secureTextEntry = YES;
            cell.accessoryView = repasswdAccessoryView;
            [repasswdAccessoryView release]; repasswdAccessoryView = nil;       			
            break;
 		            
	}
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
	cell.textLabel.textColor = [UIColor colorWithRed:.1 green:0.4 blue:0.5 alpha:1];
	cell.textLabel.shadowColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.7];
    cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);
	cell.textLabel.backgroundColor = [UIColor clearColor];
	return cell;
}



- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 3 && indexPath.section !=4 ) {
        return;
    }
    //[self.tableView addGestureRecognizer:self.gestureRecognizer];
    //UITableViewCell *targetCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *dateString = @"Jan 01, 1980";//targetCell.accessoryView.text;
	
	//This is for the datepicker. Check if our date picker is already on screen
	if (indexPath.section == 4 && self.pickerView.superview == nil) {				
      
        if (self.sexPickerView.superview != nil){
            [self clearPickerView];
        }
        if (dateString == nil) {
			dateString = @"Jan 01, 1980";
		}
     	
        self.pickerView.date = [self.dateFormatter dateFromString:dateString];
        [self.pickerView addTarget:self action:@selector(datePicked) forControlEvents:UIControlEventValueChanged];
		
		[self.view.window addSubview: self.pickerView];
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        self.pickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0,
                                       screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width,
                                       pickerSize.height);
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.pickerView.frame = pickerRect;
        
        // shrink the table vertical size to make room for the date picker
        
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.pickerView.frame.size.height ;
        //CGRect tabBarFrame = 	self.tabBarController.tabBar.frame;
        //newFrame.size.height += tabBarFrame.size.height;
        self.tableView.frame = newFrame;
        
        [UIView commitAnimations];
      	
    }
    
    //This is for the sex picker. Check if our gender picker is already on screen
    if (indexPath.section == 3  && self.sexPickerView.superview == nil) {
        
        if (self.pickerView.superview != nil){
            [self clearPickerView];
        }
        self.sexPickerView.delegate = self;
        self.sexPickerView.showsSelectionIndicator = YES;
        [self.view.window addSubview: self.sexPickerView];
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [self.sexPickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        self.sexPickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0,
                                       screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width,
                                       pickerSize.height);
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.sexPickerView.frame = pickerRect;
        
        // shrink the table vertical size to make room for the date picker
        
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.sexPickerView.frame.size.height ;
        
        //CGRect tabBarFrame = 	self.tabBarController.tabBar.frame;
        //newFrame.size.height += tabBarFrame.size.height;
        self.tableView.frame = newFrame;
        [UIView commitAnimations];
        if (!self.sex) {
            [self performSelector:@selector(initializeGender:) withObject:indexPath afterDelay:0.2];
            
        }
        
    }
    // Make the table view scroll up to show the date of birth or gender field
    if ([self.cellText isFirstResponder]) {
        [self.cellText resignFirstResponder];
    }
    else
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

- (void) initializeGender:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if([self.sexPickerView selectedRowInComponent:0] == 0){
        [(UITextField *)cell.accessoryView setText:@"Female"];
        //cell.cellText.text = @"Female";
        self.sex = @"Female";
    }
    else {
        [(UITextField *)cell.accessoryView setText:@"Male"];
        //cell.cellText.text = @"Male";
        self.sex = @"Male";
    }    
   
}
- (void) doneAction
{
    //Remove any previously created entity - v2
    [self.managedObjectContext rollback];
    [self cleanCoreData];
    
    //Resign textfield as firs responder
    if ([self.cellText isFirstResponder]) {
        [self.cellText resignFirstResponder];
    }
    if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
        [self clearPickerView];
    }         
    
    BOOL isProfileValid = [self validateProfile];
   
    if (!isProfileValid) {
        return;
    }
    //Create new userid on server. Return the userid and store it in NSUserDefults + Core Data
    /* Put all the code to sync mysql db
     */
    [self uploadProfileToServer:FALSE];
    [self.spinner show:YES];
    
}

- (void) datePicked
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.pickerView.superview != nil) {
        [(UITextField *)cell.accessoryView setText:[self.dateFormatter stringFromDate:self.pickerView.date]];
        //cell.cellText.text = [self.dateFormatter stringFromDate:self.pickerView.date];
        NSDate *date = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:self.pickerView.date]];
        self.dob = [NSNumber numberWithDouble:[date timeIntervalSince1970]]  ;
        
    }
    
}
/*- (void)okAction
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.pickerView.superview != nil) {
        [(UILabel *)cell.accessoryView setText:[self.dateFormatter stringFromDate:self.pickerView.date]];
        NSDate *date = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:self.pickerView.date]];
        self.profile.dob = [NSNumber numberWithDouble:[date timeIntervalSince1970]]  ;
        
    }
    else
    {
       
        if([self.sexPickerView selectedRowInComponent:0] == 0){
            [(UILabel *)cell.accessoryView setText:@"Female"];
            
            self.profile.sex = @"Female";
        }
        else {
            [(UILabel *)cell.accessoryView setText:@"Male"];
            
            self.profile.sex = @"Male";
        }
      
        
    }
    
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.pickerView.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
    self.pickerView.superview != nil? [self.pickerView setFrame:endFrame]:[self.sexPickerView setFrame:endFrame];
	
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.pickerView.frame.size.height;
	CGRect tabBarFrame = 	self.tabBarController.tabBar.frame;
	newFrame.size.height -= tabBarFrame.size.height;
	
	self.tableView.frame = newFrame;
	
	// remove the "Done" button in the nav bar
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	
    [rightBarButtonItem release];
    
	
	// deselect the current table row
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
}
*/
- (void)clearPickerView
{
    //[self.tableView removeGestureRecognizer:self.gestureRecognizer];
    /*CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.sexPickerView.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	self.sexPickerView.frame = endFrame;
    */
    /* start the slide down animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
    //self.pickerView.superview != nil? [self.pickerView setFrame:endFrame]:[self.sexPickerView setFrame:endFrame];
	
	[UIView commitAnimations];
	*/
    
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.sexPickerView.frame.size.height;
	//CGRect tabBarFrame = 	self.tabBarController.tabBar.frame;
	//newFrame.size.height -= tabBarFrame.size.height;
    // start the slide up animation
    
	self.tableView.frame = newFrame;
    [self slideDownDidStop];
 
    
}
- (void)slideDownDidStop
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	// the date picker has finished sliding downwards, so remove it
    if (self.pickerView.superview != nil) {
        [self.pickerView removeFromSuperview];
    }
    else
    {
        [self.sexPickerView removeFromSuperview];
    }
   // self.pickerView.superview != nil? [self.pickerView removeFromSuperview]:[self.sexPickerView removeFromSuperview];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	
	UITableViewCell *cell = (UITableViewCell *)[textField superview];
	NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    
	//Once editing in the textfield is done, assign values to the entities
    if (indexPath.section == 1) 
    {
            self.name = textField.text;
    }else if (indexPath.section == 2){
             self.email = textField.text;
        
    }
    else if(indexPath.section == 5){
        self.passwd = textField.text;
    }
   	else if(indexPath.section == 6){
        self.rePasswd = textField.text;
    }
	return YES;
}	

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
		[self clearPickerView];
        //remove the "Done" button in the nav bar
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        // deselect the current table row
        [self.tableView deselectRowAtIndexPath:path animated:NO];
    }
    
    self.cellText = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;	
}


#pragma mark -
#pragma mark UIPickerView delegate methods


- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection  
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if([self.sexPickerView selectedRowInComponent:0] == 0){
        [(UITextField *)cell.accessoryView setText:@"Female"];
        //cell.cellText.text = @"Female";
        self.sex = @"Female";
    }
    else {
        [(UITextField *)cell.accessoryView setText:@"Male"];
        //cell.cellText.text = @"Male";
        self.sex = @"Male";
    }    
    
    
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 2;
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (row == 0) {
        return @"Female";
    }
    else {
        return @"Male";
    }

    
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    return sectionWidth;
}

- (void) termsClicked
{
    TermsController *termsViewController = [[TermsController alloc] initWithNibName:@"TermsController" bundle:nil];
    [self.navigationController pushViewController:termsViewController animated:YES];
    [termsViewController release];
    return;
}

- (void) uploadProfileToServer:(BOOL) fbook
{
    
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PUBLICPATH presentDialog:NO] autorelease];

    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *fbPasswd = [Common generateRandomString];
    
    if (fbook) {
        [params setValue:self.profile.name forKey:@"name"];
        [params setValue:self.profile.email forKey:@"email"];
        [params setValue:self.profile.sex forKey:@"sex"];
        [params setValue:self.profile.dob forKey:@"dob"];
        [params setValue:fbPasswd forKey:@"password"];
        [CustomHTTPRequest storeUsername:self.profile.email password:fbPasswd];
        

    }
    else {
    [params setValue:self.name forKey:@"name"];
    [params setValue:self.email forKey:@"email"];
    [params setValue:self.sex forKey:@"sex"];
    [params setValue:self.dob forKey:@"dob"];
    [params setValue:self.passwd forKey:@"password"];
    [CustomHTTPRequest storeUsername:self.email password:self.passwd];
        
    }
    [params setValue:@"createprofile" forKey:@"script"];
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_NEW_USER;
    [self.request setPostValues:params];
}

- (void) doneCreatingNewUser
{
    if (!self.profile) {
    
        self.profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
        self.profile.name = self.name;
        self.profile.email = self.email;
        self.profile.sex = self.sex;
        self.profile.dob = self.dob;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.profile.name forKey:@"userName"];
        [prefs setObject:self.profile.email forKey:@"userEmail"];
        [prefs setInteger:25 forKey:@"range"];
  
        if ([self.profile.sex isEqualToString:@"Male"]) {
            [prefs setBool:NO forKey:@"userSex"];
            
            //Set reveal by default to Yes in NSUserDefaults for males
            [prefs setBool:YES forKey:@"revealByDefault"];
        }
        else
        {
            [prefs setBool:YES forKey:@"userSex"];
            
            //Set reveal by default to No in NSUserDefaults for females
            [prefs setBool:NO forKey:@"revealByDefault"];
        }
        //Set sound preferences to YES
        [prefs setBool:YES forKey:@"sound"];
        
        [prefs synchronize];
        self.profile.userid = [NSNumber numberWithInteger:[prefs integerForKey:@"userId"]];
        //Save data to Core Data as well
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
            [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
            
            exit(-1);  // Fail
        }
        [self.spinner hide:YES];
        [((DateMeAppDelegate *)[UIApplication sharedApplication].delegate) login]; //v2
    }
    else{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.profile.userid = [NSNumber numberWithInteger:[prefs integerForKey:@"userId"]];
    
        NSLog(@"%@",@"Profile created");
        [self uploadProfileDetails];
    }
    
    
    
}

- (BOOL)validateEmailWithString:(NSString*)emailstr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:emailstr];
}

- (BOOL)validateDob: (NSNumber*)dobnum
{
    if ([dobnum isEqualToNumber:[NSNumber numberWithInt:0]] || !dobnum) { //v2p1 !dobnum was not there before
        return NO;
    }
    NSDate *birthDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dobnum doubleValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    int years = [[gregorian components:NSYearCalendarUnit fromDate:birthDate toDate:[NSDate date] options:0] year];
    [birthDate release]; birthDate = nil;
    [gregorian release]; gregorian = nil;
    
    if (years >= 12) { //bugfix-v1 earlier 18
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (BOOL)validatePassword:(NSString *)password
{
    return [password length] > 5;
    
}

- (BOOL) validatePassword:(NSString *)password withConfirm:(NSString *)rePassword
{
    return [password isEqualToString:rePassword];
}

- (BOOL)validateProfile
{
    BOOL isNameValid = (self.name != nil && ![self.name isEqualToString:@""]);
    if (!isNameValid) {
        [ErrorHandler displayString:@"Please tell us your name" forDelegate:nil]; 
        return NO;
    }
  
    BOOL isEmailValid = [self validateEmailWithString:self.email];
    if (!isEmailValid) {
        [ErrorHandler displayString:@"Email is invalid" forDelegate:nil]; 
        return NO;
    }
    
    BOOL isGenderValid = ([self.sex isEqualToString:@"Male"] || [self.sex isEqualToString:@"Female"]);
    if (!isGenderValid) {
        [ErrorHandler displayString:@"Please tell us your gender" forDelegate:nil]; 
        return NO;
    }
    BOOL isDobValid = [self validateDob:self.dob];
    if (!isDobValid) {
        [ErrorHandler displayString:@"You need to be 12 years or older. We will keep this info private" forDelegate:nil]; //bugfix-v1 earlier 18 //v2p1 message about privacy
        return NO;
    }

    BOOL isPasswdValid = [self validatePassword:self.passwd];
    if (!isPasswdValid) {
        [ErrorHandler displayString:@"For your security, password must be longer than 5 characters" forDelegate:nil]; 
        return NO;
    }
    

    BOOL doesPasswdMatch = [self validatePassword:self.passwd withConfirm:self.rePasswd];
    if (!doesPasswdMatch) {
        [ErrorHandler displayString:@"Passwords must match" forDelegate:nil]; 
        return NO;
    }
   
    return YES;
}

- (void) stopSpinner
{
    [self.spinner hide:YES];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbLoginNewUser:) name:@"FBLoginComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLoginNewUser:) name:@"FBDidNotLogin" object:nil];
    
    NSArray *permissions = [[[NSArray alloc] initWithObjects:
                            @"user_likes",
                            @"user_about_me",
                            @"user_birthday",
                            @"user_education_history",
                            @"user_work_history",
                            @"user_activities",
                            @"email", 
                            nil] autorelease];
    [appDelegate.facebook authorize:permissions];
}


- (void)fbLoginNewUser:(NSNotification *) notification {
     [self.spinner show:YES];
    // get information about the currently logged in user
     DateMeAppDelegate *appDelegate = (DateMeAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.facebook requestWithGraphPath:@"me/?fields=first_name,last_name,email,gender,birthday,education,work,music,movies,books,activities,television,picture" andDelegate:self];
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fbDidNotLoginNewUser:(NSNotification *) notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void) request:(FBRequest *)request didFailWithError:(NSError *)error
{
    [ErrorHandler displayString:@"Cannot connect to Facebook. Please try later." forDelegate:nil];
    [self.spinner hide:YES];
    
}
- (void)request:(FBRequest *)request didLoad:(id)result
{
    //NSLog(@"%@", result);
    [self parseJSONResultAndCreateProfile:result];
}

- (void) parseJSONResultAndCreateProfile:(id) result
{
    SBJSON *parser = [[SBJSON alloc] init];
    NSString *jsonString = [NSString stringWithString:[result JSONRepresentation]];
    NSDictionary *fbData = (NSDictionary *) [parser objectWithString:jsonString error:nil];  
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Remove any previously created entity
    [self.managedObjectContext rollback];
    [self cleanCoreData];
 
    self.profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
    self.profile.name = (NSString*)[fbData objectForKey:@"first_name"];
    self.profile.name = [self.profile.name stringByAppendingString:@" "];
    self.profile.name = [self.profile.name stringByAppendingString:[fbData objectForKey:@"last_name"]];
    [prefs setObject:self.profile.name forKey:@"userName"];
    self.profile.email = (NSString *) [fbData objectForKey:@"email"];
    [prefs setObject:self.profile.email forKey:@"userEmail"];
    self.profile.sex = (NSString *) [fbData objectForKey:@"gender"];
    
    if ([self.profile.sex compare:@"Male" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
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
    
    [prefs setInteger:25 forKey:@"range"];
    
    //Set sound preferences to YES
    [prefs setBool:YES forKey:@"sound"];
    
    //Set date of logging in for chat message download
    [prefs setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"messageStartDate"];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];  // 05/24/1983
    NSDate *date = [dateFormat dateFromString:(NSString *) [fbData objectForKey:@"birthday"]];
    [dateFormat release]; dateFormat = nil;
    self.profile.dob = [NSNumber numberWithDouble:[date timeIntervalSince1970]]  ;
    
    NSDictionary *activities = (NSDictionary *) [fbData objectForKey:@"activities"];  
    NSArray *data  = (NSArray *) [activities objectForKey:@"data"];  
    for (id item in data) {  
        Hobby *hobby = [NSEntityDescription insertNewObjectForEntityForName:@"Hobby" inManagedObjectContext:self.managedObjectContext];
        hobby.name = (NSString *) [item objectForKey:@"name"];
        [self.profile addHobbiesObject:hobby];
    }  
    
    
    NSDictionary *books = (NSDictionary *) [fbData objectForKey:@"books"];  
    NSArray *dataBooks  = (NSArray *) [books objectForKey:@"data"];  
    for (id item in dataBooks) {   
        Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
        book.name = (NSString *) [item objectForKey:@"name"];
        [self.profile addBooksObject:book];
    }
    
    NSArray *education = (NSArray *) [fbData objectForKey:@"education"];  
    for (id item in education) {  
        NSDictionary *schools = (NSDictionary *) [item objectForKey:@"school"]; 
        School *school = [NSEntityDescription insertNewObjectForEntityForName:@"School" inManagedObjectContext:self.managedObjectContext];
        school.name = (NSString *) [schools objectForKey:@"name"];
        [self.profile addSchoolsObject:school];
        
    }
    NSArray *works = (NSArray *) [fbData objectForKey:@"work"];  
    for (id item in works) {  
        NSDictionary *employer = (NSDictionary *) [item objectForKey:@"employer"]; 
        Work *work = [NSEntityDescription insertNewObjectForEntityForName:@"Work" inManagedObjectContext:self.managedObjectContext];
        work.name = (NSString *) [employer objectForKey:@"name"];
        [self.profile addWorksObject:work];
        
    }
    
    NSDictionary *movies = (NSDictionary *) [fbData objectForKey:@"movies"];  
    NSArray *dataMovies  = (NSArray *) [movies objectForKey:@"data"];  
    for (id item in dataMovies) {    
        Movie *movie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.managedObjectContext];
        movie.name = (NSString *) [item objectForKey:@"name"];
        [self.profile addMoviesObject:movie];
        
    }
    NSDictionary *musics = (NSDictionary *) [fbData objectForKey:@"music"];  
    NSArray *dataMusics  = (NSArray *) [musics objectForKey:@"data"];  
    for (id item in dataMusics) {  
        Music *music = [NSEntityDescription insertNewObjectForEntityForName:@"Music" inManagedObjectContext:self.managedObjectContext];
        music.name = (NSString *) [item objectForKey:@"name"];
        [self.profile addMusicsObject:music];
    }
    
    NSDictionary *tvshows = (NSDictionary *) [fbData objectForKey:@"television"];  
    NSArray *dataTvshows  = (NSArray *) [tvshows objectForKey:@"data"];  
    for (id item in dataTvshows) {   
        Tvshow *tvshow = [NSEntityDescription insertNewObjectForEntityForName:@"Tvshow" inManagedObjectContext:self.managedObjectContext];
        tvshow.name = (NSString *) [item objectForKey:@"name"];
        [self.profile addTvshowsObject:tvshow];
        
    }

    NSDictionary *picture = (NSDictionary *) [fbData objectForKey:@"picture"];  
    NSDictionary *dataPictures  = (NSDictionary *) [picture objectForKey:@"data"];  
    NSString* picUrl = (NSString *) [dataPictures objectForKey:@"url"];
    NSRange range = [picUrl rangeOfString:@".gif"];
    if (range.location == NSNotFound) {
        NSMutableString *profilePic = [[[NSMutableString alloc] initWithString:@"http://graph.facebook.com/"] autorelease];
        [profilePic appendString:(NSString*)[fbData objectForKey:@"id"]];
        [profilePic appendString:@"/picture?type=large"];
            
        [self.request clearDelegatesAndCancel];
        self.request = [CustomHTTPRequest requestWithURL:[NSURL URLWithString:profilePic]];
        [self.request startSynchronous];
        NSError *error = [self.request error];
        
        if (!error) { 
            self.profile.faceImg = [self.request responseData];
            self.profile.face = profilePic;
            [prefs setObject:self.profile.face forKey:@"userThumbnail"];    
        }    
    }
    [prefs synchronize];
    [parser release]; parser = nil;
    [self uploadProfileToServer:YES];
    
}


- (void) uploadProfileDetails
{
    
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    
    //Initialize the entity arrays
    NSMutableArray *schoolsArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *worksArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *musicsArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *moviesArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *booksArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *hobbiesArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *tvshowsArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    
    //Set the mutable arrays for all the child entities. 
    [schoolsArray addObjectsFromArray:[profile.schools allObjects]];
    [worksArray addObjectsFromArray:[profile.works allObjects]];
    [musicsArray addObjectsFromArray:[profile.musics allObjects]];
    [moviesArray addObjectsFromArray:[profile.movies allObjects]];
    [booksArray addObjectsFromArray:[profile.books allObjects]];
    [hobbiesArray addObjectsFromArray:[profile.hobbies allObjects]];
    [tvshowsArray addObjectsFromArray:[profile.tvshows allObjects]];
    
    //NSString *profileJSON = [self jsonStructureFromManagedObjects:profilesArray];
    NSString *schoolsJSON = [self jsonStructureFromManagedObjects:schoolsArray];
    NSString *worksJSON = [self jsonStructureFromManagedObjects:worksArray];
    NSString *musicsJSON = [self jsonStructureFromManagedObjects:musicsArray];
    NSString *booksJSON = [self jsonStructureFromManagedObjects:booksArray];
    NSString *moviesJSON = [self jsonStructureFromManagedObjects:moviesArray];
    NSString *hobbiesJSON = [self jsonStructureFromManagedObjects:hobbiesArray];
    NSString *tvshowsJSON = [self jsonStructureFromManagedObjects:tvshowsArray];
    
    [schoolsArray release]; schoolsArray = nil;
    [worksArray release]; worksArray = nil;
    [musicsArray release]; musicsArray = nil;
    [moviesArray release]; moviesArray = nil;
    [booksArray release]; booksArray = nil;
    [hobbiesArray release]; hobbiesArray = nil;
    [tvshowsArray release]; tvshowsArray = nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:self.profile.userid forKey:@"userid"];
   // [params setValue:profileJSON forKey:@"profile"];
    [params setValue:schoolsJSON forKey:@"schools"];
    [params setValue:worksJSON forKey:@"works"];
    [params setValue:musicsJSON forKey:@"musics"];
    [params setValue:booksJSON forKey:@"books"];
    [params setValue:moviesJSON forKey:@"movies"];
    [params setValue:hobbiesJSON forKey:@"hobbies"];
    [params setValue:tvshowsJSON forKey:@"tvshows"];
    [params setValue:@"uploadprofile" forKey:@"script"];
    
    self.request.tag = REQUEST_FOR_PROFILE_EDIT;
    self.request.customHTTPDelegate = self;
    [self.request setPostValues:params];
}


#pragma mark
#pragma JSON from NSManagedObjects

- (NSString*)jsonStructureFromManagedObjects:(NSArray*)managedObjects
{
    
    NSArray *objectsArray = [self dataStructuresFromManagedObjects:managedObjects];
    NSString *jsonString = [objectsArray JSONRepresentation];
    return jsonString;
}

- (NSArray*)dataStructuresFromManagedObjects:(NSArray*)managedObjects
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (NSManagedObject *managedObject in managedObjects) {
        [dataArray addObject:[self dataStructureFromManagedObject:managedObject]];
    }
    return [dataArray autorelease];
}


- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject
{
    NSDictionary *attributesByName = [[managedObject entity] attributesByName];
    // NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
    NSMutableDictionary *valuesDictionary = [[managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]] mutableCopy];
    //[valuesDictionary setObject:[[managedObject entity] name] forKey:@"ManagedObjectName"];
    [valuesDictionary removeObjectForKey:@"faceImg"];
    [valuesDictionary removeObjectForKey:@"face"];
 
    return [valuesDictionary autorelease];
}

- (void) profileUploadFinished
{

    NSLog(@"%@",@"Profile details uploaded");
    [self uploadPhoto];
    
}

- (void)uploadPhoto{
	
    if (!self.profile.face || self.profile.face == nil || [self.profile.face isEqualToString:@""]) {
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
            [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
            exit(-1);  // Fail
        }
        NSLog(@"%@",@"No Photo to upload");
        [self.spinner hide:YES];
        [((DateMeAppDelegate *)[UIApplication sharedApplication].delegate) login];
        return;
    }
    [self.request clearDelegatesAndCancel];
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];   
    [self.request addDataForImageContent:self.profile.faceImg withKey:@"img"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //Get userId from NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [params setValue:[NSNumber numberWithInt:[prefs integerForKey:@"userId"]] forKey:@"userid"];
    [params setValue:@"both" forKey:@"mode"];
    [params setValue:@"uploadphoto" forKey:@"script"];
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_ADD_PHOTO_THUMBNAIL;
    [self.request setPostValues:params];
    
}

- (void) photoUploadFinished:(NSNumber*) photoIdentifier path:(NSString*) path;
{
   
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    photo.path = path;
    photo.serverPhotoId = photoIdentifier;
    photo.thumbnail = [NSNumber numberWithInt:1];
    [self.profile addPhotosObject:photo];
 
    self.profile.face = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"thumbnail.jpg"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.profile.face forKey:@"userThumbnail"];
    [prefs synchronize];

     
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
        exit(-1);  // Fail
    }
    NSLog(@"%@",@"Photo uploaded");
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

/*v2 end */


@end
