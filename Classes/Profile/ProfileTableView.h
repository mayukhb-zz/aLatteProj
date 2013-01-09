//
//  ProfileTableView.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/28/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import <CoreData/CoreData.h>
#import "ProfileTableEdit.h"
#import "ASIHTTPRequest.h"
#import "EGOPhotoViewController.h"

@interface ProfileTableView : UITableViewController <UINavigationControllerDelegate, EGOPhotoViewControllerDelegate>{

	NSArray *sectionTitle;
	UITextView *cellTextView;

	NSManagedObjectContext *managedObjectContext;
	NSMutableArray *profilesArray;
	
	Profile *profile;
	NSMutableArray *schoolsArray;
	NSMutableArray *worksArray;
	NSMutableArray *musicsArray;
	NSMutableArray *booksArray;
	NSMutableArray *moviesArray;
	NSMutableArray *hobbiesArray;
	NSMutableArray *tvshowsArray;
	NSMutableArray *photosArray;

}

@property (nonatomic, retain) NSArray *sectionTitle;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	 
@property (nonatomic, retain) NSMutableArray *profilesArray;
@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) NSMutableArray *schoolsArray;
@property (nonatomic, retain) NSMutableArray *worksArray;
@property (nonatomic, retain) NSMutableArray *musicsArray;
@property (nonatomic, retain) NSMutableArray *booksArray;
@property (nonatomic, retain) NSMutableArray *moviesArray;
@property (nonatomic, retain) NSMutableArray *hobbiesArray;
@property (nonatomic, retain) NSMutableArray *tvshowsArray;
@property (nonatomic, retain) NSMutableArray *photosArray;

-(CGFloat) cellRowHeight:(NSString *)cellText;
-(NSString *) getTextFromEntityArray:(NSMutableArray *)entityArray;
- (void) navigateToPhotos;
- (void) navigateToEdit;
- (void) navigateToSettings;

@end
