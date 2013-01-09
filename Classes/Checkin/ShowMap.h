//
//  ShowMap.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/13/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "MapLocationVO.h"
#import "CustomHTTPRequest.h"
#import "ErrorHandler.h"

@interface ShowMap : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, CustomHTTPRequestDelegate>{
    
	IBOutlet MKMapView *mapView;
	NSMutableArray *currentAnnotations;
	IBOutlet UILabel *locTitle;
	IBOutlet UILabel *locSnippet;
	IBOutlet UIButton *checkIn;
    MapLocationVO *location;
    
    CustomHTTPRequest *request;
}


@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *currentAnnotations;
@property (nonatomic, retain) MapLocationVO *location;
@property (retain, nonatomic) CustomHTTPRequest *request;
@property (nonatomic, retain) UIButton *checkIn;

-(IBAction)checkInButtonClicked: (id) sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil location:(MapLocationVO*) loc;
- (void) checkin;
- (void) checkout;
@end
