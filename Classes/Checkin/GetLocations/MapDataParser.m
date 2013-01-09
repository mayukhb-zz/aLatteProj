//
//  MapDataParser.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//


#import "MapDataParser.h"
#import "MapLocationVO.h"
#import "ErrorHandler.h"
#import "Constants.h"

@implementation MapDataParser 

@synthesize locationData, searchData, currentElementName, mapsDataParser, currentMapLocation;
@synthesize request;
@synthesize delegate;

-(void) getBusinessListingsByKeyword:(NSString *)keyword atLat:(float)lat atLng:(float)lng forSearch:(BOOL)search
{
	// Construct our maps call.
	referenceLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
	//self.category = keyword;
	isSearch = search;
	if (isSearch) {
        //v2p1
		//[self parseXMLFileAtURL:[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&mrt=yp&num=10&sll=%g,%g&radius=5&output=kml", [keyword stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], lat, lng]];
        [self parseXMLFileAtURL:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/xml?name=%@&location=%g,%g&radius=40000&sensor=true&key=AIzaSyCwtUuzxQFYCGht1NmcAbZyWJ8qlqMrIag", [keyword stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], lat, lng]]; //v2p1 #v2.1
        
	}
	else {
		//[self parseXMLFileAtURL:[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&mrt=yp&num=20&sll=%g,%g&output=kml", [keyword stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], lat, lng]];
		[self parseXMLFileAtURL:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/xml?location=%g,%g&radius=500&sensor=true&key=AIzaSyCwtUuzxQFYCGht1NmcAbZyWJ8qlqMrIag", lat, lng]]; //v2p1 
	}
    
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
	// parse file at url
	
	//NSURL *xmlURL = [NSURL URLWithString:URL];
    [self.request clearDelegatesAndCancel]; 
    self.request = nil;
    self.request = [[[CustomHTTPRequest alloc] initWithXMLPath:URL] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
    [self.request setCustomHTTPDelegate:self];
    self.request.tag = REQUEST_FOR_NEARBY_LOCATIONS;
    [self.request setPostValues:params];
    
    
   
}

- (void) doneFindingNearbyLocations:(NSData *)xmlData
{

    NSXMLParser *tempParser = [[NSXMLParser alloc] initWithData:xmlData];
    self.mapsDataParser = tempParser;
    [tempParser release]; tempParser = nil;
    
	self.mapsDataParser.delegate = self;
	[self.mapsDataParser setShouldProcessNamespaces:NO];
	[self.mapsDataParser setShouldReportNamespacePrefixes:NO];
	[self.mapsDataParser setShouldResolveExternalEntities:NO];
	
	[self.mapsDataParser parse];
}
- (void) failedFindingNearbyLocations
{
    if (isSearch) {
        [self.delegate loadSearchTableView];
    }
    else
    {
        [self.delegate loadTableView:YES]; //v2p1 new boolean argument
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Parser has started so create locationData array to store MapLocation value objects
	if (isSearch) {
		if(self.searchData) 
		{
			[self.searchData removeAllObjects];
		}
		else {
			searchData = [[NSMutableArray alloc] init];
		}
		
	}
	else {
		if (self.locationData) {
			[self.locationData removeAllObjects];
		}
		else
		{
			locationData = [[NSMutableArray alloc] init];
            
		}
	}
    
    //Also allocate currentelement to store any element in xml other than placemark
    currentElementName = [[NSMutableString alloc] initWithCapacity:10];
	
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	// Unable to reach the service, show error alert
	NSLog(@"%@", parseError);
	NSString * errorString = [NSString stringWithFormat:@"Unable to find nearby places. Please check internet connection."];
    [ErrorHandler displayString:errorString forDelegate:self];
    //v2p1
    if (isSearch) {
        [self.delegate loadSearchTableView];
    }
    else
    {
        [self.delegate loadTableView:NO];
    }
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"result"]) //v2p1
    {
		// Placemark item found, prepare to save data to new MapLocationVO
		MapLocationVO *tempMapLocationVO = [[MapLocationVO alloc] init];
        self.currentMapLocation = tempMapLocationVO;
        [tempMapLocationVO release]; tempMapLocationVO = nil;
		isPlacemark = YES;
    }
    //v2p1
    else if([elementName isEqualToString:@"location"])
    {
        isLocation = YES;
    }
	else
	{
		// Element other than Placemark found, store it for "foundCharacters" check		
		[self.currentElementName setString:elementName];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"result"])  //v2p1
	{
		// Placemark element ended, store data
		
		isPlacemark = NO;
      	if (isSearch) {
			[self.searchData addObject: self.currentMapLocation];
		}
		else {
			[self.locationData addObject: self.currentMapLocation];
		}
        
		//[currentMapLocation release];
		//currentMapLocation = nil;
	}
    //v2p1
    else if([elementName isEqualToString:@"location"])
    {
        isLocation = NO;
    }
} 

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(isPlacemark)
	{		
		// If we are currently in a Placemark element, 
		// check if current is something we want to store
		
		if ([self.currentElementName isEqualToString:@"name"])
		{
			if(!self.currentMapLocation.locationTitle)
			{
                NSMutableString *str = [[NSMutableString alloc] initWithString:string];
                self.currentMapLocation.locationTitle = str;
                [str release]; str = nil;
				//currentMapLocation.locationTitle =[[[NSMutableString alloc] initWithString:string] autorelease];
			}
			else
			{
				[self.currentMapLocation.locationTitle appendString: string];
			}
		}
        /*v2 start*/
        if ([self.currentElementName isEqualToString:@"type"])
		{
			if(!self.currentMapLocation.type)
			{
                NSMutableString *str = [[NSMutableString alloc] initWithString:string];
                self.currentMapLocation.type = str;
                [str release]; str = nil;
				//currentMapLocation.locationTitle =[[[NSMutableString alloc] initWithString:string] autorelease];
			}
		}
        /* v2 end*/
		else if ([self.currentElementName isEqualToString:@"vicinity"]) //v2p1
		{
			// Replace line breaks with new line
			if(!self.currentMapLocation.locationSnippet)
			{
                NSMutableString *str = [[NSMutableString alloc] initWithString:string];
                self.currentMapLocation.locationSnippet = str;
                [str release]; str = nil;
				//currentMapLocation.locationTitle =[[[NSMutableString alloc] initWithString:string] autorelease];
			}
			else
			{
				[self.currentMapLocation.locationSnippet appendString: string];
			}
            
		}
		else if ([self.currentElementName isEqualToString:@"lat"] && isLocation) //v2p1
		{		
			// Create a coordinate array to use when allocating CLLocation.
			// We will use the CLLocation object later when populating the map
			//NSArray *coordinatesList = [string componentsSeparatedByString:@"</lat><lng>"];
            if ([string floatValue] != 0.0) {
                CLLocation *clLoc = [[CLLocation alloc] initWithLatitude:[string floatValue] longitude:[string floatValue]];
                self.currentMapLocation.mapLocation = clLoc;
                [clLoc release]; clLoc = nil;
            }
            
		}
        //v2p1
        else if ([self.currentElementName isEqualToString:@"lng"] && isLocation)
        {
            // Create a coordinate array to use when allocating CLLocation.
			// We will use the CLLocation object later when populating the map
            if([string floatValue] != 0.0){
			CLLocation *clLoc = [[CLLocation alloc] initWithLatitude:self.currentMapLocation.mapLocation.coordinate.latitude longitude:[string floatValue]];
			self.currentMapLocation.mapLocation = clLoc;
            [clLoc release]; clLoc = nil;
        	float distance = [referenceLocation distanceFromLocation:self.currentMapLocation.mapLocation];
			self.currentMapLocation.distance = distance;
            }
        }
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{		
	// XML document is completely parsed, dispatch an event for app to handle data as needed
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mapDataParseComplete" object:nil];
    self.mapsDataParser.delegate = nil;
	//[mapsDataParser release]; mapsDataParser = nil;
    [referenceLocation release]; referenceLocation = nil;
    [currentElementName release]; currentElementName = nil;
    
    if (isSearch) {
        [self.delegate loadSearchTableView];
    }
    else
    {
        [self.delegate loadTableView:YES];//v2p1 additional argument
    }
    
}

- (void)dealloc
{
	//mapsDataParser.delegate = nil;
	[mapsDataParser release]; mapsDataParser = nil;
	[currentMapLocation release]; currentMapLocation = nil;
	[locationData release]; locationData = nil;
	[searchData release]; searchData = nil;
    
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel];
    [request release]; request = nil;
    
    [super dealloc];
}

@end
