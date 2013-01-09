//
//  Constants.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 4/3/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const APPID; //v2
extern int const ONE;
extern int const TWO;
extern int const KEYBOARD_HEIGHT;
extern NSString* const PATH;
extern NSString* const URLPATH;
extern NSString* const REGURLPATH;
extern NSString* const SERVERREALM;
extern NSString* const PUBLICPATH;
extern NSString* const PRIVATEPATH;

//Chat constants
extern CGFloat const kSentDateFontSize; 
extern CGFloat const kMessageFontSize;  
extern CGFloat const kMessageTextWidth; 
extern CGFloat const kContentHeightMax; 
extern CGFloat const kChatBarHeight1;   
extern CGFloat const kChatBarHeight4;   

//ProfileTableSetting Constants
extern int const NUM_SECTIONS_PROFILE_SETTINGS;
extern int const ACCOUNT_SECTION;
extern int const SOUND_SECTION;
extern int const RANGE_SECTION;
extern int const REVEAL_SECTION;
//extern int const SESSION_SECTION;
extern int const NUM_ROWS_ACCOUNT_SECTION;
extern int const NUM_ROWS_SOUND_SECTION;
//extern int const NUM_ROWS_APPEARANCE_SECTION;
extern int const NUM_ROWS_REVEAL_SECTION;
extern int const NUM_ROWS_RANGE_SECTION;
extern int const USERID_ROW;

//CustomHTTPRequest tag constants
extern int const REQUEST_FOR_NEARBY_DATES;
extern int const REQUEST_FOR_DATE_PROFILE;
extern int const REQUEST_FOR_SEND_CHAT_MESSAGE;
extern int const REQUEST_FOR_REVELATION;
extern int const REQUEST_FOR_POLLING;
extern int const REQUEST_FOR_PROFILE_EDIT;
extern int const REQUEST_FOR_ADD_PHOTO;
extern int const REQUEST_FOR_DELETE_PHOTO;
extern int const REQUEST_FOR_PROFILE_PIC_LABEL;
extern int const REQUEST_FOR_NEW_USER;
extern int const REQUEST_FOR_CURRENT_USER;
extern int const REQUEST_FOR_CHECK_IN;
extern int const REQUEST_FOR_CHECK_OUT;
extern int const REQUEST_FOR_NEARBY_LOCATIONS;
extern int const REQUEST_FOR_SETTING_CHANGE;
extern int const REQUEST_FOR_RESET_PASSWD;
extern int const REQUEST_FOR_DEVICE_TOKEN_REGISTRATION;
extern int const REQUEST_FOR_ADD_PHOTO_THUMBNAIL;

@interface Constants : NSObject {


}

@end
