//
//  DateProfileView.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 7/11/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "DateProfileView.h"
#import "Constants.h"
#import "DatesTableView.h"
#import "EGOPhotoGlobal.h"
#import "MyPhotoSource.h"
#import "MyPhoto.h"
#import "ChatPageViewController.h"
#import "Common.h"

@interface DateProfileView ()

- (void)startIconDownload:(UIImage *)img path:(NSString*)path forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DateProfileView

@synthesize dateUserid, request, sectionTitle, dateUserName;
@synthesize cachedUserId, dateProfileVO;
@synthesize delegate;
@synthesize spinner, refreshHeaderView;
@synthesize thumbnail;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dateUserId:(NSNumber*)userId dateUserName: (NSString*)userName cachedUserId:(NSNumber*)cachedId dateProfile:(CachedProfileVO*)dateProfile delegate:(id<DateProfileViewDelegate>) del
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        NSArray * tempArray = [[NSArray alloc] initWithObjects:@"", @"Networks", @"Music", @"Movies", @"Books", @"Hobbies", @"TV Shows", nil];
        self.sectionTitle = tempArray;
        [tempArray release];
        
        
        self.dateUserid = userId;
        self.dateUserName = userName;
                  
        if (cachedId) {
            self.cachedUserId = cachedId;
            self.dateProfileVO = dateProfile;
        }
        self.delegate = del;
    }
    return self;
}
#pragma mark - Memory Management

- (void)dealloc
{
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel];
    [request release]; request = nil;
    [dateUserid release]; dateUserid = nil;
    [dateUserName release]; dateUserName = nil;
    [sectionTitle release]; sectionTitle = nil;
    [cachedUserId release]; cachedUserId = nil;
    [dateProfileVO release]; dateProfileVO = nil;
    [spinner release]; spinner = nil;
    [refreshHeaderView release]; refreshHeaderView = nil;
    [thumbnail release]; thumbnail = nil;
   
    [super dealloc];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.spinner = nil;
    self.refreshHeaderView = nil;
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
    //[Common setTheme:self.parentViewController forTableView:self.tableView];//#v2.1
    [Common setSearchViewTheme:self.tableView]; //#v2.1
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Chat" style:UIBarButtonItemStylePlain target:self action:@selector(initiateChat)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
	[rightBarButtonItem release];
    
    //MBProgressHUD start
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [HUD setCenter:CGPointMake(160.0, 200.0)];
	
    self.spinner = HUD;
    [HUD release]; HUD = nil;
	[self.view addSubview:self.spinner];
	
	
	  //MBProgressHUD end
  
	EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    view.delegate = self;
    self.refreshHeaderView = view;
    [self.tableView addSubview:self.refreshHeaderView];
    [view release];
    
   	//  update the last update date
	[self.refreshHeaderView refreshLastUpdatedDate];
    
    if (self.cachedUserId == nil || ![self.cachedUserId isEqualToNumber:self.dateUserid]) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        //Clean up dateprofileVO to get rid of any stale values
        self.dateProfileVO = nil;
        
        //Initialize the model
        CachedProfileVO *vo = [[CachedProfileVO alloc] init];
        self.dateProfileVO = vo;
        [vo release];
        
        //Now query up new profile info
        [self.spinner show:YES];
        [self queryProfile];
    }

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
    //self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"snow.jpg"]];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientation
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionTitle count] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == ONE) {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *dateProfileIdentifier = @"DateProfileCell";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL isFemaleFlag = [prefs boolForKey:@"userSex"];
    
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dateProfileIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:dateProfileIdentifier] autorelease];
	}
	
	//Need to clear any images set before
    cell.imageView.image = nil;
    cell.imageView.userInteractionEnabled = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView *view in cell.imageView.subviews){
        [view removeFromSuperview];
    }
    
    UIButton *button;
	switch (indexPath.section)
	{
		case 0:
             if (self.dateProfileVO.face != nil) {
                if (!self.dateProfileVO.faceImg) {
                    
                    //download image code
                    [self startIconDownload:self.thumbnail.dateIcon path:self.dateProfileVO.face forIndexPath:indexPath];
                    if (isFemaleFlag) {
                        cell.imageView.image = [UIImage imageNamed:@"nonrevealed.png"];
                    }
                    else {
                        cell.imageView.image = [UIImage imageNamed:@"nonrevealed_f.png"];
                    }
                    
                }
                else
                {
                     cell.imageView.image = self.dateProfileVO.faceImg;
                    
                }
                
            }
            else
            {
                if (isFemaleFlag) {
                    cell.imageView.image = [UIImage imageNamed:@"nonrevealed.png"];
                }else {
                    cell.imageView.image = [UIImage imageNamed:@"nonrevealed_f.png"];
                }
                
            }
        
            [cell.imageView.layer setCornerRadius:10.0];
            cell.imageView.layer.masksToBounds = YES;
            [cell.imageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
            [cell.imageView.layer setBorderWidth: 2.0];

            button = [UIButton buttonWithType:UIButtonTypeCustom];
           
            [button setFrame:CGRectMake(5,0,120,150)];
            [button addTarget:self action:@selector(navigateToPhotos) forControlEvents:UIControlEventTouchUpInside];
            cell.imageView.userInteractionEnabled = YES;
            [cell.imageView addSubview:button];
            
            [cell.detailTextLabel setFrame:CGRectMake(120, 50, 200, 150)];
            
            cell.detailTextLabel.text = self.dateProfileVO.name;
            break;
			
		case 1:
			if (indexPath.row == 0) {
                //NSString *test = @"\u00c9cole";
				cell.detailTextLabel.text =  self.dateProfileVO.schools;
			}
			else {
				cell.detailTextLabel.text = self.dateProfileVO.works;
			}
			
			
			break;
		case 2:
			cell.detailTextLabel.text = self.dateProfileVO.musics;
			break;
		case 3:
			cell.detailTextLabel.text = self.dateProfileVO.movies;
			break;
		case 4:			
            cell.detailTextLabel.text = self.dateProfileVO.books;
			break;
		case 5:
			cell.detailTextLabel.text = self.dateProfileVO.hobbies;
			break;
		default:
			cell.detailTextLabel.text = self.dateProfileVO.tvshows;
			break;
            
	}
	cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.detailTextLabel.numberOfLines = 0;

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
            if (indexPath.row == 0) {
                return [self cellRowHeight:self.dateProfileVO.schools];
            }
            else {
                return [self cellRowHeight:self.dateProfileVO.works];
            }
            break;
        case 2:
            return [self cellRowHeight:self.dateProfileVO.musics];
            break;
        case 3:
            return [self cellRowHeight:self.dateProfileVO.movies];
            break;
        case 4:
            return [self cellRowHeight:self.dateProfileVO.books];
            break;
        case 5:
            return [self cellRowHeight:self.dateProfileVO.hobbies];
            break;
        default:
            return [self cellRowHeight:self.dateProfileVO.tvshows];
            break;
	}
	
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


#pragma mark - methods to query profile data from server

- (void) queryProfile
{
    [self.request clearDelegatesAndCancel]; 
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.dateUserid forKey:@"dateuserid"];
    [dict setValue:[NSNumber numberWithInt:[prefs integerForKey:@"userId"]] forKey:@"userid"];    
    
    NSString *userSex = [prefs boolForKey:@"userSex"] == YES? @"Female":@"Male";
    [dict setValue:userSex forKey:@"usersex"];
    [dict setValue:@"dateprofile" forKey:@"script"];

    [self.request setCustomHTTPDelegate:self];
    self.request.tag = REQUEST_FOR_DATE_PROFILE;
    [self.request setPostValues:dict];

}

#pragma mark - photo display methods

- (void)navigateToPhotos {
    
    MyPhotoSource *source =[[MyPhotoSource alloc] initWithPhotos:[NSMutableArray arrayWithObjects:nil]];
    MyPhoto *photo; 
    int zeroPhotoFlag = 1;
  
    for (NSString *obj in self.dateProfileVO.photos) {
		if (obj != nil && ![obj isEqualToString:@""]) {
			photo = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:obj] name:@""];
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

    EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source andViewOnlyMode:YES];

	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
	
	navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	navController.modalPresentationStyle = UIModalPresentationFullScreen;
	
	[self presentModalViewController:navController animated:YES];
	
	[navController release];
	[photoController release];
	[source release];


}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	    
	_reloading = YES;
    //Clean up dateprofileVO to get rid of any stale values
    self.dateProfileVO = nil;
    self.thumbnail = nil;
    
    //Initialize the model
    CachedProfileVO *vo = [[CachedProfileVO alloc] init];
    self.dateProfileVO = vo;
    [vo release];
    
    //Now query up new profile info
    [self queryProfile];
    
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    [self.spinner hide:YES];
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	//if (![self.searchDisplayController isActive]) {
		[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	//}
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


#pragma mark - methods related to the chat interface

- (void) initiateChat
{
    for (UIViewController *v in self.tabBarController.viewControllers)
    {
        UIViewController *vc = v;
        
        if ([v isKindOfClass:[UINavigationController class]])
        {
                 vc = [(UINavigationController*)v visibleViewController];
        }
             
        if ([vc isKindOfClass:[ChatPageViewController class]])
        {
            ChatPageViewController *myViewController = (ChatPageViewController*)vc;
            myViewController.activeUserId = self.dateUserid;
            myViewController.activeUserName = self.dateUserName;
            
        }
    }
    self.tabBarController.selectedIndex = 2;
    

}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(UIImage *)img path:(NSString*)path forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = self.thumbnail;
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgURLString = path;
        iconDownloader.dateIcon = img;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        iconDownloader.smallThumbnail = NO;
        self.thumbnail =  [[[IconDownloader alloc] init] autorelease];
        self.thumbnail = iconDownloader;
        [iconDownloader startDownload];
        [iconDownloader release];   
        
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)dateImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = self.thumbnail;
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.dateIcon;

        self.thumbnail.dateIcon = iconDownloader.dateIcon;
        self.dateProfileVO.faceImg = iconDownloader.dateIcon;
    }
}

- (void)dateProfileDidDownload:(CachedProfileVO *)vo
{
    self.dateProfileVO  = vo;
    self.cachedUserId = self.dateUserid;
    [self.delegate queriedProfile:self.dateProfileVO withId:self.dateUserid];
    [self.tableView reloadData];
    [self doneLoadingTableViewData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
	
}
    
@end
