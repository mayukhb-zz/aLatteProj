//
//  ProfileTableSetting.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 11/2/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ProfileTableSetting.h"
#import "Constants.h"
#import "Common.h"
#import "DateMeAppDelegate.h"
#import "ErrorHandler.h"

@implementation ProfileTableSetting

@synthesize sectionTitle;
@synthesize managedObjectContext, profile;
@synthesize request;
@synthesize passwd;
@synthesize cellText;
@synthesize passwdChanged;
@synthesize revealSettingChanged, revealByDefault;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        NSArray *tempSectionTitle = [[NSArray alloc ] initWithObjects:@"Account",@"", @"",@"", nil];
        self.sectionTitle = tempSectionTitle;
        [tempSectionTitle release]; tempSectionTitle = nil;
        
        // Fetch existing events.
        // Create a fetch request;Find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch
        if (!self.managedObjectContext) {
            self.managedObjectContext = [(DateMeAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Execute the fetch -- create a mutable copy of the result.
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
            [ErrorHandler displayString:@"Unexpected issue while retrieving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
            exit(-1);  // Fail		
        }
        self.profile = (Profile*)[mutableFetchResults objectAtIndex:0];
        [mutableFetchResults release];mutableFetchResults = nil;
        [fetchRequest release]; fetchRequest = nil;
        
        self.passwd = [CustomHTTPRequest passwd];
        [self addObserver:self forKeyPath:@"parentViewController" options:0 context:NULL];
        self.passwdChanged = NO;
        self.revealSettingChanged = NO;

    }
    return self;
}
- (void)dealloc
{
    [sectionTitle release]; sectionTitle = nil;
    [managedObjectContext release]; managedObjectContext = nil;
    [profile release]; profile = nil;
    [passwd release]; passwd = nil;
    
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel];
    [request release]; request = nil;
    
    [self removeObserver:self forKeyPath:@"parentViewController"];
    [cellText release]; cellText = nil;
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
    self.navigationItem.title = @"Settings"; 
    self.navigationController.navigationBar.backItem.title = @"Done";
    //[Common setTheme:self.parentViewController forTableView:self.tableView];//#v2.1
    [Common setSearchViewTheme:self.tableView]; //#v2.1
    
    	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.cellText = nil;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"parentViewController" isEqualToString:keyPath] && object == self) {
        if (!self.parentViewController)
        {
            if ([self.cellText isFirstResponder]) {
                [self.cellText resignFirstResponder];
            }
            if (self.passwdChanged || self.revealSettingChanged) {
                [self uploadToServer];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUM_SECTIONS_PROFILE_SETTINGS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == ACCOUNT_SECTION) {
        /*v2 start*/
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if ([prefs objectForKey:@"FBAccessTokenKey"] 
            && [prefs objectForKey:@"FBExpirationDateKey"])
        {
            return 1;
        } else
        {
        return NUM_ROWS_ACCOUNT_SECTION;
        }
        /*v2 end*/
    }
    else if (section == SOUND_SECTION){
        return NUM_ROWS_SOUND_SECTION;
    }
    else if (section  == REVEAL_SECTION){
        return NUM_ROWS_REVEAL_SECTION;
    }
    else {
        return NUM_ROWS_RANGE_SECTION;
    }
    //else return NUM_ROWS_SESSION_SECTION;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *profileSettingCellId = @"ProfileSettingCell";
    
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:profileSettingCellId];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:profileSettingCellId] autorelease];
	}
	
	//Need to clear any settings before
	cell.imageView.image = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    
    //Define some temporary variables
	UISwitch *switchview;
    UISegmentedControl *segmentedControl;
    //UIButton *logoutButton;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //int theme;
    
	switch (indexPath.section)
	{
		case 0:
			
            if (indexPath.row == USERID_ROW) {
                cell.textLabel.text = @"Email";
                UILabel *useridAccessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 175, 40)];
                useridAccessoryView.text = self.profile.email;
                useridAccessoryView.userInteractionEnabled = NO;
                cell.accessoryView = useridAccessoryView;
                [useridAccessoryView release]; useridAccessoryView = nil;
                
                              
            }
            else{
                cell.textLabel.text = @"Password";
                UITextField *passwdAccessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 175, 25)];
                passwdAccessoryView.text = [prefs stringForKey:@"password"];
                passwdAccessoryView.secureTextEntry = YES;
                passwdAccessoryView.text = self.passwd;
                passwdAccessoryView.delegate = self;
                cell.accessoryView = passwdAccessoryView;
                [passwdAccessoryView release]; passwdAccessoryView = nil;
                
            }
			break;
			
		case 1:
          
            cell.textLabel.text = @"Sound & Alert";
            //add a switch
            switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchview setOn:[prefs boolForKey:@"sound"]];
            cell.accessoryView = switchview;
            [switchview addTarget:self action:@selector(updateSoundPref:) forControlEvents:UIControlEventTouchUpInside];
            [switchview release]; switchview = nil;
			break;
			
		/*case 2:
            theme = [prefs integerForKey:@"theme"] ;
            
            cell.accessoryType = theme == indexPath.row? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
			if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"snow.jpg"];
				cell.textLabel.text = @"Sparkling Snow";
                
			}
			else {
                cell.imageView.image = [UIImage imageNamed:@"Big-Water-Drops.jpg"];
				cell.textLabel.text = @"Water Drops";
			}
			
			
			break;*/
		case 2:
            cell.textLabel.text = @"Reveal Pics by Default";
            //add a switch
            switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchview setOn:[prefs boolForKey:@"revealByDefault"]];
            cell.accessoryView = switchview;
            
            [switchview addTarget:self action:@selector(updateRevealPref:) forControlEvents:UIControlEventTouchUpInside];
            [switchview release]; switchview = nil;
			break;
            
        case 3:
            cell.textLabel.text = @"Near Me Range (mi)";
            //add a switch
            segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(320, 5, 110, 35)];
            [segmentedControl insertSegmentWithTitle: @"5" atIndex: 0 animated: NO ];
            [segmentedControl insertSegmentWithTitle: @"10" atIndex: 1 animated: NO ];
            [segmentedControl insertSegmentWithTitle: @"25" atIndex: 2 animated: NO ];
            segmentedControl.selectedSegmentIndex = [prefs integerForKey:@"range"]/10;
            [segmentedControl addTarget:self action:@selector(updateRangePref:) forControlEvents:UIControlEventValueChanged];
            [segmentedControl setWidth:35 forSegmentAtIndex:0];
            [segmentedControl setWidth:35 forSegmentAtIndex:1];
            [segmentedControl setWidth:35 forSegmentAtIndex:2];
            //[segmentedControl setOn:[prefs boolForKey:@"revealByDefault"]];
            cell.accessoryView = segmentedControl;
            [segmentedControl release]; segmentedControl = nil;
			
        /*case 4:
            cell.textLabel.text = @"Session";
            //add a logout button
          
            logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
            logoutButton.clearsContextBeforeDrawing = NO;
            logoutButton.frame = CGRectMake(0, 0, 80, 30);
            UIImage *sendButtonBackground = [UIImage imageNamed:@"SendButton.png"];
            [logoutButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
            logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            logoutButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
            [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
            UIColor *shadowColor = [[UIColor alloc] initWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
            [logoutButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
            [shadowColor release]; shadowColor = nil;
            
            [logoutButton addTarget:self action:@selector(actionButtonHit:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = logoutButton;
          */
            
	}
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
	cell.textLabel.textColor = [UIColor colorWithRed:.1 green:0.4 blue:0.5 alpha:1];
	cell.textLabel.shadowColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.7];
    cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);
	cell.textLabel.backgroundColor = [UIColor clearColor];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the region at the section index.	
	
    return [self.sectionTitle objectAtIndex:section];
}

/*
 To conform to Human Interface Guildelines, since selecting a row would have no effect (such as navigation), make sure that rows cannot be selected.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (indexPath.section != APPEARANCE_SECTION) {
        return;
    }*/
   /* NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   
    if (indexPath.row == 0) {
        [prefs setInteger:0 forKey:@"theme"];
    }
    else
    {
        [prefs setInteger:1 forKey:@"theme"];
    }
    [prefs synchronize];
    NSString *themeImg = [prefs integerForKey:@"theme"] == 1? @"Big-Water-Drops.jpg" : @"snow.jpg";
    
    self.parentViewController.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:themeImg]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //Call something to update the theme in other tabs??
    [self.tableView reloadData]; // do we nead a reload?
    */
}

- (void) updateSoundPref:(id)sender
{
    UISwitch *switchView = sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setBool:[switchView isOn] forKey:@"sound"];
    [prefs synchronize];
}

- (void) updateRevealPref:(id)sender
{
    UISwitch *switchView = sender;
    self.revealByDefault = [switchView isOn];
    self.revealSettingChanged = YES;
}

- (void) updateRangePref:(id)sender
{
    UISegmentedControl *segmentedControl = sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger range = [segmentedControl selectedSegmentIndex];
    if (range == 0) {
        range = 5;
    }
    else if (range == 1){
        range = 10;
    }
    else {
        range = 25;
    }
    [prefs setInteger:range forKey:@"range"];
    [prefs synchronize];
}

/*- (void) logout
{
     [CustomHTTPRequest logout];
    [((DateMeAppDelegate *)[UIApplication sharedApplication].delegate) logout];

}*/

/*- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		[self logout];
    }
	
}*/

/*- (void)actionButtonHit:(id)sender{
	
	UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout",nil];
    	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	
	[actionSheet showInView:self.parentViewController.tabBarController.view];
	[actionSheet release];
	
}*/

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.cellText = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    self.passwd = textField.text;
    self.passwdChanged = YES;
	/*UITableViewCell *cell = (UITableViewCell *)[textField superview];
	NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    
    if (indexPath.section == ACCOUNT_SECTION && indexPath.row == 1)
    {
        self.passwd = textField.text;
    }*/
   
    return YES;
}	

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;	
}

- (void) uploadToServer
{
    
    if (self.passwdChanged && ![self validatePassword:self.passwd]) {
        [ErrorHandler displayString:@"For your security, password must be longer than 5 characters" forDelegate:nil]; 
        return;

    }
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.passwdChanged) {
        [params setValue:self.profile.email forKey:@"email"];
        [params setValue:self.passwd forKey:@"password"];
        [params setValue:@"Y" forKey:@"changePasswd"]   ;  
    }
    if (self.revealSettingChanged) {
        [params setValue:self.profile.userid forKey:@"userid"];
        [params setValue:self.revealByDefault?@"1":@"0" forKey:@"reveal"];
        [params setValue:@"Y" forKey:@"changeReveal"];  
    }
    
    [params setValue:@"updatesettings" forKey:@"script"];
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_SETTING_CHANGE;
    [self.request setPostValues:params];
}

- (void) doneChangingSetting
{
    if (self.passwdChanged) {
        [CustomHTTPRequest logout];
        [CustomHTTPRequest storeUsername:self.profile.email password:self.passwd];
        
    }
    if (self.revealSettingChanged) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:self.revealByDefault forKey:@"revealByDefault"];
        [prefs synchronize];
        
    }
    [ErrorHandler displayInfoString:@"Settings updated." forDelegate:nil];
        
}


- (BOOL)validatePassword:(NSString *)password
{
    return [password length] > 5;
    
}

@end
