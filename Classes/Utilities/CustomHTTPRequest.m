//
//  CustomHTTPRequest.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 12/26/11.
//  Copyright (c) 2011 Individual. All rights reserved.
//

#import "CustomHTTPRequest.h"
#import "CachedProfileVO.h"
#import "ErrorHandler.h"
#import "Constants.h"

@implementation CustomHTTPRequest

@synthesize customHTTPDelegate;


+ (NSURL *)apiURLWithPath:(NSString *)path {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://alatteapp.com/",path]];    
}

- (id)initWithPath:(NSString *)path presentDialog:(BOOL)dialog{
    if (self = [super initWithURL:[CustomHTTPRequest apiURLWithPath:path]]) {
        self.shouldPresentAuthenticationDialog = dialog;
        self.useKeychainPersistence = YES;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        [self setShouldContinueWhenAppEntersBackground:YES];
#endif

        [self setDidFailSelector:@selector(downloadFailed:)];
        [self setDidFinishSelector:@selector(downloadFinished:)];
        self.shouldUseRFC2616RedirectBehaviour = YES;
        [self setTimeOutSeconds:20];
        self.delegate = self;
        
    }
 
    return self;
}

- (id)initWithXMLPath:(NSString *)path{
    if (self = [super initWithURL:[NSURL URLWithString:path]]) {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        [self setShouldContinueWhenAppEntersBackground:YES];
#endif
        
        [self setDidFailSelector:@selector(downloadFailed:)];
        [self setDidFinishSelector:@selector(downloadFinished:)];
        self.shouldUseRFC2616RedirectBehaviour = YES;
        [self setTimeOutSeconds:20];
        self.delegate = self;
        
    }
    
    return self;
}

- (void) addDataForImageContent:(NSData*) imgData withKey:(NSString*) key
{
    [self addData:imgData withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:key];
}

- (void) setPostValues:(NSMutableDictionary*) dict
{
    for(id key in dict)
    {
        [self setPostValue:[dict objectForKey:key] forKey:key];
    }
    [self startAsynchronous];
}

+ (NSString *)username {
    NSURL *url = [self apiURLWithPath:@""];
    NSURLCredential *authenticationCredentials = [self savedCredentialsForHost:[url host] 
                                                                          port:[[url port] intValue] 
                                                                      protocol:[url scheme] 
                                                                         realm:SERVERREALM];
    if (authenticationCredentials)
        return [authenticationCredentials user];
    else
        return nil;
}

+ (NSString *)passwd { //FIXME secure/encode the passwd string?
    NSURL *url = [self apiURLWithPath:@""];
    NSURLCredential *authenticationCredentials = [self savedCredentialsForHost:[url host] 
                                                                          port:[[url port] intValue] 
                                                                      protocol:[url scheme] 
                                                                         realm:SERVERREALM];
    if (authenticationCredentials)
        return [authenticationCredentials password];
    else
        return nil;
}

+ (BOOL)loggedIn {
    return ([self username] != nil);
}

+ (void)storeUsername:(NSString *)u password:(NSString *)p {
    NSURL *url = [self apiURLWithPath:@""];
    NSURLCredential *credentials = [NSURLCredential credentialWithUser:u password:p persistence:NSURLCredentialPersistencePermanent];
    [self saveCredentials:credentials forHost:[url host] port:[[url port] intValue] protocol:[url scheme] realm:SERVERREALM];
}

+ (void)logout {
    // clear saved credentials
    [self clearSession];
    
    // remove all credentials
    NSURL *url = [self apiURLWithPath:@""];
    NSURLProtectionSpace *protectionSpace = [[[NSURLProtectionSpace alloc] initWithHost:[url host] 
                                                                                   port:[[url port] intValue] 
                                                                               protocol:[url scheme] 
                                                                                  realm:SERVERREALM 
                                                                   authenticationMethod:NSURLAuthenticationMethodDefault] autorelease];
    NSURLCredential *credential;
    while ((credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace])) {
        [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:protectionSpace];
    }
}

- (void)downloadFailed:(ASIHTTPRequest *)theRequest
{
    
    if (self.tag == REQUEST_FOR_SEND_CHAT_MESSAGE)
    {
        [self.customHTTPDelegate sendMessageFailed:@"fail"];
    }
    else if (self.tag != REQUEST_FOR_POLLING && self.tag != REQUEST_FOR_DEVICE_TOKEN_REGISTRATION)
    {
        NSLog(@"%@, error: %@", [theRequest responseString], [theRequest error]);
        [ErrorHandler displayString:@"Unable to perform action. Please check internet connection." forDelegate:nil];
    }
    
    if (self.tag == REQUEST_FOR_NEARBY_DATES || self.tag == REQUEST_FOR_DATE_PROFILE )
    {   
        [self.customHTTPDelegate doneLoadingTableViewData];     
    }
    else if (self.tag == REQUEST_FOR_NEARBY_LOCATIONS)
    {
        [self.customHTTPDelegate failedFindingNearbyLocations];
    }
    else if (self.tag == REQUEST_FOR_POLLING)
    {
        [self.customHTTPDelegate resetTimer:YES];
    }
    if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
    {
        [self.customHTTPDelegate stopSpinner];   
    }
    self.customHTTPDelegate = nil;
}

- (void)downloadFinished:(ASIHTTPRequest *)theRequest
{
    //If the response code is anythong other than 200 throw error and return.
    //NSLog(@"Response: %@", [theRequest responseString]);
    //NSLog(@"%@", [theRequest responseHeaders]);
    //NSLog(@"Lets see if this works: %@", [[theRequest responseHeaders] valueForKey:@"X-Alatte"]);
    //NSLog(@"Lets see if this works: %@", [[theRequest responseHeaders] valueForKey:@"x-alatte"]);
    //NSLog(@"Lets see if this works: %@", [[theRequest responseHeaders] valueForKey:@"x-aLatte"]);
    //NSLog(@"Lets see if this works: %@", [[theRequest responseHeaders] valueForKey:@"X-aLatte"]);

    if ([theRequest responseStatusCode] == 401) {
        if (self.tag == REQUEST_FOR_SEND_CHAT_MESSAGE)
        {
            [self.customHTTPDelegate sendMessageFailed:@"not authenticated"];
        }
        else if (self.tag != REQUEST_FOR_POLLING && self.tag != REQUEST_FOR_DEVICE_TOKEN_REGISTRATION)
        {
            [ErrorHandler displayString:@"Invalid login. Verify email/password." forDelegate:nil];
        }
        if (self.tag == REQUEST_FOR_NEARBY_DATES || self.tag == REQUEST_FOR_DATE_PROFILE)
        {   
            [self.customHTTPDelegate doneLoadingTableViewData];     
        }
        else if (self.tag == REQUEST_FOR_POLLING)
        {
            [self.customHTTPDelegate resetTimer:YES];
        }
        /*else if(self.tag == REQUEST_FOR_NEW_USER || self.tag == REQUEST_FOR_CURRENT_USER || self.tag == REQUEST_FOR_RESET_PASSWD){
            [self.customHTTPDelegate stopSpinner];
        }*/
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        self.customHTTPDelegate = nil;
        return;
    }
    if ([theRequest responseStatusCode] != 200) {
        if (self.tag == REQUEST_FOR_SEND_CHAT_MESSAGE)
        {
            [self.customHTTPDelegate sendMessageFailed:@"not ok"];
        }
        else if (self.tag != REQUEST_FOR_POLLING && self.tag != REQUEST_FOR_DEVICE_TOKEN_REGISTRATION)
        {
            [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
        }
        if (self.tag == REQUEST_FOR_NEARBY_DATES || self.tag == REQUEST_FOR_DATE_PROFILE)
        {   
            [self.customHTTPDelegate doneLoadingTableViewData];     
        }
        else if (self.tag == REQUEST_FOR_POLLING)
        {
            [self.customHTTPDelegate resetTimer:YES];
        }
        /*else if(self.tag == REQUEST_FOR_NEW_USER || self.tag == REQUEST_FOR_CURRENT_USER || self.tag == REQUEST_FOR_RESET_PASSWD){
            [self.customHTTPDelegate stopSpinner];
        }*/
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        self.customHTTPDelegate = nil;
        return;
    }
    //Even if response code is 200, we are not sure whether data is safe. Check the header response for aLatte:success key value pair
    // Leave nearby locations out
    if(![[[theRequest responseHeaders] valueForKey:@"X-Alatte"] isEqualToString:@"success"] && self.tag != REQUEST_FOR_NEARBY_LOCATIONS)
    {
        if (self.tag == REQUEST_FOR_SEND_CHAT_MESSAGE)
        {
            [self.customHTTPDelegate sendMessageFailed:@"fail"];
        }
        else if (self.tag != REQUEST_FOR_POLLING && self.tag != REQUEST_FOR_DEVICE_TOKEN_REGISTRATION)
        {
            [ErrorHandler displayString:@"Unable to perform action. Please check internet connection." forDelegate:nil];
        }
        
        if (self.tag == REQUEST_FOR_NEARBY_DATES || self.tag == REQUEST_FOR_DATE_PROFILE )
        {   
            [self.customHTTPDelegate doneLoadingTableViewData];     
        }
        else if (self.tag == REQUEST_FOR_NEARBY_LOCATIONS)
        {
            [self.customHTTPDelegate failedFindingNearbyLocations];
        }
        else if (self.tag == REQUEST_FOR_POLLING)
        {
            [self.customHTTPDelegate resetTimer:YES];
        }
        /*else if(self.tag == REQUEST_FOR_NEW_USER || self.tag == REQUEST_FOR_CURRENT_USER || self.tag == REQUEST_FOR_RESET_PASSWD){
            [self.customHTTPDelegate stopSpinner];
        }*/
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        self.customHTTPDelegate = nil;
        return;
    }
    
    if (self.tag == REQUEST_FOR_DATE_PROFILE) {
        [self handleDateProfileDidDownload:theRequest];
    }
    else if (self.tag == REQUEST_FOR_NEARBY_DATES)
    {
        [self handleNearbyDatesDidFound:theRequest];
    }
    else if(self.tag == REQUEST_FOR_SEND_CHAT_MESSAGE)
    {
        [self handleSendMessage];
    }
    else if(self.tag == REQUEST_FOR_REVELATION)
    {
        [self handleRevelation];
    }
    else if(self.tag == REQUEST_FOR_ADD_PHOTO)
    {
        [self handlePhotoUpload:theRequest];
    }
    /*v2 start */
    else if(self.tag == REQUEST_FOR_ADD_PHOTO_THUMBNAIL)
    {
        [self handlePhotoAndProfilePicUpload:theRequest];
    }
    /*v2 end */
    else if(self.tag == REQUEST_FOR_PROFILE_PIC_LABEL)
    {
        [self handleProfilePicUpload:theRequest];
    }
    else if (self.tag == REQUEST_FOR_DELETE_PHOTO)
    {
        [self handlePhotoDelete:theRequest];
    }
    else if(self.tag  == REQUEST_FOR_PROFILE_EDIT)
    {
        [self handleProfileUpload];
    }
    else if (self.tag == REQUEST_FOR_NEW_USER)
    {
        [self handleNewUserRegistration:theRequest];
    }
    else if (self.tag == REQUEST_FOR_CURRENT_USER)
    {
        [self handleCurrentUserLogin: theRequest];
    }
    else if (self.tag == REQUEST_FOR_CHECK_IN)
    {
        [self handleCheckIn];
    }
    else if (self.tag == REQUEST_FOR_CHECK_OUT)
    {
        [self handleCheckOut];
    }
    else if (self.tag == REQUEST_FOR_NEARBY_LOCATIONS)
    {
        [self handleNearbyLocations: theRequest];
    }
    else if (self.tag == REQUEST_FOR_POLLING)
    {
        [self handlePollingComplete:theRequest];
    }
    else if (self.tag == REQUEST_FOR_SETTING_CHANGE){
        [self handleSettingChange];
    }
    else if (self.tag == REQUEST_FOR_RESET_PASSWD){
        [self handlePasswordReset: theRequest]; 
    }
    else if (self.tag == REQUEST_FOR_DEVICE_TOKEN_REGISTRATION)
    {
        [self handleRegistrationDeviceToken];
    }
    self.customHTTPDelegate = nil;
}

- (void) handleDateProfileDidDownload: (ASIHTTPRequest*) theRequest
{
    NSMutableString *str = [[NSMutableString alloc] init];
    [str setString:[theRequest responseString]];
    [self preprocess:str];
    
    
    if ([str isEqualToString:@"NO DATA"]) {
        [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
        [str release]; str = nil;
        self.customHTTPDelegate = nil;
        return;

    } 
    else { 
  
        //Preprocess string delete ends '[' and ']' as necessary
        if (![self deleteEnds:str]) {
            [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
            [str release]; str = nil;
            return;
        }
        
 
        NSArray *tempArray = [str componentsSeparatedByString:@"]["];
        NSString *tempStr = (NSString*)[tempArray objectAtIndex:0];
        NSArray *bioArray = [tempStr componentsSeparatedByString:@","]; 
        
        CachedProfileVO *vo = [[[CachedProfileVO alloc] init] autorelease];
        
        vo.name = (NSString*)[bioArray objectAtIndex:0];
        vo.face = (NSString*)[bioArray objectAtIndex:1];
        
        vo.schools = (NSString*)[tempArray objectAtIndex:1];
        vo.works = (NSString*)[tempArray objectAtIndex:2];
        vo.musics = (NSString*)[tempArray objectAtIndex:3] ;
        vo.movies = (NSString*)[tempArray objectAtIndex:4] ;
        vo.books = (NSString*)[tempArray objectAtIndex:5] ;
        vo.hobbies = (NSString*)[tempArray objectAtIndex:6] ;
        vo.tvshows = (NSString*)[tempArray objectAtIndex:7] ;
        
        NSArray *photoArray = [[tempArray objectAtIndex:8] componentsSeparatedByString:@","]; 
        vo.photos = photoArray;
        [str release]; str = nil;
        
        [self.customHTTPDelegate dateProfileDidDownload:vo];
        
    }

}

- (void) handleNearbyDatesDidFound:(ASIHTTPRequest*) theRequest
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:20];
    [str setString: [theRequest responseString]];
    [self preprocess:str];
    
    BOOL isCheckedIn = YES;
    if ([str isEqualToString:@"NO DATA"]) {
        isCheckedIn = YES;
        [self.customHTTPDelegate nearbyDatesDidFound:isCheckedIn userIdArray:nil dateArray:nil placesArray:nil pathArray:nil];
    }
    else if([str isEqualToString:@"NOT CHECKED IN"]){
        isCheckedIn = NO;
        [self.customHTTPDelegate nearbyDatesDidFound:isCheckedIn userIdArray:nil dateArray:nil placesArray:nil pathArray:nil];
    }
    else {
         
       
        //Preprocess string to remove ",/,new line. Also delete ends '[' and ']' as necessary
        if (![self deleteEnds:str]) {
            [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
            [str release]; str = nil;
            return;
        }
        
        NSArray *tempArray = [str componentsSeparatedByString:@"]["];
        NSArray *userIdArray = [[tempArray objectAtIndex:0] componentsSeparatedByString:@","];
        NSArray *dateArray = [[tempArray objectAtIndex:1] componentsSeparatedByString:@","];
        NSArray *placesArray = [[tempArray objectAtIndex:2] componentsSeparatedByString:@","];
        NSArray *pathArray = [[tempArray objectAtIndex:3] componentsSeparatedByString:@","];
        
        [self.customHTTPDelegate nearbyDatesDidFound:isCheckedIn userIdArray:userIdArray dateArray:dateArray placesArray:placesArray pathArray:pathArray];
    }
    [str release]; str = nil;
}

- (void)handleSendMessage
{
    [self.customHTTPDelegate sendMessageDidComplete];
}

- (void) handleRevelation
{
    [self.customHTTPDelegate revealFinished];
}

- (void) handlePhotoUpload:(ASIHTTPRequest*) theRequest
{
    NSMutableString *str = [[[NSMutableString alloc] init] autorelease];
    [str setString:[theRequest responseString]];
    
    //Preprocess string to remove ",/,new line. Also delete ends '[' and ']' as necessary
    [self preprocess:str];
    /*if (![self deleteEnds:str]) {
        [ErrorHandler displayString:@"Unable to upload photo. Please try again later." forDelegate:nil];
        return;
    }*/
    
    NSRange range = [str rangeOfString:@".jpg"];
    if (range.length != [@".jpg" length]) {
        [ErrorHandler displayString:@"Unable to upload photo. Please try again later." forDelegate:nil];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        return;
    }
    int photoidLoc = range.location + range.length;
    
    if ([str length] <= photoidLoc) {
        [ErrorHandler displayString:@"Unable to upload photo. Please try again later." forDelegate:nil];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        return;
    }
    //Extract the photo id using numberformatter
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *photoId = [f numberFromString:[str substringFromIndex:photoidLoc]];
    [f release];
    
    if (photoId == nil) {
        [ErrorHandler displayString:@"Unable to upload photo. Please try again later." forDelegate:self];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        return;
    }
    
    //Now remove the photoid from the string to get the url of the uploaded pic
    range.location = photoidLoc;
    range.length = [str length] - range.location;
    [str deleteCharactersInRange:range];
    
    [self.customHTTPDelegate photoUploadFinished:photoId path:str];
      
}

- (void) handleProfilePicUpload:(ASIHTTPRequest *)theRequest
{
    NSMutableString *str = [[NSMutableString alloc] init] ;
    
    [str setString:[theRequest responseString]];
    //Preprocess string to remove ",/,new line. 
    [self preprocess:str];
    
    if ([str isEqualToString:@"Success"]) {
        
        [self.customHTTPDelegate profilePicUploaded];
    }
    else
    {
        [ErrorHandler displayString:@"Unable to perform action. Please try again later." forDelegate:nil];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        
    }
    [str release]; str = nil;

}
/*v2 start */
- (void) handlePhotoAndProfilePicUpload:(ASIHTTPRequest *)theRequest
{
    NSMutableString *str = [[[NSMutableString alloc] init] autorelease];
    [str setString:[theRequest responseString]];
    
    //Preprocess string to remove ",/,new line. Also delete ends '[' and ']' as necessary
    [self preprocess:str];
    
    NSRange range = [str rangeOfString:@".jpg"];
    if (range.length != [@".jpg" length]) {
/*        [ErrorHandler displayString:@"Unable to upload photo. Please try again later." forDelegate:nil];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
 */
        return;
    }
    int photoidLoc = range.location + range.length;
    
    if ([str length] <= photoidLoc) {
      /*  [ErrorHandler displayString:@"Unable to upload photo. Please try again later." forDelegate:nil];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }*/
        return;
    }
    //Extract the photo id using numberformatter
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *photoId = [f numberFromString:[str substringFromIndex:photoidLoc]];
    [f release];
    
    if (photoId == nil) {
        /*[ErrorHandler displayString:@"Unable to upload photo. Please try again later." forDelegate:self];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }*/
        return;
    }
    
    //Now remove the photoid from the string to get the url of the uploaded pic
    range.location = photoidLoc;
    range.length = [str length] - range.location;
    [str deleteCharactersInRange:range];
    
    [self.customHTTPDelegate photoUploadFinished:photoId path:str];
    
}
/*v2 end */

- (void) handlePhotoDelete:(ASIHTTPRequest *)theRequest
{
    NSMutableString *str = [[NSMutableString alloc] init];
    [str setString:[theRequest responseString]];
    
    //Preprocess string to remove ",/,new line.
    [self preprocess:str];
   
    if ([str isEqualToString:@"Success"]) {
        [self.customHTTPDelegate photoDeleteFinished];
        
    }
    else
    {
        [ErrorHandler displayString:@"Unable to delete photo. Please try again later." forDelegate:self];
        if([self.customHTTPDelegate respondsToSelector:@selector(stopSpinner)])
        {
            [self.customHTTPDelegate stopSpinner];   
        }
        
    }
    [str release]; str = nil;
}

- (void) handleProfileUpload
{
    [self.customHTTPDelegate profileUploadFinished];
}
- (void) handleNewUserRegistration:(ASIHTTPRequest *)theRequest
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:20];
   // NSLog(@"the request: %@", [theRequest responseString]);
  
    [str setString:[theRequest responseString]];
    //NSLog(@"str: %@", str);    

    //Preprocess string to remove ",/,new line. 
    [self preprocess:str];
  
    if ([str isEqualToString:@"Email Exists"]) {
        [ErrorHandler displayString:@"Email is already registered" forDelegate:nil]; 
        [str release]; str = nil;
        [self.customHTTPDelegate stopSpinner];
        return;
    }
    //Extract the user id using numberformatter
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *userId = [f numberFromString:str];
    [f release];
    [str release]; str =nil;
    
    if (userId == nil) {
        [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:self];
        [self.customHTTPDelegate stopSpinner];
        return;
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[userId integerValue] forKey:@"userId"];
    [prefs synchronize];
    [self.customHTTPDelegate doneCreatingNewUser];
}

- (void) handleCurrentUserLogin: (ASIHTTPRequest *)theRequest
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:20];
    //NSLog(@"the request: %@", [theRequest responseString]);
    [str setString:[theRequest responseString]];
    //NSLog(@"str: %@", str);    
    //Preprocess string to remove ",/,new line. 
    [self preprocess:str];
    
    if ([str isEqualToString:@"Failure"]) {
        [ErrorHandler displayString:@"Invalid login" forDelegate:nil];
        [str release]; str = nil;
        [self.customHTTPDelegate stopSpinner];
        return;
    }
    if ([str isEqualToString:@"Success"]) {
        
        [str release]; str = nil;
        [self.customHTTPDelegate doneLoginCurrentUser:YES profile:nil school:nil work:nil music:nil movie:nil book:nil hobby:nil tvshow:nil photo:nil revelation:nil];
        return;
    }
    
    //Preprocess string to delete ends '[' and ']' 
    if (![self deleteEnds:str]) {
        [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
        [str release]; str = nil;
        [self.customHTTPDelegate stopSpinner];
        return;
    }
    
    NSArray *tempArray = [str componentsSeparatedByString:@"]["];
    [str release]; str = nil;
    
    NSString *tempStr = (NSString*)[tempArray objectAtIndex:0];
    NSArray *profileArray = [tempStr componentsSeparatedByString:@","]; 
    
    NSArray *schoolArray = [[tempArray objectAtIndex:1] componentsSeparatedByString:@","];
    NSArray *workArray = [[tempArray objectAtIndex:2] componentsSeparatedByString:@","];
    NSArray *musicArray = [[tempArray objectAtIndex:3] componentsSeparatedByString:@","];
    NSArray *movieArray = [[tempArray objectAtIndex:4] componentsSeparatedByString:@","];
    NSArray *bookArray = [[tempArray objectAtIndex:5] componentsSeparatedByString:@","];
    NSArray *hobbyArray = [[tempArray objectAtIndex:6] componentsSeparatedByString:@","];
    NSArray *tvshowArray = [[tempArray objectAtIndex:7] componentsSeparatedByString:@","];
    
    NSMutableString *photoStr = [[NSMutableString alloc] initWithString:[tempArray objectAtIndex:8]];
    if([photoStr length] > 2)
    {                                                    
        [photoStr setString:[photoStr substringWithRange:NSMakeRange(1, [photoStr length] - 2)]];
    }
    NSArray *photoArray = [photoStr componentsSeparatedByString:@"],["];
    [photoStr release]; photoStr = nil;
    
    NSArray *revelationArray = [[tempArray objectAtIndex:9] componentsSeparatedByString:@","];
    
    
    [self.customHTTPDelegate doneLoginCurrentUser:NO profile:profileArray school:schoolArray work:workArray music:musicArray movie:movieArray book:bookArray hobby:hobbyArray tvshow:tvshowArray photo:photoArray revelation:revelationArray];
    
}


- (void) handleCheckIn
{
    [self.customHTTPDelegate doneCheckingIn];
}

- (void) handleCheckOut
{
    [self.customHTTPDelegate doneCheckingOut];
}

- (void) handleNearbyLocations:(ASIHTTPRequest *)theRequest
{
    [self.customHTTPDelegate doneFindingNearbyLocations: [theRequest responseData]];
}

- (void) handlePollingComplete:(ASIHTTPRequest *)theRequest
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:20];
    [str setString: [theRequest responseString]];
    [self preprocessPreserveDoubleQuotes:str];
    if ([str isEqualToString:@"\"NO DATA\""]) {
        [self.customHTTPDelegate resetTimer:NO];
        [str release]; str =nil;
        return;
    }

    if (![self deleteEnds:str]) {
            [self.customHTTPDelegate resetTimer:NO];
            [str release]; str = nil;
            return;
    }
       
    NSArray *tempArray = [str componentsSeparatedByString:@"]["];
    [str release]; str = nil;
    
    NSString *tempStr = (NSString*)[tempArray objectAtIndex:0];
    NSArray *messageidArray = [tempStr componentsSeparatedByString:@","]; 
  
    tempStr = (NSString*) [tempArray objectAtIndex:1];
    NSArray *useridArray = [tempStr componentsSeparatedByString:@","];
    tempStr = (NSString*) [tempArray objectAtIndex:2];
    NSMutableArray *usernameArray = [[[tempStr componentsSeparatedByString:@"\",\""] mutableCopy] autorelease];
    [self preprocessRemoveDoubleQuotes:usernameArray];
    
    tempStr = (NSString*) [tempArray objectAtIndex:3];
    NSMutableArray *timestampArray = [[[tempStr componentsSeparatedByString:@"\",\""] mutableCopy] autorelease];
    [self preprocessRemoveDoubleQuotes:timestampArray];
    
    tempStr = (NSString*) [tempArray objectAtIndex:4];
    NSMutableArray *messageArray = [[[tempStr componentsSeparatedByString:@"\",\""] mutableCopy] autorelease];
    [self preprocessRemoveDoubleQuotes:messageArray];
    
    int numNewMessages = [messageidArray count];
    
    [self.customHTTPDelegate doneLoadingNewMessages:numNewMessages messageId:messageidArray userId:useridArray username:usernameArray message:messageArray timestamp:timestampArray];
}

- (void) handleSettingChange
{
    [self.customHTTPDelegate doneChangingSetting];
}

- (void) handlePasswordReset:(ASIHTTPRequest *)theRequest
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:20];
    [str setString: [theRequest responseString]];
    [self preprocess:str];
    
    if ([str isEqualToString:@"Invalid Email"]) {
        [ErrorHandler displayString:@"Please make sure the email is filled in and correct" forDelegate:nil];
        [str release]; str =nil;
        [self.customHTTPDelegate stopSpinner];
        return;
    }
    else if ([str isEqualToString:@"Success"]){
        [ErrorHandler displayInfoString:@"Password has been reset. Please check email for the new password" forDelegate:nil];
        [str release]; str =nil;
        [self.customHTTPDelegate stopSpinner];
        return;
        
    }
    else if([str isEqualToString:@"Fail"]){
        [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
        [str release]; str =nil;
        [self.customHTTPDelegate stopSpinner];
        return;

    }
    else {
        [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
        [str release]; str =nil;
        [self.customHTTPDelegate stopSpinner];
        return;
    }
    
}

- (void) handleRegistrationDeviceToken
{
    [self.customHTTPDelegate providerDeviceTokenSent];
}

- (void) preprocessRemoveDoubleQuotes: (NSMutableArray*) arr
{
    NSArray *tempArr = [arr copy];
    for (NSString* str in tempArr) {
        [arr replaceObjectAtIndex:[tempArr indexOfObject:str] withObject:[str stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    }
    [tempArr release]; tempArr = nil;
}

- (void) preprocessPreserveDoubleQuotes:(NSMutableString *)str
{
    [str replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];//#v2.1
    [str replaceOccurrencesOfString:@"\\/" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];//#v2.1
    
    CFStringRef transform = CFSTR("Any-Hex/Java");//#v2.1 to handle unicode
    CFStringTransform((CFMutableStringRef)str, NULL, transform, YES);//#v2.1 to handle unicode
 
}
- (void) preprocess: (NSMutableString*) str 
{
    [str replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];//#v2.1
    [str replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\\/" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];//#v2.1
     
    CFStringRef transform = CFSTR("Any-Hex/Java"); //#v2.1 to handle unicode
    CFStringTransform((CFMutableStringRef)str, NULL, transform, YES); //#v2.1 to handle unicode
}

- (BOOL) deleteEnds: (NSMutableString*) str
{
    if ([str length] > 2) {
        [str deleteCharactersInRange:NSMakeRange(0, 1)];
        [str deleteCharactersInRange:NSMakeRange([str length]-1, 1)];
        return YES;
    }
    else
    {
        return NO;
    }

}
@end
