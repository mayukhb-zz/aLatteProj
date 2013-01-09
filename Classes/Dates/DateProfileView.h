//
//  DateProfileView.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 7/11/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHTTPRequest.h"
#import "CachedProfileVO.h"
#import "EGORefreshTableHeaderView.h"
#import "IconDownloader.h"
#import "MBProgressHUD.h"

@protocol DateProfileViewDelegate 

- (void) queriedProfile: (CachedProfileVO*)cachedProfile withId:(NSNumber*) userId;

@end



@interface DateProfileView : UITableViewController <EGORefreshTableHeaderDelegate, IconDownloaderDelegate, CustomHTTPRequestDelegate>{
    
    CustomHTTPRequest *request;
    NSNumber *dateUserid;
    NSString *dateUserName;
    NSNumber *cachedUserId;
    NSArray *sectionTitle;
       
    CachedProfileVO *dateProfileVO;
    id<DateProfileViewDelegate> delegate;
    EGORefreshTableHeaderView *refreshHeaderView;
    
 	BOOL _reloading;
    IconDownloader *thumbnail;
    MBProgressHUD *spinner;
    

}

@property (nonatomic, retain) CustomHTTPRequest *request;
@property (nonatomic, retain) NSNumber* dateUserid;
@property (nonatomic, retain) NSString* dateUserName;
@property (nonatomic, retain) NSNumber* cachedUserId;

@property (nonatomic, retain) NSArray *sectionTitle;
@property (nonatomic, retain) CachedProfileVO *dateProfileVO;
@property (nonatomic, assign) id<DateProfileViewDelegate> delegate;

@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) IconDownloader *thumbnail;
@property (nonatomic, retain) MBProgressHUD *spinner;

- (void) queryProfile;
- (void) navigateToPhotos;
-(CGFloat) cellRowHeight:(NSString *)cellText;
-(CGFloat) cellRowHeight:(NSString *)cellText;
- (void) initiateChat;
- (void)doneLoadingTableViewData;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dateUserId:(NSNumber*)userId dateUserName: (NSString*)userName cachedUserId:(NSNumber*)cachedId dateProfile:(CachedProfileVO*)dateProfile delegate:(id<DateProfileViewDelegate>) del;
- (void)dateImageDidLoad:(NSIndexPath *)indexPath;
- (void)dateProfileDidDownload:(CachedProfileVO *)vo;

@end
