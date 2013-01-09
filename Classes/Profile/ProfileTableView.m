//
//  ProfileTableView.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/28/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ProfileTableView.h"
#import "Tvshow.h"
#import "School.h"
#import "Book.h"
#import "Movie.h"
#import "Hobby.h"
#import "Music.h"
#import "Work.h"
#import "Photo.h"
#import "EGOPhotoGlobal.h"
#import "MyPhotoSource.h"
#import "MyPhoto.h"
#import "ProfileTableSetting.h"
#import "Common.h"
#import "ErrorHandler.h"
#import "DateMeAppDelegate.h"

@implementation ProfileTableView

@synthesize profile,sectionTitle,managedObjectContext, profilesArray,schoolsArray, worksArray, booksArray, musicsArray, moviesArray, hobbiesArray, tvshowsArray, photosArray;

- (void)viewDidLoad {
	
    [super viewDidLoad];
    if (!self.managedObjectContext) {
        self.managedObjectContext = [(DateMeAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    //[Common setTheme:self.parentViewController forTableView:self.tableView];//#v2.1
    [Common setSearchViewTheme:self.tableView]; //#v2.1
    if (!self.sectionTitle) {
        NSArray *tempSectionTitle = [[NSArray alloc ] initWithObjects:@"",@"Bio", @"Networks", @"Music", @"Movies", @"Books", @"Hobbies", @"TV Shows", nil];
        self.sectionTitle = tempSectionTitle;
        [tempSectionTitle release]; tempSectionTitle = nil;
    }

	UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToEdit)];
	self.navigationItem.leftBarButtonItem = leftBarButtonItem;
	
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToSettings)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	
	[leftBarButtonItem release];
	[rightBarButtonItem release];
	
    if (!self.profile) {
    // Fetch existing events.
	// Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
	if (mutableFetchResults == nil) {
		// Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
		exit(-1);  // Fail		
	}
    
    //Initialize profiles array
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.profilesArray = tempArray;
    [tempArray release]; tempArray = nil;
    
	// Set self's events array to the mutable array, then clean up.
	[self.profilesArray addObjectsFromArray:mutableFetchResults];
        //NSLog(@"%d",[self.profilesArray count]);
        
	if ([self.profilesArray count] !=0) {
		self.profile = (Profile *)[self.profilesArray objectAtIndex:0];
       // NSLog(@"%@",self.profile.name);
	}
	else {
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
		exit(-1);  // Fail	
	}
		
	//Initialize the entity arrays
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.schoolsArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.worksArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.musicsArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.moviesArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.booksArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.hobbiesArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.tvshowsArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithCapacity:5];
    self.photosArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    //Set the mutable arrays for all the child entities. 
	[self.schoolsArray addObjectsFromArray:[self.profile.schools allObjects]];
	[self.worksArray addObjectsFromArray:[self.profile.works allObjects]];
 	[self.musicsArray addObjectsFromArray:[self.profile.musics allObjects]];
  	[self.moviesArray addObjectsFromArray:[self.profile.movies allObjects]];
  	[self.booksArray addObjectsFromArray:[self.profile.books allObjects]];
  	[self.hobbiesArray addObjectsFromArray:[self.profile.hobbies allObjects]];
    [self.tvshowsArray addObjectsFromArray:[self.profile.tvshows allObjects]];
    [self.photosArray addObjectsFromArray:[self.profile.photos allObjects]];
	
    [mutableFetchResults release];mutableFetchResults = nil;
	[request release];request = nil;
	}
	self.navigationController.delegate = self;
    
    //A failback if section which tries to download the face photo in case it was not initiallly downloaded etc
    //This code will rarely be executed!
    if (![self.profile.face isEqualToString:@"null"] && self.profile.face && !self.profile.faceImg) { 
        CustomHTTPRequest *request;
        request = [CustomHTTPRequest requestWithURL:[NSURL URLWithString:self.profile.face]];
        [request addBasicAuthenticationHeaderWithUsername:CustomHTTPRequest.username
                                                   andPassword:CustomHTTPRequest.passwd];

        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            self.profile.faceImg = [request responseData];
            //Save data to Core Data as well
            if (![self.managedObjectContext save:&error]) {
                // Handle the error.
                //No need - Mayukh
            }
        }
        
    }
}

- (void) viewDidUnload {
	
	[super viewDidUnload];
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Number of sections is the number of regions.
	
	return [self.sectionTitle count] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == ONE) {
		return 3;
	}
    else if (section == TWO){
        return 2;
    }
        
	else {
		return 1;
	}

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the region at the section index.	
	
		return [self.sectionTitle objectAtIndex:section];
	}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"ProfileViewCell";

	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
	}
	
	//Need to clear any images set before
	cell.imageView.image = nil;
	cell.imageView.userInteractionEnabled = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    for (UIView *view in cell.imageView.subviews){
        [view removeFromSuperview];
    }
    
	NSMutableString *text = [[NSMutableString alloc] init];
	
    UIButton *button;
    UIImage *img = [UIImage imageNamed:@"Add.png"];
    switch (indexPath.section)
	{
		case 0:
		
            if (self.profile.faceImg != nil) {
                img = [UIImage imageWithData: self.profile.faceImg];
                           
            }
            [cell.imageView setImage:img];
            [cell.imageView.layer setCornerRadius:10.0];
            cell.imageView.layer.masksToBounds = YES;
            [cell.imageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
            [cell.imageView.layer setBorderWidth: 2.0];
            

            button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [button setFrame:CGRectMake(5,0,120,150)]; 
            [button addTarget:self action:@selector(navigateToPhotos) forControlEvents:UIControlEventTouchUpInside];
            cell.imageView.userInteractionEnabled = YES;
            [cell.imageView addSubview:button];
            
			cell.detailTextLabel.text = self.profile.name;
			break;
			
		case 1:
            if (indexPath.row == TWO){
                cell.detailTextLabel.text = self.profile.sex;

            }
			else if (indexPath.row == ONE) {
				NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
				[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                
                if (![self.profile.dob isEqualToNumber:[NSNumber numberWithInt:0]]) {
                     cell.detailTextLabel.text  = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.profile.dob doubleValue]]];
                }
                else{
                    cell.detailTextLabel.text = nil;
                }
               
				[dateFormatter release];
				
			}
			else{
				cell.detailTextLabel.text = self.profile.email;
				
			}
			break;
			
		case 2:
			if (indexPath.row == 0) {
				cell.detailTextLabel.text = [self getTextFromEntityArray:self.schoolsArray];
			}
			else {
				cell.detailTextLabel.text = [self getTextFromEntityArray:self.worksArray];
			}
			
			
			break;
		case 3:
			cell.detailTextLabel.text = [self getTextFromEntityArray:self.musicsArray];
			break;
		case 4:
			cell.detailTextLabel.text = [self getTextFromEntityArray:self.moviesArray];
			break;
		case 5:
			cell.detailTextLabel.text = [self getTextFromEntityArray:self.booksArray];
			break;
		case 6:
			cell.detailTextLabel.text = [self getTextFromEntityArray:self.hobbiesArray];
			break;
		default:
			cell.detailTextLabel.text = [self getTextFromEntityArray:self.tvshowsArray];
			break;
		
	}
	cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.detailTextLabel.numberOfLines = 0;
	
	[text release];
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
	case 0:
		return 150;
		break;
		
	case 1:
		return 40;
		break;
	case 2:
		if (indexPath.row == 0) {
			return [self cellRowHeight:[self getTextFromEntityArray:self.schoolsArray]];
		}
		else {
			return [self cellRowHeight:[self getTextFromEntityArray:self.worksArray]];
		}
		break;
	case 3:
		return [self cellRowHeight:[self getTextFromEntityArray:self.musicsArray]];
		break;
	case 4:
		return [self cellRowHeight:[self getTextFromEntityArray:self.moviesArray]];
		break;
	case 5:
		return [self cellRowHeight:[self getTextFromEntityArray:self.booksArray]];
		break;
	case 6:
		return [self cellRowHeight:[self getTextFromEntityArray:self.hobbiesArray]];
		break;
	default:
		return [self cellRowHeight:[self getTextFromEntityArray:self.tvshowsArray]];
		break;
	}
	
}

-(NSString *) getTextFromEntityArray:(NSMutableArray *)entityArray
{
	NSMutableString *text  = [[NSMutableString alloc] init];
	//text = @"";
	for (NSManagedObject *obj in entityArray) {
		if ([(Profile*)obj name] != nil) {
			[text appendString:[(Profile*)obj name]];
			[text appendString:@", "];
		}
		
		
	}
	
	NSRange range;
	if([text length] > 2){
		
		range.length = 2;
		range.location = [text length] - 2;
		[text deleteCharactersInRange:range];
	}
	if ([text length] == 0) {
		[text appendString:@""];
	}
	return [text autorelease];
	
}


- (CGFloat)cellRowHeight:(NSString *)cellText
{
	if (cellText == nil || [cellText isEqualToString:@""]) {
		return 40;
	}
	UIFont *cellFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
	CGSize constraintSize = CGSizeMake(300.0f, MAXFLOAT);
	CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	return labelSize.height + 20;
}

- (void)navigateToEdit {
	
	ProfileTableEdit *profileTableEdit = [[ProfileTableEdit alloc] initWithStyle:UITableViewStyleGrouped manageObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:profileTableEdit animated:YES];
    [profileTableEdit release]; profileTableEdit = nil;
	
}

- (void)navigateToPhotos {
	
	MyPhotoSource *source =[[MyPhotoSource alloc] initWithPhotos:[NSMutableArray arrayWithObjects:nil]];
	MyPhoto *photo;
    int zeroPhotoFlag = 1;
    
    for (NSManagedObject *obj in self.photosArray) {
		if ([(Photo*)obj path] != nil && ![[(Photo*)obj path] isEqualToString:@""]) {
            
			photo = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:[(Photo*)obj path]] name:[NSString stringWithFormat:@"%@",[(Photo*)obj serverPhotoId]]];
 			[source addPhoto:photo];
			[photo release];
            zeroPhotoFlag = 0;
		}
		
		
	}
    if (zeroPhotoFlag == 1) {
        photo = [[MyPhoto alloc ] initWithImage:[UIImage imageNamed:@"egopv_photo_placeholder.png"]];
        [source addPhoto:photo];
        [photo release];
    }

	EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source andViewOnlyMode:NO];
	photoController.photoDelegate = self;
    
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
	
	navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	navController.modalPresentationStyle = UIModalPresentationFullScreen;
	
	[self presentModalViewController:navController animated:YES];
    [navController release];
	[photoController release];
	[source release];
}

- (BOOL) isSelectedPicThumbnail: (NSNumber*) photoId
{
    //Secondly set thumbnail flag to 1 in photo table. Reset any other thumbnail flag to 0
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(serverPhotoId == %@ && thumbnail == %d)", photoId, 1];
    [fetchRequest setPredicate:predicate];
    // Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
	if (mutableFetchResults == nil) {
		// Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];
        exit(-1);  // Fail	
    }
    BOOL thumbnail = NO;
    for (NSManagedObject *obj in mutableFetchResults) {
        thumbnail = YES;
    }  
    [fetchRequest release]; fetchRequest = nil;
    [mutableFetchResults release]; mutableFetchResults = nil;
    
    return thumbnail;

}

- (void) setPhoto:(NSString *)path withServerPhotoId: (NSNumber*) photoId
{
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    photo.path = path;
    photo.serverPhotoId = photoId;
    [self.profile addPhotosObject:photo];
    [self.photosArray addObject:photo];
   
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while saving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];
        exit(-1);  // Fail
    }
 
}

- (void) deletePhoto:(NSNumber *)photoId
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(serverPhotoId == %@)", photoId];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entity];
    // Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
	if (mutableFetchResults == nil) {
		// Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];

        exit(-1);  // Fail	
    }
    BOOL thumbnail;
    for (NSManagedObject *obj in mutableFetchResults) {
        
        [self.profile removePhotosObject:(Photo*)obj];
        [self.photosArray removeObject:(Photo*)obj];
        thumbnail = [[(Photo*)obj thumbnail] boolValue];
        if (thumbnail){
            self.profile.faceImg = nil;
            self.profile.face = nil;
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:nil forKey:@"userThumbnail"];
            [prefs synchronize];
        }
    }  
    [fetchRequest release]; fetchRequest = nil;
    [mutableFetchResults release]; mutableFetchResults = nil;
    
    //Lastly save coredata
    error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while saving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];

        exit(-1);  // Fail
    }    
    [self.tableView reloadData];
}

- (void) setProfilePhoto:(NSData *)photoData withId:(NSNumber *)photoId
{
    //First set the new profile image
    self.profile.faceImg = photoData;
    
    //Secondly set thumbnail flag to 1 in photo table. Reset any other thumbnail flag to 0
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    // Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
	if (mutableFetchResults == nil) {
		// Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];

        exit(-1);  // Fail	
    }
    BOOL thumbnail;
    NSNumber* serverPhotoId;
    for (NSManagedObject *obj in mutableFetchResults) {
        
        thumbnail = [[(Photo*)obj thumbnail] boolValue];
        serverPhotoId = [(Photo*)obj serverPhotoId] ;
        if ([serverPhotoId isEqualToNumber:photoId]) {
            [(Photo*)obj setThumbnail:[NSNumber numberWithInt:1]];
            
            self.profile.face = [[(Photo*)obj path] stringByReplacingOccurrencesOfString:@".jpg" withString:@"thumbnail.jpg"];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:self.profile.face forKey:@"userThumbnail"];
            [prefs synchronize];
            
        }
        else if (thumbnail){
            [(Photo*)obj setThumbnail:[NSNumber numberWithInt:0]];
        }
    }  
    [fetchRequest release]; fetchRequest = nil;
    [mutableFetchResults release]; mutableFetchResults = nil;
    //[serverPhotoId release]; serverPhotoId = nil;
    
    //Lastly save coredata
    error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while saving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];
        exit(-1);  // Fail
    }    
    [self.tableView reloadData];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //This method is called when user moves back from edit page to view page 
    //Need to update the entity arrays with the new saved entity records
    
	[self.schoolsArray removeAllObjects];
    [self.schoolsArray addObjectsFromArray:[self.profile.schools allObjects]];
    
	[self.worksArray removeAllObjects];
    [self.worksArray addObjectsFromArray:[self.profile.works allObjects]];

	[self.musicsArray removeAllObjects];
    [self.musicsArray addObjectsFromArray:[self.profile.musics allObjects]];

	[self.moviesArray removeAllObjects];
    [self.moviesArray addObjectsFromArray:[self.profile.movies allObjects]];
	
	[self.booksArray removeAllObjects];
    [self.booksArray addObjectsFromArray:[self.profile.books allObjects]];
  	
	[self.hobbiesArray removeAllObjects];
    [self.hobbiesArray addObjectsFromArray:[self.profile.hobbies allObjects]];
    
	[self.tvshowsArray removeAllObjects];
    [self.tvshowsArray addObjectsFromArray:[self.profile.tvshows allObjects]];
	
   	[self.tableView reloadData];
}

- (void) navigateToSettings
{
    ProfileTableSetting *profileTableSetting = [[ProfileTableSetting alloc]initWithNibName:@"ProfileTableSetting" bundle:nil];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [newBackButton release];
    [self.navigationController pushViewController:profileTableSetting animated:YES];
    [profileTableSetting release];
    
}


- (void) dealloc {
    
  	[sectionTitle release];sectionTitle = nil;
	[managedObjectContext release];managedObjectContext = nil;
    [profilesArray release]; profilesArray = nil;
    [profile release]; profile = nil;
    [schoolsArray release]; schoolsArray = nil;
    [worksArray release]; worksArray = nil;
    [musicsArray release]; musicsArray = nil;
    [booksArray release]; booksArray = nil;
    [moviesArray release]; moviesArray = nil;
    [hobbiesArray release]; hobbiesArray = nil;
    [tvshowsArray release]; tvshowsArray = nil;
    [photosArray release]; photosArray =nil;

	[super dealloc];
    
}


@end
