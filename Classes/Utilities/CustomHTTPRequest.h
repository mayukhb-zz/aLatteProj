//
//  CustomHTTPRequest.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 12/26/11.
//  Copyright (c) 2011 Individual. All rights reserved.
//

#import "ASIFormDataRequest.h"

@protocol CustomHTTPRequestDelegate;
@class CachedProfileVO;

@interface CustomHTTPRequest : ASIFormDataRequest
{
    
}

@property (nonatomic, retain) id <CustomHTTPRequestDelegate> customHTTPDelegate;

- (id)initWithPath:(NSString *)path presentDialog:(BOOL)dialog;
- (id)initWithXMLPath:(NSString *)path;

- (void) setPostValues:(NSMutableDictionary*) dict;
- (void) addDataForImageContent:(NSData*) imgData withKey:(NSString*) key;

+ (NSURL *)apiURLWithPath:(NSString *)path ;

+ (NSString *)username;
+ (NSString *)passwd;

+ (BOOL)loggedIn;

+ (void)storeUsername:(NSString *)u password:(NSString *)p;
+ (void)logout;
    
- (void)downloadFailed:(ASIHTTPRequest *)theRequest;
- (void)downloadFinished:(ASIHTTPRequest *)theRequest;
- (void) preprocess:(NSMutableString*) str ;
- (void) preprocessPreserveDoubleQuotes: (NSMutableString*) str ;
- (void) preprocessRemoveDoubleQuotes:(NSMutableArray*) arr;
- (BOOL) deleteEnds: (NSMutableString*) str;

// Methods to handle different requests completion
- (void) handleDateProfileDidDownload: (ASIHTTPRequest*) theRequest;
- (void) handleNearbyDatesDidFound: (ASIHTTPRequest*) theRequest;
- (void) handleSendMessage;
- (void) handleRevelation;
- (void) handlePhotoUpload:(ASIHTTPRequest*) theRequest;
- (void) handleProfilePicUpload:(ASIHTTPRequest*) theRequest;
/*v2 start */
- (void) handlePhotoAndProfilePicUpload:(ASIHTTPRequest*) theRequest;
/*v2 end */
- (void) handlePhotoDelete: (ASIHTTPRequest*) theRequest;
- (void) handleProfileUpload;
- (void) handleNewUserRegistration: (ASIHTTPRequest*) theRequest;
- (void) handleCurrentUserLogin: (ASIHTTPRequest *)theRequest;
- (void) handleCheckIn;
- (void) handleCheckOut;
- (void) handleNearbyLocations : (ASIHTTPRequest *)theRequest;
- (void) handlePollingComplete : (ASIHTTPRequest *)theRequest;
- (void) handleSettingChange;
- (void) handlePasswordReset:(ASIHTTPRequest *)theRequest;
- (void) handleRegistrationDeviceToken;
@end

@protocol CustomHTTPRequestDelegate <NSObject>

@optional

- (void)dateProfileDidDownload:(CachedProfileVO *)vo;
- (void)doneLoadingTableViewData;
- (void)stopSpinner;
- (void)nearbyDatesDidFound:(BOOL) isCheckedInParam userIdArray:(NSArray*)userIdArrayParam dateArray:(NSArray*)dateArrayParam placesArray:(NSArray*)placesArrayParam pathArray:(NSArray*)pathArrayParam ;
- (void) sendMessageDidComplete;
- (void) sendMessageFailed:(NSString*) status;
- (void) revealFinished;
- (void) photoUploadFinished:(NSNumber*) photoIdentifier path:(NSString*) path;
- (void) profilePicUploaded;
- (void) photoDeleteFinished;
- (void) profileUploadFinished;
- (void) doneCreatingNewUser;
- (void)doneLoginCurrentUser:(BOOL) login profile:(NSArray*)profileArray school:(NSArray*) schoolArray work:(NSArray*) workArray music:(NSArray*) musicArray movie:(NSArray*) movieArray book:(NSArray*) bookArray hobby:(NSArray*) hobbyArray tvshow:(NSArray*) tvshowArray photo:(NSArray*) photoArray revelation:(NSArray*) revelationArray;

- (void) doneCheckingIn;
- (void) doneCheckingOut;
- (void) doneFindingNearbyLocations: (NSData*) xmlData;
- (void) failedFindingNearbyLocations;
- (void) resetTimer: (BOOL) lastFireRetrivedMessage;
- (void) doneLoadingNewMessages:(int) numNewMessages messageId:(NSArray*) messageIdArray userId:(NSArray*) useridArray username:(NSMutableArray*) userNameArray message:(NSMutableArray*) messageArray timestamp:(NSMutableArray*) timeStampArray;
- (void) doneChangingSetting;
- (void) providerDeviceTokenSent;

@end