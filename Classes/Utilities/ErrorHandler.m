//
//  ErrorHandler.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 10/28/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ErrorHandler.h"


@implementation ErrorHandler

+ (void) displayError:(NSError *)error  forDelegate:(id)del
{
    UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:@"!" message:[error localizedDescription] delegate:del cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [errorAlert setOpaque:NO];
    [errorAlert show];
}

+ (void) displayString:(NSString *)error  forDelegate:(id)del
{
    UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:@"!" message:NSLocalizedString(error, nil) delegate:del cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
     [errorAlert setOpaque:NO];
    [errorAlert show];
}

+ (void) displayString:(NSString *)error forDelegate:(id)del otherButton:(NSString*) otherButtonTitle
{
    UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:@"!" message:NSLocalizedString(error, nil) delegate:del cancelButtonTitle:@"OK" otherButtonTitles:otherButtonTitle,nil] autorelease];
    [errorAlert setOpaque:NO];
    [errorAlert show];
}

+ (void) displayInfoString:(NSString *)info forDelegate:(id)del
{
    UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil) message:NSLocalizedString(info, nil) delegate:del cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    
    [errorAlert setOpaque:NO];
    [errorAlert show];
}


@end
