//
//  ProfileTableEdit.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 5/15/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Profile.h"
#import "ProfileEditCell.h"
#import "Constants.h"
#import "CustomHTTPRequest.h"

@interface ProfileTableEdit : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, CustomHTTPRequestDelegate> {

	NSManagedObjectContext *managedObjectContext;
	NSMutableArray *profilesArray;
	NSMutableArray *schoolsArray;
	NSMutableArray *worksArray;
	NSMutableArray *musicsArray;
	NSMutableArray *booksArray;
	NSMutableArray *moviesArray;
	NSMutableArray *hobbiesArray;
	NSMutableArray *tvshowsArray;
	
	ProfileEditCell *profileEditCell;
	Profile *profile;
	
	//UIDatePicker *pickerView;
    //UIPickerView *sexPickerView;
	NSDateFormatter *dateFormatter;
    UITextField *cellText;
    
    CustomHTTPRequest *request;
    NSIndexPath *lastSelectedIndexPath;
    //UITapGestureRecognizer *gestureRecognizer;
		
}

@property (nonatomic, assign) IBOutlet ProfileEditCell *profileEditCell;

@property (nonatomic, retain) Profile *profile;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	

@property (nonatomic, retain) NSMutableArray *profilesArray;
@property (nonatomic, retain) NSMutableArray *schoolsArray;
@property (nonatomic, retain) NSMutableArray *worksArray;
@property (nonatomic, retain) NSMutableArray *musicsArray;
@property (nonatomic, retain) NSMutableArray *booksArray;
@property (nonatomic, retain) NSMutableArray *moviesArray;
@property (nonatomic, retain) NSMutableArray *hobbiesArray;
@property (nonatomic, retain) NSMutableArray *tvshowsArray;

@property (nonatomic, retain) NSDateFormatter *dateFormatter; 
//@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;
//@property (nonatomic, retain) IBOutlet UIPickerView *sexPickerView;
@property (nonatomic, retain) UITextField *cellText;
@property (nonatomic, retain) NSIndexPath *lastSelectedIndexPath;

@property (retain, nonatomic) CustomHTTPRequest *request;
//@property (nonatomic, retain) UITapGestureRecognizer *gestureRecognizer;

- (void)insertRowsAnimated:(BOOL)animated inSection:(int)section;
//- (void) doneAction;
//- (void) slideDownDidStop;
//- (void) clearPickerView;
- (void) uploadProfileToServer;
//- (void) datePicked;
//- (void)backgroundTap:(id)sender ;

- (NSString*)jsonStructureFromManagedObjects:(NSArray*)managedObjects;
- (NSArray*)dataStructuresFromManagedObjects:(NSArray*)managedObjects;
- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject;
- (id)initWithStyle:(UITableViewStyle)style manageObjectContext:(NSManagedObjectContext*)mo;

@end
