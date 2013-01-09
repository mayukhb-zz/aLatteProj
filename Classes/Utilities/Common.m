//
//  Common.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 6/30/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "Common.h"


@implementation Common

static Common *_sharedInstance;
@synthesize userid;
@synthesize tabBarHeight, navBarHeight;

+ (Common *) sharedInstance
{
	if (!_sharedInstance)
	{
		_sharedInstance = [[Common alloc] init];
	}
    
	return _sharedInstance;
}

+ (void) setTheme: (UIViewController*) vc 
{
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //int theme = [prefs integerForKey:@"theme"] ;
    NSString *themeImg = @"background.png";
    
    vc.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:themeImg]];
    
}
+ (void) setTheme: (UIViewController*) vc forTableView: (UITableView *) t
{
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //int theme = [prefs integerForKey:@"theme"] ;
    NSString *themeImg = @"background.png";
    
    vc.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:themeImg]];
    t.backgroundColor = [UIColor clearColor];

}

+ (void) setUIViewTheme: (UIView*) vc forTableView: (UITableView *) t
{
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //int theme = [prefs integerForKey:@"theme"] ;
    NSString *themeImg =  @"background.png";
    
    vc.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:themeImg]];
    t.backgroundColor = [UIColor clearColor];
    
}

+ (void) setSearchViewTheme: (UITableView *) t
{
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //int theme = [prefs integerForKey:@"theme"] ;
    NSString *themeImg = @"chatBackground.png";
    
    t.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:themeImg]] autorelease];
    t.backgroundView.contentMode = UIViewContentModeTopLeft;
    t.separatorStyle = UITableViewCellSeparatorStyleNone;
    t.backgroundColor = [UIColor clearColor];
    
}
/*v2 start */
+ (NSString*) generateRandomString {
    NSString *characters = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int len = [characters length];
    NSMutableString *randomString = [[[NSMutableString alloc] initWithString:@""] autorelease];
    for (int i = 0; i < 8; i++) {
        [randomString appendString:[characters substringWithRange:NSMakeRange(arc4random() % len, 1)]] ;
    }
    return [NSString stringWithString:randomString];
}
/*v2 end */
- (void)dealloc
{
    [userid release]; userid = nil;
    [super dealloc];
}

@end
