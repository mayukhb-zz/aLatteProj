//
//  MapDataParser.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/7/11.
//  Copyright 2011 Individual. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MapLocationVO.h"
#import "CustomHTTPRequest.h"

@protocol MapDataParserProtocol 

- (void) loadTableView:(BOOL)showMessage; //v2p1 new BOOL argument
- (void) loadSearchTableView;

@end

@interface MapDataParser : NSObject <NSXMLParserDelegate, CustomHTTPRequestDelegate>
{
	BOOL isPlacemark;
    BOOL isLocation; //v2p1
	
	NSXMLParser *mapsDataParser;
	NSMutableString *currentElementValue;
	NSMutableArray *locationData;
	NSMutableArray *searchData;
	MapLocationVO *currentMapLocation;
	NSMutableString	*currentElementName;
	CLLocation *referenceLocation;
    CustomHTTPRequest *request;
	//NSString *category;
	BOOL isSearch;
}

@property (nonatomic, readonly) NSMutableArray *locationData;
@property (nonatomic, readonly) NSMutableArray *searchData;
@property (nonatomic, retain) NSMutableString *currentElementName;
@property (nonatomic, retain) NSXMLParser *mapsDataParser;
@property (nonatomic, retain) MapLocationVO *currentMapLocation;
@property (nonatomic, retain) CustomHTTPRequest *request;
@property (nonatomic, assign) id <MapDataParserProtocol> delegate;

-(void) getBusinessListingsByKeyword:(NSString *)keyword atLat:(float)lat atLng:(float)lng forSearch:(BOOL)search;
-(void) parseXMLFileAtURL:(NSString *)URL;

@end
