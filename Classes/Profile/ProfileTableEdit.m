//
//  ProfileTableEdit.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 5/15/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ProfileTableEdit.h"
#import "Tvshow.h"
#import "School.h"
#import "Book.h"
#import "Movie.h"
#import "Hobby.h"
#import "Music.h"
#import "Work.h"
#import "ProfileEditCell.h"
#import "Constants.h"
#import "Common.h"
#import "SBJson.h"
#import "ErrorHandler.h"

@implementation ProfileTableEdit

@synthesize dateFormatter, profile, profileEditCell, managedObjectContext, profilesArray, schoolsArray, worksArray, booksArray, musicsArray, moviesArray, hobbiesArray, tvshowsArray;
@synthesize cellText;
@synthesize request;
@synthesize lastSelectedIndexPath;
//@synthesize gestureRecognizer;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style manageObjectContext:(NSManagedObjectContext*)mo
{
    self = [super initWithStyle:style];
    if (self) {
        //Fetch existing events.
        //Create a fetch request;Find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
        self.managedObjectContext = mo; 
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Execute the fetch -- create a mutable copy of the result.
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
            [ErrorHandler displayString:@"Unexpected issue while retrieving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];
            exit(-1);  // Fail		
        }
        
        //Initialize profiles array
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.profilesArray = tempArray;
        [tempArray release]; tempArray = nil;
        
        // Set self's profile's array to the mutable array, then clean up.
        [self.profilesArray addObjectsFromArray:mutableFetchResults];
        if ([self.profilesArray count] !=0) {
            self.profile = (Profile *)[self.profilesArray objectAtIndex:0];
        }
        else {
            // Handle the error.
            [ErrorHandler displayString:@"Unexpected issue while retrieving data. Please try restarting." forDelegate:nil];
            //exit(-1);  // Fail		
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
        
         
        //Set the mutable arrays for all the child entities. 
        [self.schoolsArray addObjectsFromArray:[profile.schools allObjects]];
        [self.worksArray addObjectsFromArray:[profile.works allObjects]];
        [self.musicsArray addObjectsFromArray:[profile.musics allObjects]];
        [self.moviesArray addObjectsFromArray:[profile.movies allObjects]];
        [self.booksArray addObjectsFromArray:[profile.books allObjects]];
        [self.hobbiesArray addObjectsFromArray:[profile.hobbies allObjects]];
        [self.tvshowsArray addObjectsFromArray:[profile.tvshows allObjects]];
        
        [mutableFetchResults release];mutableFetchResults = nil;
        [fetchRequest release]; fetchRequest = nil;
        [self setEditing:TRUE];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setTimeStyle:NSDateFormatterNoStyle];
        self.dateFormatter = dateFormat;
        [dateFormat release]; dateFormat = nil; 
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[Common setTheme:self.parentViewController forTableView:self.tableView];//#v2.1
    [Common setSearchViewTheme:self.tableView]; //#v2.1
    
    self.title = @"Edit Profile";
	self.tableView.allowsSelectionDuringEditing = YES;
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //return YES; // for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 9;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

	int count = 0;
	switch (section)
	{
		case 0:
			return 1;
			break;
		case 1:
			return 3;
			break;
		case 2:
			count = [self.schoolsArray count];
			if (self.editing) {
				count++;
			}
			return count;
			break;
		case 3:
			count = [self.worksArray count];
			if (self.editing) {
				count++;
			}
			return count;
			break;
		case 4:
			count = [self.musicsArray count];
			if (self.editing) {
				count++;
			}
			return count;
			break;
		case 5:
			count = [self.moviesArray count];
			if (self.editing) {
				count++;
			}
			return count;
			break;
		case 6:
			count = [self.booksArray count];
			if (self.editing) {
				count++;
			}
			return count;
			break;
		case 7:
			count = [self.hobbiesArray count];
			if (self.editing) {
				count++;
			}
			return count;
			break;
		default:
			count = [self.tvshowsArray count];
			if (self.editing) {
				count++;
			}
			return count;
			break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSUInteger row = indexPath.row;
	NSString *placeholder = @"";
	int count = 0;
	
	switch (indexPath.section) {
		case 2:
			count = [self.schoolsArray count];
			placeholder = @"Add School";
			break;
		case 3:
			count = [self.worksArray count];
			placeholder = @"Add Work";
			break;
		case 4:
			count = [self.musicsArray count];
			placeholder = @"Add Music";
			break;
		case 5:
			count = [self.moviesArray count];
			placeholder = @"Add Movie";
			break;
		case 6:
			count = [self.booksArray count];
			placeholder = @"Add Book";
			break;
		case 7:
			count = [self.hobbiesArray count];
			placeholder = @"Add Hobby";
			break;
		case 8:
			count = [self.tvshowsArray count];
			placeholder = @"Add TV Show";
			break;
		default:
			placeholder = @"";
			break;
	}
	
	if (row == count && indexPath.section > 1) {
		// This is the insertion cell.
		static NSString *InsertionCellIdentifier = @"InsertionCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InsertionCellIdentifier];
		if (cell == nil) {		
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InsertionCellIdentifier] autorelease];
		}
		cell.textLabel.text = placeholder;
		cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
		cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	
	static NSString *MyIdentifier2 = @"ProfileTableEdit";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	ProfileEditCell *cell = (ProfileEditCell*)[tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"ProfileTableEditCell" owner:self options:nil]; //#v2.1
		cell = profileEditCell;
		self.profileEditCell = nil;
	}	
	//Need to clear any settings set before
	cell.cellText.userInteractionEnabled = YES;
	cell.cellText.autocapitalizationType = UITextAutocapitalizationTypeWords;
    cell.cellText.autocorrectionType = UITextAutocorrectionTypeYes;
    cell.backgroundColor = [UIColor whiteColor];
    // Configure the cell..
		switch (indexPath.section)
	{
		case 0:
			cell.cellText.text = self.profile.name;
			cell.cellText.placeholder = @"Name";
            cell.cellText.autocorrectionType = UITextAutocorrectionTypeNo;
            break;
			
		case 1:
            if (row == TWO){
                cell.cellText.text = self.profile.sex;
				cell.cellText.placeholder = @"Sex"; 
                cell.backgroundColor = [UIColor clearColor];
                cell.cellText.userInteractionEnabled = NO;
            }
			else if (row == ONE) {
                if (![self.profile.dob isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    cell.cellText.text  = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.profile.dob doubleValue]]];
                }
                else{
                    cell.cellText.text = nil;
                }
                cell.backgroundColor = [UIColor clearColor];
            	cell.cellText.placeholder = @"Date of Birth";
				cell.cellText.userInteractionEnabled = NO;
			}
			else{
				cell.cellText.text = self.profile.email;
				cell.cellText.placeholder = @"Email";
                cell.cellText.userInteractionEnabled = NO;
                cell.backgroundColor = [UIColor clearColor];
                cell.cellText.autocapitalizationType = UITextAutocapitalizationTypeNone;
				cell.cellText.autocorrectionType = UITextAutocorrectionTypeNo;
			}
			
			break;
			
		case 2:
			cell.cellText.placeholder = @"School";
			if ([self.schoolsArray count] != 0) {
				cell.cellText.text = [[self.schoolsArray objectAtIndex:row] name];
			}
			break;
		case 3:
			cell.cellText.placeholder = @"Work";
			if ([self.worksArray count] != 0) {
				cell.cellText.text = [[self.worksArray objectAtIndex:row] name];
			}
			break;
		case 4:
			cell.cellText.placeholder = @"Music";
			if ([self.musicsArray count] != 0) {
				cell.cellText.text = [[self.musicsArray objectAtIndex:row] name];
			}
			break;
		case 5:
			cell.cellText.placeholder = @"Movie";
			if ([self.moviesArray count] != 0) {
				cell.cellText.text = [[self.moviesArray objectAtIndex:row] name];
			}
			break;
		case 6:
			cell.cellText.placeholder = @"Book";
			if ([self.booksArray count] != 0) {
				cell.cellText.text = [[self.booksArray objectAtIndex:row] name];
			}
			break;
		case 7:
			cell.cellText.placeholder = @"Hobby";
			if ([self.hobbiesArray count] != 0) {
				cell.cellText.text = [[self.hobbiesArray objectAtIndex:row] name];
			}
			break;
		default:
			cell.cellText.placeholder = @"TV Show";
			if ([self.tvshowsArray count] != 0) {
				cell.cellText.text = [[self.tvshowsArray objectAtIndex:row] name];
			}
			break;
		
	}
	
	cell.cellText.backgroundColor =[UIColor clearColor];
	cell.cellText.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
	cell.cellText.textColor = [UIColor darkGrayColor];
	/*if (indexPath.section ==1 && (row ==1 || row ==2)) {
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else {*/
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//}

	return cell;
}

#pragma mark -
#pragma mark Editing rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// The add row gets an insertion marker, the others a delete marker.
	switch (indexPath.section)
	{
		case 0:
			return UITableViewCellEditingStyleNone;
			break;
		case 1:
			return UITableViewCellEditingStyleNone;
			break;
		case 2:
			if (indexPath.row == [self.schoolsArray count]) {
				return UITableViewCellEditingStyleInsert;
			}
			break;
		case 3:
			if (indexPath.row == [self.worksArray count]) {
				return UITableViewCellEditingStyleInsert;
			}
			break;
		case 4:
			if (indexPath.row == [self.musicsArray count]) {
				return UITableViewCellEditingStyleInsert;
			}
			break;
		case 5:
			if (indexPath.row == [self.moviesArray count]) {
				return UITableViewCellEditingStyleInsert;
			}
			break;
		case 6:
			if (indexPath.row == [self.booksArray count]) {
				return UITableViewCellEditingStyleInsert;
			}
			break;
		case 7:
			if (indexPath.row == [self.hobbiesArray count]) {
				return UITableViewCellEditingStyleInsert;
			}
			break;
		default:
			if (indexPath.row == [self.tvshowsArray count]) {
				return UITableViewCellEditingStyleInsert;
			}
			break;
    }
	return UITableViewCellEditingStyleDelete;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
	
   // If editing is finished, save the managed object context.
	
	if (!editing) {
        
        if ([self.cellText isFirstResponder]) {
            [self.cellText resignFirstResponder];
        }
        /*if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
            [self clearPickerView];
        } */        
        /* Put all the code to sync mysql db
         */
        [self uploadProfileToServer];
        
       		
    }
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		
		// Ensure the cell is not being edited, otherwise the callback in textFieldShouldEndEditing: may look for a non-existent row.
		ProfileEditCell *cell = (ProfileEditCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.cellText resignFirstResponder];
		
		switch (indexPath.section)
		{ 
			// For each of the child entity, find the entity to delete
			// Delete the entity
			// Remove the entity from the entity array and corresponding row from the table view
			case 2:
			{
				School *school = [self.schoolsArray objectAtIndex:indexPath.row];
				[self.profile removeSchoolsObject:school];
				[self.schoolsArray removeObject:school];
			}
				break;
			case 3:
			{
				Work *work = [self.worksArray objectAtIndex:indexPath.row];
				[self.profile removeWorksObject:work];
				[self.worksArray removeObject:work];
			}
				break;
			case 4:
			{
				Music *music = [self.musicsArray objectAtIndex:indexPath.row];
				[self.profile removeMusicsObject:music];
				[self.musicsArray removeObject:music];
			}
				break;
			case 5:
			{
				Movie *movie = [self.moviesArray objectAtIndex:indexPath.row];
				[self.profile removeMoviesObject:movie];
				[self.moviesArray removeObject:movie];
			}
				break;
			case 6:
			{
				Book *book = [self.booksArray objectAtIndex:indexPath.row];
				[self.profile removeBooksObject:book];
				[self.booksArray removeObject:book];
			}
				break;
			case 7:
			{
				Hobby *hobby = [self.hobbiesArray objectAtIndex:indexPath.row];
				[self.profile removeHobbiesObject:hobby];
				[self.hobbiesArray removeObject:hobby];
			}
				break;
			case 8:
			{
				Tvshow *tvshow = [self.tvshowsArray objectAtIndex:indexPath.row];
				[self.profile removeTvshowsObject:tvshow];
				[self.tvshowsArray removeObject:tvshow];
			}
				break;
			default:
				break;
		}
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			
    }
	
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		
		[self insertRowsAnimated:YES inSection:indexPath.section];
		// Don't save yet as the user must set a name.
	}	
}

- (void)insertRowsAnimated:(BOOL)animated inSection:(int)section {
	
	// Create a new instance of entity, insert it into the entity array, and add a corresponding new row to the table view.
	// The entity was added for the current profile, so relate it to the profile.
	// Add the new entity to the entity array and to the table view.
	int entityCount =0;
	switch (section)
	{ 			
		case 2:
		{
			School *school = [NSEntityDescription insertNewObjectForEntityForName:@"School" inManagedObjectContext:self.managedObjectContext];
			[self.profile addSchoolsObject:school];
			[self.schoolsArray addObject:school];
			entityCount = [self.schoolsArray count];
		}
			break;
		case 3:
		{
			Work *work = [NSEntityDescription insertNewObjectForEntityForName:@"Work" inManagedObjectContext:self.managedObjectContext];
			[self.profile addWorksObject:work];
			[self.worksArray addObject:work];
			entityCount = [self.worksArray count];
		}
			break;
		case 4:
		{
			Music *music = [NSEntityDescription insertNewObjectForEntityForName:@"Music" inManagedObjectContext:self.managedObjectContext];
			[self.profile addMusicsObject:music];
			[self.musicsArray addObject:music];
			entityCount = [self.musicsArray count];
		}
			break;
		case 5:
		{
			Movie *movie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.managedObjectContext];
			[self.profile addMoviesObject:movie];
			[self.moviesArray addObject:movie];
			entityCount = [self.moviesArray count];
		}
			break;
		case 6:
		{
			Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
			[self.profile addBooksObject:book];
			[self.booksArray addObject:book];
			entityCount = [self.booksArray count];
		}
			break;
		case 7:
		{
			Hobby *hobby = [NSEntityDescription insertNewObjectForEntityForName:@"Hobby" inManagedObjectContext:self.managedObjectContext];
			[self.profile addHobbiesObject:hobby];
			[self.hobbiesArray addObject:hobby];
			entityCount = [self.hobbiesArray count];
		}
			break;
		case 8:
		{
			Tvshow *tvshow = [NSEntityDescription insertNewObjectForEntityForName:@"Tvshow" inManagedObjectContext:self.managedObjectContext];
			[self.profile addTvshowsObject:tvshow];
			[self.tvshowsArray addObject:tvshow];
			entityCount = [self.tvshowsArray count];
		
						
		}
			break;
		default:
			break;
	}
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:entityCount-1 inSection:section];
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
	if (animated) {
		animationStyle = UITableViewRowAnimationFade;
	}
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animationStyle];
	
	
	// Start editing the tag's name.
	ProfileEditCell *cell = (ProfileEditCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.cellText becomeFirstResponder];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate
/*
 To conform to Human Interface Guildelines, since selecting a row would have no effect (such as navigation), make sure that rows cannot be selected.
 */
/*- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return indexPath;
}*/

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1 || indexPath.row == 0) {
        return;
    }
    if ([self.cellText isFirstResponder]) {
        [self.cellText resignFirstResponder];
    }
    ProfileEditCell *targetCell = (ProfileEditCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *str = targetCell.cellText.text;
	//This is for the datepicker. Check if our date picker is already on screen
	if (indexPath.section == 1 && indexPath.row == 1 && self.pickerView.superview == nil) {				
	
        if (self.sexPickerView.superview != nil){
            [self clearPickerView];
        }
      	if (str == nil) {
			str = @"Jan 01, 1980";
		}
		self.pickerView.date = [self.dateFormatter dateFromString:str];
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
			
			CGRect tabBarFrame = 	self.tabBarController.tabBar.frame;
			newFrame.size.height += tabBarFrame.size.height;
			self.tableView.frame = newFrame;
			[UIView commitAnimations];
		
		}
    
    //This is for the sex picker. Check if our sex picker is already on screen
    if (indexPath.section == 1 && indexPath.row == 2 && self.sexPickerView.superview == nil) {
        
        if (self.pickerView.superview != nil){
            [self clearPickerView];
        }
        self.sexPickerView.delegate = self;
        self.sexPickerView.showsSelectionIndicator = YES;
        
        int row;
        if ([@"Female" isEqualToString:str]) {
            row = 0;
        }
        else
            row = 1;
        [self.sexPickerView selectRow:row inComponent:0 animated:YES];
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
        
        CGRect tabBarFrame = 	self.tabBarController.tabBar.frame;
        newFrame.size.height += tabBarFrame.size.height;
        self.tableView.frame = newFrame;
        [UIView commitAnimations];
            
    }
}*/

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[super viewDidUnload];
    //self.pickerView = nil;
    //self.sexPickerView = nil;
    self.cellText = nil;
    //self.gestureRecognizer = nil;
	// Release any retained subviews of the main view.
}

/*- (void)backgroundTap:(id)sender { 
    if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
        [self clearPickerView];
    }
}*/

#pragma mark -
#pragma mark Editing text fields

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = self.lastSelectedIndexPath;
  
	//Once editing in the textfield is done, assign values to the entities
	switch (indexPath.section)
	{ 
		case 0:
		{
			self.profile.name = textField.text;
		}
			break;
		case 1:
			break;
		case 2:
		{
			School *school = [self.schoolsArray objectAtIndex:indexPath.row];
			school.name = textField.text;
		}
			break;
		case 3:
		{
			Work *work = [self.worksArray objectAtIndex:indexPath.row];
			work.name = textField.text;
		}
			break;
		case 4:
		{
			Music *music = [self.musicsArray objectAtIndex:indexPath.row];
			music.name = textField.text;
		}
			break;
		case 5:
		{
			Movie *movie = [moviesArray objectAtIndex:indexPath.row];
			movie.name = textField.text;
		}
			break;
		case 6:
		{
			Book *book = [self.booksArray objectAtIndex:indexPath.row];
			book.name = textField.text;
		}
			break;
		case 7:
		{
			Hobby *hobby = [self.hobbiesArray objectAtIndex:indexPath.row];
			hobby.name = textField.text;
		}
			break;
		default:
		{
			Tvshow *tvshow = [self.tvshowsArray objectAtIndex:indexPath.row];
			tvshow.name = textField.text;
		}
			break;
		
	}
	
	return YES;
}	

/*- (void) datePicked
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	ProfileEditCell *cell = (ProfileEditCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.pickerView.superview != nil) {
        cell.cellText.text = [self.dateFormatter stringFromDate:self.pickerView.date];
        NSDate *date = [self.dateFormatter dateFromString:cell.cellText.text];
        self.profile.dob = [NSNumber numberWithDouble:[date timeIntervalSince1970]]  ;
        
    }
    
}*/
/*- (void)doneAction
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	ProfileEditCell *cell = (ProfileEditCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.pickerView.superview != nil) {
        cell.cellText.text = [self.dateFormatter stringFromDate:self.pickerView.date];
        NSDate *date = [self.dateFormatter dateFromString:cell.cellText.text];
        self.profile.dob = [NSNumber numberWithDouble:[date timeIntervalSince1970]]  ;
        
    }
    else
    {
         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if([self.sexPickerView selectedRowInComponent:0] == 0){
            cell.cellText.text = @"Female";
            [prefs setBool:YES forKey:@"userSex"];
        }
        else {
            cell.cellText.text = @"Male";
            [prefs setBool:NO forKey:@"userSex"];
        }
        self.profile.sex = cell.cellText.text;
        [prefs synchronize];
        
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
	self.navigationItem.rightBarButtonItem = nil;
	
	// deselect the current table row
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
}*/

/*- (void)clearPickerView
{
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.sexPickerView.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	self.sexPickerView.frame = endFrame;

	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.sexPickerView.frame.size.height;
	CGRect tabBarFrame = 	self.tabBarController.tabBar.frame;
	newFrame.size.height -= tabBarFrame.size.height;
	
	self.tableView.frame = newFrame;
   [self slideDownDidStop];

}*/
/*- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
    self.pickerView.superview != nil? [self.pickerView removeFromSuperview]:[self.sexPickerView removeFromSuperview];
    
}
*/
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	/*if (self.pickerView.superview != nil || self.sexPickerView.superview != nil){
		[self clearPickerView];
        //remove the "Done" button in the nav bar
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        // deselect the current table row
        [self.tableView deselectRowAtIndexPath:path animated:NO];
    }
    */
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview] ;
	NSIndexPath *path = [self.tableView indexPathForCell:cell];
    self.lastSelectedIndexPath = path;
    self.cellText = textField;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;	
}

#pragma mark -
#pragma mark UIPickerView delegate methods


/*- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection   
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	ProfileEditCell *cell = (ProfileEditCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([self.sexPickerView selectedRowInComponent:0] == 0){
        cell.cellText.text = @"Female";
        [prefs setBool:YES forKey:@"userSex"];
    }
    else {
        cell.cellText.text = @"Male";
        [prefs setBool:NO forKey:@"userSex"];
    }
    self.profile.sex = cell.cellText.text;
    [prefs synchronize];
    
}
*/
// tell the picker how many rows are available for a given component
/*- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 2;
    return numRows;
}
*/
// tell the picker how many components it will have
/*- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
*/
// tell the picker the title for a given component
/*- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (row == 0) {
        return @"Female";
    }
    else {
        return @"Male";
    }
        
    
}*/

// tell the picker the width of each row for a given component
/*- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    return sectionWidth;
}
*/
#pragma mark - methods to query profile data from server

- (void) uploadProfileToServer
{
    
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    
    NSString *profileJSON = [self jsonStructureFromManagedObjects:self.profilesArray];
    NSString *schoolsJSON = [self jsonStructureFromManagedObjects:self.schoolsArray];
    NSString *worksJSON = [self jsonStructureFromManagedObjects:self.worksArray];
    NSString *musicsJSON = [self jsonStructureFromManagedObjects:self.musicsArray];
    NSString *booksJSON = [self jsonStructureFromManagedObjects:self.booksArray];
    NSString *moviesJSON = [self jsonStructureFromManagedObjects:self.moviesArray];
    NSString *hobbiesJSON = [self jsonStructureFromManagedObjects:self.hobbiesArray];
    NSString *tvshowsJSON = [self jsonStructureFromManagedObjects:self.tvshowsArray];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:self.profile.userid forKey:@"userid"];
    [params setValue:profileJSON forKey:@"profile"];
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
        /*for (NSString *relationshipName in [relationshipsByName allKeys]) {
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if (![description isToMany]) {
            [valuesDictionary setValue:[self dataStructureForManagedObject:]];
            continue;
        }
        NSSet *relationshipObjects = [managedObject objectForKey:relationshipName];
        NSMutableArray *relationshipArray = [[NSMutableArray alloc] init];
        for (NSManagedObject *relationshipObject in relationshipObjects) {
            [relationshipArray addObject:[self dataStructureForManagedObject:relationshipObject]];
        }
        [valuesDictionary setObject:relationshipArray forKey:relationshipName];
    }*/
    return [valuesDictionary autorelease];
}
    
- (void) profileUploadFinished
{
    //Save data to Core Data as well
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while saving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];

        exit(-1);  // Fail
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.profile.name forKey:@"userName"];
    [prefs synchronize];
   
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
   
	[profile release]; profile = nil;
	[schoolsArray release]; schoolsArray = nil;
	[worksArray release]; worksArray = nil;
	[musicsArray release]; musicsArray = nil;
	[booksArray release]; booksArray = nil;
	[moviesArray release]; moviesArray = nil;
	[hobbiesArray release]; hobbiesArray = nil;
	[tvshowsArray release]; tvshowsArray = nil;
	[profilesArray release]; profilesArray = nil;
	//[pickerView release]; pickerView = nil;
	[dateFormatter release]; dateFormatter = nil;
    [managedObjectContext release]; managedObjectContext = nil;
    //[sexPickerView release]; sexPickerView = nil;
    [cellText release]; cellText = nil;
    
    [request clearDelegatesAndCancel];
    self.request.customHTTPDelegate = nil;
    [request release]; request = nil;
    [lastSelectedIndexPath release]; lastSelectedIndexPath = nil;
    //[gestureRecognizer release]; gestureRecognizer = nil;
    [super dealloc];
}


@end

