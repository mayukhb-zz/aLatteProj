//
//  Constants.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 4/3/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "Constants.h"


@implementation Constants

NSString* const APPID = @"530011154";
int const ONE = 1;
int const TWO = 2;
int const KEYBOARD_HEIGHT = 236;
NSString* const PATH = @"/Users/Mayukh/Sites/";
NSString* const URLPATH = @"http://alatteapp.com/scripts/";
NSString* const REGURLPATH = @"http://alatteapp.com/";
NSString* const SERVERREALM = @"aLatte Server"; // Set in httpd.conf basic auth section
NSString* const PUBLICPATH = @"public.php";
NSString* const PRIVATEPATH = @"scripts/index.php";

//Constants for Chat 
 CGFloat const kSentDateFontSize = 13.0f;
 CGFloat const kMessageFontSize   = 16.0f;   // 15.0f, 14.0f
 CGFloat const kMessageTextWidth  = 180.0f;
 CGFloat const kContentHeightMax  = 84.0f;  // 80.0f, 76.0f
 CGFloat const kChatBarHeight1    = 40.0f;
 CGFloat const kChatBarHeight4    = 94.0f;

//ProfileTableSetting Constants
int const NUM_SECTIONS_PROFILE_SETTINGS = 4;
int const ACCOUNT_SECTION = 0;
int const SOUND_SECTION = 1;
int const REVEAL_SECTION = 2;
int const RANGE_SECTION = 3;
//int const SESSTION_SECTION = 4;
int const NUM_ROWS_ACCOUNT_SECTION = 2;
int const NUM_ROWS_SOUND_SECTION = 1;
//int const NUM_ROWS_APPEARANCE_SECTION = 2;
int const NUM_ROWS_REVEAL_SECTION = 1;
int const NUM_ROWS_RANGE_SECTION = 1;
int const USERID_ROW = 0;

//CustomHTTPRequest tag constants
int const REQUEST_FOR_NEARBY_DATES = 1;
int const REQUEST_FOR_DATE_PROFILE = 2;
int const REQUEST_FOR_SEND_CHAT_MESSAGE = 3;
int const REQUEST_FOR_REVELATION = 4;
int const REQUEST_FOR_POLLING = 5;
int const REQUEST_FOR_PROFILE_EDIT = 6;
int const REQUEST_FOR_ADD_PHOTO = 7;
int const REQUEST_FOR_DELETE_PHOTO = 8;
int const REQUEST_FOR_PROFILE_PIC_LABEL = 9;
int const REQUEST_FOR_NEW_USER = 10;
int const REQUEST_FOR_CURRENT_USER = 11;
int const REQUEST_FOR_CHECK_IN = 12;
int const REQUEST_FOR_CHECK_OUT = 13;
int const REQUEST_FOR_NEARBY_LOCATIONS = 14;
int const REQUEST_FOR_SETTING_CHANGE = 15;
int const REQUEST_FOR_RESET_PASSWD = 16;
int const REQUEST_FOR_DEVICE_TOKEN_REGISTRATION = 17;
int const REQUEST_FOR_ADD_PHOTO_THUMBNAIL = 18;

@end
