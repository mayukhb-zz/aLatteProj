//
//  LocationsMap.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "LocationsMap.h"
#import "MapDataParser.h"
#import "MapLocationVO.h"
#import "ShowMap.h"
#import "Common.h"
#import "ErrorHandler.h"
#import "LoginViewController.h"


@implementation LocationsMap

@synthesize mapDataParser, currentLocation, searchKeyword, searchBar;
@synthesize refreshHeaderView, spinner, refreshTime;
@synthesize showCoverPage;
@synthesize didUpdateLocationThreshold;
@synthesize iconMap; //v2

- (void) dismissCoverPage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    sleep(3);
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [pool drain];
   
}
- (void)viewDidLoad {
    
    if (!self.showCoverPage) {
        self.showCoverPage = [NSNumber numberWithInt:0];
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self.navigationController presentModalViewController:login animated:NO]; 
        [login release];
   
        [self performSelectorInBackground:@selector(dismissCoverPage) withObject:nil];
        
    }
    [Common setTheme:self.parentViewController forTableView:self.tableView];
    
   
    //MBProgressHUD start
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [HUD setCenter:CGPointMake(160.0, 200.0)];
    //HUD.delegate = self;
	
    self.spinner = HUD;
    [HUD release]; HUD = nil;
	[self.view addSubview:self.spinner];
	
	
	[self.spinner show:YES];
    //MBProgressHUD end
    
    EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshView.delegate = self;
    self.refreshHeaderView = refreshView;
    [self.tableView addSubview:self.refreshHeaderView];
    [refreshView release]; refreshView = nil;
		
	
   	//  update the last update date
	[self.refreshHeaderView refreshLastUpdatedDate];
    self.refreshTime = [NSDate date];
    
    //Find all businesses nearby
    [self findLocationsByKeyword:@"*"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /*v2 start initialize nsdictionary for icons*/
    NSArray *keys = [NSArray arrayWithObjects:@"accounting", @"airport",@"amusement_park",@"aquarium",@"art_gallery",@"atm",@"bakery",@"bank",@"bar",@"beauty_salon",@"bicycle_store", @"book_store",@"bowling_alley",@"bus_station",@"cafe",@"campground",@"car_dealer",@"car_rental",@"car_repair",@"car_wash",@"casino", @"cemetery",@"church",@"city_hall",@"clothing_store",@"convenience_store",@"courthouse",@"dentist",@"department_store",@"doctor",@"electrician", @"electronics_store",@"embassy",@"establishment",@"finance",@"fire_station",@"florist",@"food",@"funeral_home",@"furniture_store",@"gas_station", @"general_contractor",@"grocery_or_supermarket",@"gym",@"hair_care",@"hardware_store",@"health",@"hindu_temple",@"home_goods_store",@"hospital",@"insurance_agency", @"jewelry_store",@"laundry",@"lawyer",@"library",@"liquor_store",@"local_government_office",@"locksmith",@"lodging",@"meal_delivery",@"meal_takeaway", @"mosque",@"movie_rental",@"movie_theater",@"moving_company",@"museum",@"night_club",@"painter",@"park",@"parking",@"pet_store", @"pharmacy",@"physiotherapist",@"place_of_worship",@"plumber",@"police",@"post_office",@"real_estate_agency",@"restaurant",@"roofing_contractor",@"rv_park", @"school",@"shoe_store",@"shopping_mall",@"spa",@"stadium",@"storage",@"store",@"subway_station",@"synagogue",@"taxi_stand", @"train_station",@"travel_agency",@"university",@"veterinary_care",@"zoo", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"finance", @"airport", @"park", @"aquarium",@"art",@"finance",@"restaurant",@"finance",@"bar",@"grocery",@"grocery",@"grocery",@"entertainment",@"transportation",@"restaurant",@"park",@"misc",@"misc",@"misc",@"misc",@"casino",@"misc",@"worship",@"public_place",@"mall",@"grocery",@"public_place",@"misc",@"mall",@"misc",@"misc",@"grocery",@"public_place",@"misc",@"finance",@"misc",@"grocery",@"restaurant",@"misc",@"grocery",@"gas",@"misc",@"grocery",@"gym",@"grocery",@"grocery",@"misc",@"worship",@"grocery",@"hospital",@"misc",@"grocery",@"misc",@"misc",@"library",@"grocery",@"public_place",@"misc",@"hotel",@"misc",@"misc",@"worship",@"grocery",@"movie",@"misc",@"museum",@"bar",@"misc",@"park",@"misc",@"grocery",@"grocery",@"misc",@"worship",@"misc",@"misc",@"public_place",@"misc",@"restaurant",@"misc",@"misc",@"school",@"grocery",@"mall",@"misc",@"stadium",@"misc",@"grocery",@"transportation",@"worship",@"transportation",@"transportation",@"misc",@"school",@"misc",@"zoo", nil];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    self.iconMap = dict;
    [dict release]; dict = nil;
    /*v2 end */
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.refreshHeaderView = nil;
    self.spinner = nil;
    
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	[self findLocationsByKeyword:searchText];
	
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	// Return YES to cause the search result table view to be reloaded.
    /*for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews)
    { 
        [subview removeFromSuperview]; 
    }*/
    //Commented out the code above to prevent crash on location search in iOS6 //#v2.1
    [controller.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [controller.searchResultsTableView setRowHeight:800];
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	
    [Common setSearchViewTheme:self.searchDisplayController.searchResultsTableView];
    [self.searchDisplayController.searchResultsTableView setRowHeight:44];
   	[self filterContentForSearchText:searchBar.text];
    
}

-(void) findLocationsByKeyword:(NSString *)keyword
{
	// if we haven't gotten the user's location yet, create an instance of CLLocationManager to find it.
	// Otherwise, go ahead and call "getBusinessListingsByKeyword" on our MapDataParser instance
	
	if(!locationManager)
	{
		locationManager = [[CLLocationManager alloc] init];
		locationManager.desiredAccuracy=kCLLocationAccuracyBest;
		locationManager.delegate = self;
        // Set a movement threshold for new events.
        locationManager.distanceFilter = 500;
        self.didUpdateLocationThreshold = 0;
        [locationManager startUpdatingLocation];
        
		
		// listen for map data parsing completion
		//[[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData:) name:@"mapDataParseComplete" object:nil];
	}
	else
	{
        [self.spinner hide:YES];
        [mapDataParser getBusinessListingsByKeyword:keyword atLat:currentLocation.coordinate.latitude atLng:currentLocation.coordinate.longitude forSearch:TRUE];
		
	}
	
	// save the keyword state
	searchKeyword = keyword;
}



- (void)timerCallback {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (locationManager.delegate) {
    
        locationManager.delegate = nil;
        [locationManager stopUpdatingLocation];
        
        if(!mapDataParser) {
            mapDataParser = [[MapDataParser alloc] init];
        }
        //NSLog(@"Latitude and Longtude %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        [mapDataParser getBusinessListingsByKeyword:searchKeyword atLat:currentLocation.coordinate.latitude atLng:currentLocation.coordinate.longitude forSearch:FALSE];
        mapDataParser.delegate = self;
        
    }
    [pool drain];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{	
    CLLocation *cloc = [newLocation copy];
    self.currentLocation = cloc;
    [cloc release]; cloc = nil;
    if (self.didUpdateLocationThreshold == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [self methodSignatureForSelector: @selector(timerCallback)]];
        [invocation setTarget:self];
        [invocation setSelector:@selector(timerCallback)];
        [NSTimer scheduledTimerWithTimeInterval:5 invocation:invocation repeats:NO];
    }
    
    // User location has been found/updated, load map data now.
    self.didUpdateLocationThreshold ++;
	NSDate* newLocTime = newLocation.timestamp;
 	NSTimeInterval howRecent = [newLocTime timeIntervalSinceNow];
    NSTimeInterval howLongRefresh = [self.refreshTime timeIntervalSinceNow];
    /*double currentLocAccuracy = 150;
    if (self.currentLocation) {
        currentLocAccuracy = self.currentLocation.horizontalAccuracy;
    }*/
 //   NSLog(@"newLocAccu:%f, howRecent: %d, howlongref: %d, didUpdateLocThresh: %d ",newLocation.horizontalAccuracy, abs(howRecent), abs(howLongRefresh), self.didUpdateLocationThreshold);
    if( (newLocation.horizontalAccuracy < 100 && abs(howRecent) < 15) || abs(howLongRefresh)>5 || self.didUpdateLocationThreshold > 4)
	{
        locationManager.delegate = nil;
        self.didUpdateLocationThreshold = 0;
		[locationManager stopUpdatingLocation];
		
		if(!mapDataParser) {
			mapDataParser = [[MapDataParser alloc] init];
		}
	
        [mapDataParser getBusinessListingsByKeyword:searchKeyword atLat:currentLocation.coordinate.latitude atLng:currentLocation.coordinate.longitude forSearch:FALSE];
	    mapDataParser.delegate = self;        
		
	}

}

- (void) loadSearchTableView
{
    [self.searchDisplayController.searchResultsTableView reloadData];

}

- (void) loadTableView:(BOOL)showMessage //v2p1 new argument BOOL
{
   	[self.tableView reloadData];
    [self doneLoadingTableViewData];
    [self.spinner hide:YES];
    if (self.currentLocation.horizontalAccuracy >= 150 && showMessage) { //v2p1 appended && showMessage
        [ErrorHandler displayInfoString:@"Unable to determine location accurately. Pull down to refresh or try search" forDelegate:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// Failed to find the user's location. This error occurs when the user declines the location request 
	// or has location services turned off.
	
	NSString * errorString = @"Unable to determine your location.\n Please check internet connection And\n Make sure location services are ON in iPhone Settings.";
    [ErrorHandler displayString:errorString forDelegate:nil];
	[locationManager stopUpdatingLocation];
    [self.spinner hide:YES];
    if (_reloading) {
        [self doneLoadingTableViewData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// There is only one section.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [mapDataParser.searchData count];
    }
	else
	{
		if ([mapDataParser.locationData count] == 0) {
            return 0;
        }
        else
        {
            return [mapDataParser.locationData count]+1;
        }
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		
		// Use the default cell style.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		
	}
	
	// Set up the cell.
    
	NSString *title;
	NSString *snippet;
    NSString *icon;
    /*v2 start */
    cell.imageView.image = nil;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    /*v2 end */
    
    if(indexPath.row == [mapDataParser.locationData count] && indexPath.row != 0){
        title = @"Touch here to Search";
        snippet = @"Did not find what you were looking for?";
        cell.textLabel.text = title;
        cell.detailTextLabel.text = snippet;
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
 
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        title = [[mapDataParser.searchData objectAtIndex:indexPath.row] locationTitle ];
		snippet = [[mapDataParser.searchData objectAtIndex:indexPath.row] locationSnippet ];
        icon = [self.iconMap objectForKey:[[mapDataParser.searchData objectAtIndex:indexPath.row] type ]];
    }
	else
	{   
		title = [[mapDataParser.locationData objectAtIndex:indexPath.row] locationTitle ];
		snippet = [[mapDataParser.locationData objectAtIndex:indexPath.row] locationSnippet ];
        icon = [self.iconMap objectForKey:[[mapDataParser.locationData objectAtIndex:indexPath.row] type ]];
	}
	
    if (icon == nil) {
        icon = @"misc";
    }
    //cell.contentView.backgroundColor = [UIColor yellowColor];
	cell.textLabel.text = title;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    //cell.textLabel.textColor = [UIColor colorWithRed:.3 green:0.13 blue:0 alpha:1];
	cell.textLabel.textColor = [UIColor colorWithRed:.1 green:0.4 blue:0.5 alpha:1];
	cell.textLabel.shadowColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.7];
    cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);
	cell.textLabel.backgroundColor = [UIColor clearColor];
	
	//float target = [currentLocation getDistanceFrom:[[mapDataParser.locationData objectAtIndex:indexPath.row] mapLocation ]];
	//cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance %f", target];
    cell.detailTextLabel.text = snippet;
   // cell.detailTextLabel.text = [self.iconMap objectForKey:[[mapDataParser.locationData objectAtIndex:indexPath.row] type ]];
	//cell.detailTextLabel.text = [[mapDataParser.locationData objectAtIndex:indexPath.row] category];
	cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.85];
    if (title != nil) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.imageView.image = [UIImage imageNamed:icon];
    [cell.imageView.layer setCornerRadius:10.0];
    cell.imageView.layer.masksToBounds = YES;
    [cell.imageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [cell.imageView.layer setBorderWidth: 1.0];
	return cell;
	
	
}

/*
 To conform to Human Interface Guildelines, since selecting a row would have no effect (such as navigation), make sure that rows cannot be selected.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
    if(indexPath.row == [mapDataParser.locationData count]){
        [self.searchBar becomeFirstResponder];
        return;
    }
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        ShowMap *showMap = [[ShowMap alloc] initWithNibName:@"ShowMap" bundle:nil location:[mapDataParser.searchData objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:showMap animated:YES];
        [showMap release];
    }
	else
	{
        ShowMap *showMap = [[ShowMap alloc] initWithNibName:@"ShowMap" bundle:nil location:[mapDataParser.locationData objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:showMap animated:YES];
        [showMap release];
	}
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	locationManager = nil;
    self.refreshTime = [NSDate date];
	[self findLocationsByKeyword:@"*"];
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (![self.searchDisplayController isActive]) {
		[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	}
    
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

- (void)dealloc {
    
	
	[locationManager release]; locationManager = nil;
	[mapDataParser release]; mapDataParser = nil;
	[currentLocation release]; currentLocation = nil;
	[searchKeyword release]; searchKeyword = nil;
    [spinner release]; spinner = nil;
    [searchBar release];
    [refreshHeaderView release]; refreshHeaderView = nil;
    [refreshTime release]; refreshTime = nil;
    [showCoverPage release]; showCoverPage = nil;
    [iconMap release]; iconMap = nil;
    [super dealloc];
}


@end
