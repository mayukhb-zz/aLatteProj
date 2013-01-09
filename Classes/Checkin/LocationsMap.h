//
//  LocationsMap.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "MapDataParser.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@interface LocationsMap: UITableViewController <CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, EGORefreshTableHeaderDelegate, MapDataParserProtocol>
{
	CLLocationManager *locationManager;
	MapDataParser *mapDataParser;
	CLLocation *currentLocation;
	NSString *searchKeyword;
    IBOutlet UISearchBar *searchBar;
 	EGORefreshTableHeaderView *refreshHeaderView;

	BOOL _reloading;
    NSDate *refreshTime;
    NSNumber *showCoverPage;
    int didUpdateLocationThreshold;
    MBProgressHUD *spinner;
    
    NSDictionary *iconMap; //v2
}


@property (nonatomic, retain) MapDataParser *mapDataParser;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSString *searchKeyword;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar; 
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) MBProgressHUD *spinner;
@property (nonatomic, retain) NSDate *refreshTime;
@property (nonatomic, retain) NSNumber *showCoverPage;
@property (nonatomic, assign) int didUpdateLocationThreshold;
@property (nonatomic, retain) NSDictionary *iconMap; //v2

-(void) findLocationsByKeyword:(NSString *)searchKeyword;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
