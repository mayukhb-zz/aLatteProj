//
//  ChatPageViewController.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 7/29/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGPageScrollView.h"
#import "PageHeaderInfo.h"
#import <CoreData/CoreData.h>
#import "DateProfileView.h"
#import "CustomHTTPRequest.h"
#import "ChatViewController.h"
#import "RevealTutorialViewController.h"

#define kNumPages 2

@interface ChatPageViewController : UIViewController <HGPageScrollViewDelegate, HGPageScrollViewDataSource, UITextFieldDelegate, PageHeaderInfo, ChatViewControllerDelegate, CustomHTTPRequestDelegate, UIActionSheetDelegate, RevealTutorialDelegate> {
    
	HGPageScrollView *_myPageScrollView;
    NSMutableArray   *_myPageDataArray;
	
	IBOutlet UIToolbar *toolbar;
    
    NSMutableIndexSet *indexesToDelete, *indexesToInsert, *indexesToReload;
    NSMutableArray *usersArray;
    NSMutableArray *userIds;
	
    int numPages;
    NSNumber *activeUserId;
    NSNumber *selectedUserId;
    NSString *activeUserName;
    UIButton *deleteChatButton;
    
    int selectedIndex;
    CustomHTTPRequest *request;
    CustomHTTPRequest *requestPollMsg;
    NSTimer *timer;
    
    BOOL reloadFlag;
    BOOL revealByDefault;
    
    UIBarButtonItem *revealButton;
    UIBarButtonItem *revealAnimatedButton;
    
    UITapGestureRecognizer *gestureRecognizer;

    }

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableArray *usersArray;
@property (nonatomic, retain) NSMutableArray *userIds;
@property (nonatomic, assign) int numPages;
@property (nonatomic, retain) NSNumber* activeUserId;
@property (nonatomic, retain) NSNumber* selectedUserId;
@property (nonatomic, retain) NSString* activeUserName;
@property (nonatomic, retain) UIButton *deleteChatButton;

@property (nonatomic, retain) CustomHTTPRequest *request;
@property (nonatomic, retain) CustomHTTPRequest *requestPollMsg;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, assign) BOOL reloadFlag;
@property (nonatomic, assign) BOOL revealByDefault;
@property (nonatomic, retain) UIBarButtonItem *revealButton;
@property (nonatomic, retain) UIBarButtonItem *revealAnimatedButton;

- (void) didClickBrowsePages;
- (void) didClickAddPage;
- (void) removeDeleteButton;
- (void) addDeleteButton;
- (void) removeInfoLabel;
- (void) pollForNewMessages;
- (void) resetTimer: (BOOL) lastFireRetrivedMessage;
- (void) timerCallback;
- (void) reloadChatPageView;
- (void) loadChatPageView;
- (void) saveNewMessageCount;
- (BOOL) revleaLButtonEnabledFlag: (NSNumber *) revealedToUserId;
- (void) setRevealState;
- (void) stopPollingForMessages;
- (void) setupRevealButton;

@end
