//
//  DatesTableView.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 6/30/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "DatesTableView.h"
#import "Common.h"
#import "ViewHandler.h"
#import "Constants.h"
#import "DateProfileView.h"
#import "RevealTutorialViewController.h"

@interface DatesTableView ()

- (void)startIconDownload:(UIImage *)img path:(NSString*)path forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DatesTableView

@synthesize latitude, longitude, locationTitle, userid, request, dateArray, pathArray, placesArray,useridArray, lastCheckedinLocation;
@synthesize cachedUserId, cachedProfileVO, spinner, refreshHeaderView;
@synthesize image, isCheckedIn;
@synthesize imageDownloadsInProgress;
@synthesize tableView;
@synthesize isLoadingMoreDates; //v2 load more dates feature
@synthesize isMoreDatesAvailable; //v2 for the load more feature
@synthesize loadMoreDatesView;  //v2 load more dates feature
@synthesize mainLabel, subtitleLabel, titleLabel; //v2

#pragma mark - Memory Management

- (void)dealloc
{
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel];
    [request release]; request = nil;
    
    [userid release]; userid = nil;
    [cachedUserId release]; cachedUserId = nil;
    [locationTitle release]; locationTitle = nil;
    
    [useridArray release]; useridArray = nil;
    [dateArray release]; dateArray = nil;
    [pathArray release]; pathArray = nil;
    [placesArray release]; placesArray = nil;
    [lastCheckedinLocation release]; lastCheckedinLocation = nil;
    [cachedProfileVO release]; cachedProfileVO = nil;
    [spinner release]; spinner = nil;
    [refreshHeaderView release]; refreshHeaderView = nil;
    [imageDownloadsInProgress release]; imageDownloadsInProgress = nil;
    [tableView release]; tableView = nil;
    [loadMoreDatesView release]; loadMoreDatesView = nil; //v2 load more dates feature
    [mainLabel release]; mainLabel = nil;
    [subtitleLabel release]; subtitleLabel = nil;
    [titleLabel release]; titleLabel = nil;
    
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
    UIImage* img = [UIImage imageNamed:@"background.png"];
    UIImageView *imgView = [[[UIImageView alloc] initWithImage: img] autorelease];
    [self.view addSubview: imgView];
    imgView.center = CGPointMake(160, 175); 
    if (!self.imageDownloadsInProgress) {
        self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    }
  
    if (!self.useridArray) {
        //Initialize userid array
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.useridArray = tempArray;
        [tempArray release]; tempArray = nil;
    }
    
    if(!self.dateArray){
        //Initialize the date arrays
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.dateArray = tempArray;
        [tempArray release]; tempArray = nil;
        
    }
   
    if(!self.pathArray){
        //Initialize the path arrays
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.pathArray = tempArray;
        [tempArray release]; tempArray = nil;
        
    }
    
    if(!self.placesArray){
        //Initialize the places arrays
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.placesArray = tempArray;
        [tempArray release]; tempArray = nil;
        
    }
     
    //MBProgressHUD start
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [HUD setCenter:CGPointMake(160.0, 200.0)];
	
    self.spinner = HUD;
    [HUD release]; HUD = nil;
	[self.view addSubview:self.spinner];
	
	
	[self.spinner show:YES];
    //MBProgressHUD end
   
    EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshView.delegate = self;
    self.refreshHeaderView = refreshView;
    [self.tableView addSubview:self.refreshHeaderView];
    [refreshView release];refreshView = nil;
	
   	//  update the last update date
	[self.refreshHeaderView refreshLastUpdatedDate];
    _reloading = YES;
    self.isLoadingMoreDates = NO; //v2 load more dates feature
    self.isMoreDatesAvailable = YES; //v2 for the load more feature
    [self findNearbyDates];
    [self.spinner show:YES];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    [self addTutorialView];//v2
     
    /*v2 start*/
    UIActivityIndicatorView *tempView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadMoreDatesView = tempView;
    [tempView release]; tempView = nil;
    
    UILabel *tempMainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 30)];
    tempMainLabel.font = [UIFont boldSystemFontOfSize:18.0];
    tempMainLabel.textColor = [UIColor whiteColor];
    tempMainLabel.textAlignment = UITextAlignmentCenter;
    tempMainLabel.backgroundColor = [UIColor clearColor];
    tempMainLabel.text = @"Near Me";
    self.mainLabel = tempMainLabel;
    [tempMainLabel release]; tempMainLabel = nil;
    
    UILabel *tempSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 310, 15)];
    tempSubTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    tempSubTitleLabel.textColor = [UIColor whiteColor];
    tempSubTitleLabel.textAlignment = UITextAlignmentCenter;
    tempSubTitleLabel.backgroundColor = [UIColor clearColor];
    if ([prefs valueForKey:@"currentLocation"] != nil) {
        tempSubTitleLabel.text = [prefs valueForKey:@"currentLocation"];
    }
    self.subtitleLabel = tempSubTitleLabel;
    [tempSubTitleLabel release]; tempSubTitleLabel = nil;
    
    UILabel *tempTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 44)];
    tempTitleLabel.backgroundColor = [UIColor clearColor];
    tempTitleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel = tempTitleLabel;
    [tempTitleLabel release]; tempTitleLabel = nil;
    
    [self.titleLabel addSubview:self.mainLabel];
    [self.titleLabel addSubview:self.subtitleLabel];
    self.navigationItem.titleView = self.titleLabel;
     
    /*v2 end */
    [self.view addSubview: self.tableView];
    
}

/* v2 start */
- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
 
    if([prefs boolForKey:@"nearmeNeedsRefresh"])
    {
        [self addTutorialView];
        if ([prefs valueForKey:@"currentLocation"] != nil) {
            self.subtitleLabel.text = [prefs valueForKey:@"currentLocation"];
        }

        _reloading = YES;
        self.isLoadingMoreDates = NO; //v2 load more dates feature
        self.isMoreDatesAvailable = YES; //v2 for the load more feature
        [self findNearbyDates];
        [self.spinner show:YES];
    }
}

/* v2 end */
- (void) addTutorialView
{
    //clear any tutorial view first
    [ViewHandler removeSubviewsFrom:self.view withTag:1];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //[prefs setInteger:0 forKey:@"tutorial"]; [prefs synchronize]; 
    int tutorial = [prefs integerForKey:@"datesTutorial"] ;
    
    if (tutorial != 2 && [prefs valueForKey:@"currentLocation"] != nil && [[prefs valueForKey:@"currentLocation"] length] > 0 ) {
        NSArray *tutorialImages = [NSArray arrayWithObjects:
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner.png"],
                                   [UIImage imageNamed:@"banner1.png"],
                                   [UIImage imageNamed:@"banner2.png"],
                                   [UIImage imageNamed:@"banner3.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   [UIImage imageNamed:@"banner0.png"],
                                   nil];
        
        
        
        UIImageView *tutorialImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 30)];
        tutorialImageView.animationImages = tutorialImages;
        UIButton *tutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tutorialButton.frame = tutorialImageView.frame;
        
        tutorialImageView.animationDuration = 1; // seconds
        tutorialImageView.animationRepeatCount = 0; // 0 = loops forever
        [tutorialButton addSubview:tutorialImageView];
        [tutorialImageView startAnimating];
        [tutorialImageView release]; tutorialImageView = nil;
        [tutorialButton addTarget:self action:@selector(didClickTutorial) forControlEvents:UIControlEventTouchUpInside];
        tutorialButton.tag = 1;
        [self.view addSubview:tutorialButton];
        [self.tableView setFrame:CGRectMake(0.0f, 30, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        
    }
    else
    {
        [self.tableView setFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        
    }

}
/*v2 start */
/*v2 end */
- (void) didClickTutorial
{
    RevealTutorialViewController *tutorialViewController = [[RevealTutorialViewController alloc] initWithNibName:@"RevealTutorialViewController" bundle:nil fromDatesTable:YES];
    tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.navigationController presentModalViewController:tutorialViewController animated:YES]; 
    [tutorialViewController release];
    [self.tableView setFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    
    [ViewHandler removeSubviewsFrom:self.view withTag:1];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int tutorial = [prefs integerForKey:@"datesTutorial"] ;
    [prefs setInteger:tutorial+1 forKey:@"datesTutorial"];
    [prefs synchronize];
    
    return;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.refreshHeaderView = nil;
    self.spinner = nil;
    self.tableView = nil;
    self.loadMoreDatesView = nil; //v2 load more dates feature
    self.mainLabel = nil;//v2
    self.subtitleLabel = nil; //v2
    self.titleLabel = nil; //v2
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([self.dateArray count] == 0){
        return 1;
    }
    else
    {
        return [self.dateArray count]+1; //v2 added +1 for spinner in last row.
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DateCellIdentifier = @"DateCellIdentifier";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL isFemaleFlag = [prefs boolForKey:@"userSex"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DateCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DateCellIdentifier] autorelease];
    }
    
    //Need to clear any settings set before
    
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone; //v2
    cell.userInteractionEnabled = YES; //v2
  
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.detailTextLabel.text = nil;
    cell.accessoryView = nil;
    //[self.loadMoreDatesView stopAnimating];
    
    if(indexPath.row == [self.dateArray count] && indexPath.row == 0 && !_reloading){
        
        if (!self.isCheckedIn) {
            cell.textLabel.text = @"Check in to discover people near you";
            cell.detailTextLabel.text = @"Pull down to refresh.."; //v2p1
        }
        else {
            
            cell.textLabel.text = @"No one near you found";
            cell.detailTextLabel.text = @"Pull down to refresh.."; //v2p1
            cell.userInteractionEnabled = NO; //v2
        }
     
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.textLabel.textColor = [UIColor colorWithRed:.1 green:0.4 blue:0.5 alpha:1];
        cell.textLabel.shadowColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.7];
        cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);

        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.selectionStyle = UITableViewCellSelectionStyleNone; v2p1
        return cell;
    }
    /*v2 start */
    if(indexPath.row == [self.dateArray count] && indexPath.row != 0 && !_reloading)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        cell.textLabel.text = @"";
        if (self.isMoreDatesAvailable) {
            cell.accessoryView = self.loadMoreDatesView;
            self.isLoadingMoreDates = YES;
            [self.loadMoreDatesView startAnimating];
            [self findNearbyDates];
        }
        return cell;
    }
    /*v2 end */
 
     if ([self.dateArray count] > indexPath.row) {
        cell.textLabel.text = [self.dateArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.placesArray objectAtIndex:indexPath.row]; 
         
         
         // Only load cached images; defer new downloads until scrolling ends
         if (![[self.pathArray objectAtIndex:indexPath.row] isEqualToString:@"null"])
         {
             if (![[self.imageDownloadsInProgress objectForKey:indexPath] dateIcon] ) 
             {
                 
                 if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
                 {
                     [self startIconDownload:[[self.imageDownloadsInProgress objectForKey:indexPath] dateIcon] path:[self.pathArray objectAtIndex:indexPath.row] forIndexPath:indexPath];
                 }
                 // if a download is deferred or in progress, return a placeholder image
                 cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];                
             }
             else
             {
                 cell.imageView.image = [[self.imageDownloadsInProgress objectForKey:indexPath] dateIcon];
                 
             }
         }
         else
         {
             if (isFemaleFlag) {
                 cell.imageView.image = [UIImage imageNamed:@"noimage.png"]; 
             }
             else {
                 cell.imageView.image = [UIImage imageNamed:@"noimage_f.png"];
             }
             
             
         }
       
       /*  if (![[self.pathArray objectAtIndex:indexPath.row] isEqualToString:@"null"]) {
             [self.request cancel];
             self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.pathArray objectAtIndex:indexPath.row]]];
             [self.request startSynchronous];
             NSError *error = [self.request error];
             if (!error) {
                 img = [UIImage imageWithData: [self.request responseData]];
                 cell.imageView.image = img;
             }
             // img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.pathArray objectAtIndex:indexPath.row]]]];
             
             
         }*/
         //cell.imageView.layer.masksToBounds = YES;
         //cell.imageView.layer.cornerRadius = 5.0;
         
         [cell.imageView.layer setCornerRadius:10.0];
         cell.imageView.layer.masksToBounds = YES;
         [cell.imageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
         [cell.imageView.layer setBorderWidth: 2.0];
         
         cell.textLabel.textAlignment = UITextAlignmentLeft;
         cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
         cell.textLabel.textColor = [UIColor colorWithRed:.1 green:0.4 blue:0.5 alpha:1];
         cell.textLabel.shadowColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.7];
         cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
    // Navigation logic may go here. Create and push another view controller.
    if(indexPath.row == [self.dateArray count] && indexPath.row == 0){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];//v2p1
        self.tabBarController.selectedIndex = 0;//v2p1
        return;
    }
   
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
     NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
     NSNumber *dateId = [f numberFromString:[self.useridArray objectAtIndex:indexPath.row]];
    DateProfileView *dateProfileView = [[DateProfileView alloc] initWithNibName:@"DateProfileView" bundle:nil dateUserId:dateId dateUserName:[self.dateArray objectAtIndex:indexPath.row] cachedUserId:self.cachedUserId dateProfile:self.cachedProfileVO delegate:self];
    
     [self.navigationController pushViewController:dateProfileView animated:YES];
     [dateProfileView release];
     [f release];

}

#pragma mark - Methods to get nearby dates

- (void) findNearbyDates {
   
    [self.request clearDelegatesAndCancel]; 
    self.request = nil;
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
   
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [params setValue:[NSNumber numberWithInteger:[prefs integerForKey:@"userId"]] forKey:@"userid"];
    NSString *userSex = [prefs boolForKey:@"userSex"] == YES? @"1":@"0";
    [params setValue:userSex forKey:@"usersex"];
    
    [params setValue:[NSNumber numberWithInteger:[prefs integerForKey:@"range"]] forKey:@"range"];
    /* v2 start*/
    NSNumber *fetchstart = [NSNumber numberWithInt:0];
    if (self.isLoadingMoreDates) {
        fetchstart = [NSNumber numberWithInteger:[self.dateArray count]];
    }
    [params setValue:fetchstart forKey:@"fetchstart"];
    /* v2 end*/
    [params setValue:@"nearbydates" forKey:@"script"];
    [self.request setCustomHTTPDelegate:self];
    self.request.tag = REQUEST_FOR_NEARBY_DATES;
    [self.request setPostValues:params];
}


- (void)nearbyDatesDidFound:(BOOL) isCheckedInParam userIdArray:(NSArray*)userIdArrayParam dateArray:(NSArray*)dateArrayParam placesArray:(NSArray*)placesArrayParam pathArray:(NSArray*)pathArrayParam
{
    //v2 load more dates feature
    if ((userIdArrayParam == nil || [userIdArrayParam count] == 0) && self.isLoadingMoreDates) {
        [self.loadMoreDatesView stopAnimating];
        self.isMoreDatesAvailable = NO;
    }
    //else {
      //  [self.loadMoreDatesView startAnimating];
    //}
    // v2 start load more dates feature
    if (!self.isLoadingMoreDates) {
        [self.useridArray removeAllObjects];
        [self.dateArray removeAllObjects];
        [self.pathArray removeAllObjects];
        [self.placesArray removeAllObjects];
    }
    
    
    self.isCheckedIn = isCheckedInParam;
    
    if (userIdArrayParam != nil) {
        [self.useridArray addObjectsFromArray:userIdArrayParam];
        [self.dateArray addObjectsFromArray:dateArrayParam];
        [self.placesArray addObjectsFromArray:placesArrayParam];
        [self.pathArray addObjectsFromArray:pathArrayParam];
        
        [self.imageDownloadsInProgress removeAllObjects];
    }
    [self.tableView reloadData];

    [self doneLoadingTableViewData];

}

- (void) queriedProfile: (CachedProfileVO*)cachedProfile withId:(NSNumber *)userId
{
    self.cachedProfileVO = cachedProfile;
    self.cachedUserId = userId;
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    _reloading = YES;
    self.isLoadingMoreDates = NO; //v2 load more dates feature
    self.isMoreDatesAvailable = YES; //v2 load more dates feature 
    [self findNearbyDates];
    
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    
    [self.spinner hide:YES];
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    /*v2 start */
    [self.loadMoreDatesView stopAnimating];
    self.isLoadingMoreDates = NO;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:NO forKey:@"nearmeNeedsRefresh"];
    [prefs synchronize];
    /*v2 end */
	
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
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{

	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(UIImage *)img path:(NSString*)path forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgURLString = path;
        iconDownloader.dateIcon = img;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        iconDownloader.smallThumbnail = YES;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.pathArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            /* v2 start */
            if (indexPath.row == [dateArray count]) {
                break;
            }
            /* v2 end */
            UIImage *img = [[self.imageDownloadsInProgress objectForKey:indexPath] dateIcon];
            
            if (!img) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:img path:[self.pathArray objectAtIndex:indexPath.row] forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)dateImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.dateIcon;
        
        ((IconDownloader*)[self.imageDownloadsInProgress objectForKey:indexPath]).dateIcon = iconDownloader.dateIcon;
        //[self.imgDict setObject:iconDownloader.dateIcon forKey:indexPath];
    }
}



@end
