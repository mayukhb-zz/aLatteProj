//
//  DatesTableView.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 6/30/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHTTPRequest.h"
#import "CachedProfileVO.h"
#import "DateProfileView.h"
#import "EGORefreshTableHeaderView.h"
#import "IconDownloader.h"
#import "MBProgressHUD.h"

@interface DatesTableView : UIViewController <DateProfileViewDelegate, EGORefreshTableHeaderDelegate, IconDownloaderDelegate, CustomHTTPRequestDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    double latitude;
    double longitude;
    NSNumber *userid;
    NSNumber *cachedUserId;
    NSString *locationTitle;
    NSMutableArray *dateArray;
    NSMutableArray *pathArray;
    NSMutableArray *placesArray;
    NSMutableArray *useridArray;
    NSString *lastCheckedinLocation;
    CustomHTTPRequest *request;
    
    CachedProfileVO *cachedProfileVO;
    MBProgressHUD *spinner;
    EGORefreshTableHeaderView *refreshHeaderView;
    
    UIImage *image;
    
    //  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
    BOOL isCheckedIn;
    BOOL isLoadingMoreDates; //v2 for the load more feature
    BOOL isMoreDatesAvailable; //v2 for the load more feature 
    UIActivityIndicatorView *loadMoreDatesView; //v2 for the load more feature
    UILabel *mainLabel; //v2
    UILabel *subtitleLabel; //v2
    UILabel *titleLabel; //v2
    
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each date
    IBOutlet UITableView *tableView;
    
}

@property (nonatomic, copy) NSString *locationTitle;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, retain) NSNumber *userid;
@property (nonatomic, retain) NSNumber *cachedUserId;
@property (retain, nonatomic) CustomHTTPRequest *request;
@property (nonatomic, retain) NSMutableArray *dateArray;
@property (nonatomic, retain) NSMutableArray *pathArray;
@property (nonatomic, retain) NSMutableArray *placesArray;
@property (nonatomic, retain) NSMutableArray *useridArray;
@property (nonatomic, copy) NSString *lastCheckedinLocation;

@property (nonatomic, retain) CachedProfileVO *cachedProfileVO;
@property (nonatomic, retain) MBProgressHUD *spinner;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) BOOL isCheckedIn;
@property (nonatomic, assign) BOOL isLoadingMoreDates; //v2 for the load more feature
@property (nonatomic, assign) BOOL isMoreDatesAvailable; //v2 for the load more feature
@property (nonatomic, retain) UIActivityIndicatorView *loadMoreDatesView; //v2 for the load more feature
@property (nonatomic, retain) UILabel *mainLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) IBOutlet UITableView *tableView;


- (void)dateImageDidLoad:(NSIndexPath *)indexPath;
- (void)findNearbyDates;
- (void)doneLoadingTableViewData;
- (void)loadImagesForOnscreenRows;
- (void)didClickTutorial;

@end
