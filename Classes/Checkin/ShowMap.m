//
//  ShowMap.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/13/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ShowMap.h"
#import "BLAnnotation.h"
#import "BLPinAnnotation.h"
#import "Common.h"
#import "Constants.h"


@implementation ShowMap
@synthesize mapView, currentAnnotations, location, request;
@synthesize checkIn;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil location:(MapLocationVO*) loc {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        self.location = loc;
        mapView.delegate = self;
        
     	// array to store annotations added to the map
		currentAnnotations = [[NSMutableArray alloc] init];
		
		// respond to an annotation being selected by centering the map to it's coordinates
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centerMapToAnnotation:) name:@"annotationSelected" object:nil];
        
		
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    [self.checkIn setTitle:@"Check In/Out" forState:UIControlStateNormal];
   
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.mapLocation.coordinate,500, 500);
    
	[mapView setRegion:region animated:YES];
	[mapView regionThatFits:region];
	locTitle.text = self.location.locationTitle;
	locSnippet.text = self.location.locationSnippet;
	
    // Create annotations for the returned google maps data.
    
    BLAnnotation *businessListingAnnotation = [[BLAnnotation alloc] initWithCoordinate: self.location.mapLocation.coordinate title:self.location.locationTitle subtitle:self.location.locationSnippet];
    [mapView addAnnotation: businessListingAnnotation];
    
    [businessListingAnnotation release];
    businessListingAnnotation = nil;
}


-(void) centerMapToAnnotation:(NSNotification *)note
{
	// Type dispatching annotation object
	BLPinAnnotation *annotation = (BLPinAnnotation *)[note object];
	
	// animate the map to the pin's coordinates
	[mapView setCenterCoordinate:annotation.annotation.coordinate animated: YES];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
	// Specify which MKPinAnnotationView to use for each annotation. 
	
	if (annotation != self.mapView.userLocation)
	{
		// Use custom annotation view for anything but the user's locaiton pin
		
		BLPinAnnotation *blAnnotationView = (BLPinAnnotation *)[self.mapView dequeueReusableAnnotationViewWithIdentifier: @"BLPin" ];
		
		if (blAnnotationView == nil)
		{
			blAnnotationView = [[[BLPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:@"BLPin"] autorelease] ;
		}
		else
		{
			blAnnotationView.annotation = annotation;
			blAnnotationView.titleLabel.text = annotation.title;
			blAnnotationView.subtitleLabel.text = annotation.subtitle;
		}
		
		return blAnnotationView;
	}
	else
	{
		// Use a native MKAnnoationView for the user's location
		
		MKPinAnnotationView *businessListingPin = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier: @"BLUserPin" ];
		
		if (businessListingPin == nil) businessListingPin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BLUserPin"] autorelease];
		
		businessListingPin.canShowCallout = NO;
		businessListingPin.pinColor = MKPinAnnotationColorRed;
		
		return businessListingPin;
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		[self checkin];
    }
    else {
        [self checkout];
    }
	
}

-(IBAction)checkInButtonClicked:(id) sender {
	
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Check In", @"Check Out", nil];
    
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	
	[actionSheet showInView:self.parentViewController.tabBarController.view];
	[actionSheet release];

}

- (void) checkin
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.request clearDelegatesAndCancel];
    self.request = nil;
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:self.location.locationTitle forKey:@"place"];
    [params setValue:[NSNumber numberWithDouble:self.location.mapLocation.coordinate.latitude] forKey:@"lat"];
    [params setValue:[NSNumber numberWithDouble:self.location.mapLocation.coordinate.longitude] forKey:@"long"];
    [params setValue:[NSNumber numberWithInteger:[prefs integerForKey:@"userId"]] forKey:@"userid"];
    [params setValue:[prefs objectForKey:@"userName"] forKey:@"username"];
    [params setValue:[prefs objectForKey:@"userSex"] forKey:@"usersex"];
    [params setValue:[prefs objectForKey:@"userThumbnail"] forKey:@"thumbnail"];
    [params setValue:@"checkin" forKey:@"mode"];
    [params setValue:@"checkin" forKey:@"script"];
    
    self.request.tag = REQUEST_FOR_CHECK_IN;
    self.request.customHTTPDelegate = self;
    [self.request setPostValues:params];
}

- (void) checkout
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.request clearDelegatesAndCancel];
    self.request = nil;
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInteger:[prefs integerForKey:@"userId"]] forKey:@"userid"];
    [params setValue:@"checkout" forKey:@"mode"];
    [params setValue:@"checkin" forKey:@"script"];
    
    self.request.tag = REQUEST_FOR_CHECK_OUT;
    self.request.customHTTPDelegate = self;
    
    [self.request setPostValues:params];
}


#pragma mark -
#pragma mark load name, thumbnail usign coredata Methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.mapView = nil;
    self.checkIn = nil;
    
}

- (void) doneCheckingIn
{
    [ErrorHandler displayInfoString:@"You are now checked into the current location." forDelegate:nil];
    /*v2 start */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:self.location.locationTitle forKey:@"currentLocation"];
    [prefs setBool:YES forKey:@"nearmeNeedsRefresh"];
    [prefs synchronize];
    /*v2 end */
}

- (void) doneCheckingOut
{
    [ErrorHandler displayInfoString:@"You are now checked out." forDelegate:nil];
    /*v2 start */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:@"" forKey:@"currentLocation"];
    [prefs setBool:YES forKey:@"nearmeNeedsRefresh"];
    [prefs synchronize];
    /*v2 end */
}

- (void)dealloc {
    
	[mapView release]; mapView = nil;
	[currentAnnotations release]; currentAnnotations = nil;
    [location release]; location = nil;
    
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel];
    [request release]; request = nil;
    [super dealloc];
    
}


@end
