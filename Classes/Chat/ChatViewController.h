//
//  ChatViewController.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/8/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <CoreData/CoreData.h>
#import "HGPageView.h"
#import "PageHeaderInfo.h"
#import "CustomHTTPRequest.h"
#import "MBProgressHUD.h"

@class Chat;
 
@protocol ChatViewControllerDelegate 

- (void) resetTimer: (BOOL) lastFireRetrivedMessage;

@end

@interface ChatViewController : UIViewController <NSFetchedResultsControllerDelegate,
UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate, PageHeaderInfo, CustomHTTPRequestDelegate, UIAlertViewDelegate> {
    
    CGRect keyboardEndFrame;
    int userId;
    NSString *chatUserName;
    NSNumber *badgeNumber;
    
    CustomHTTPRequest *request;
    id<ChatViewControllerDelegate> delegate;
    MBProgressHUD *spinner;
    UITapGestureRecognizer *gestureRecognizer;

}

@property (nonatomic, assign) SystemSoundID receiveMessageSound;
@property (nonatomic, assign) BOOL keyboardIsShowing;
@property (nonatomic, assign) CGFloat previousContentHeight;
@property (nonatomic, assign) int userId;
@property (nonatomic, retain) NSString *chatUserName;
@property (nonatomic, retain) NSNumber *badgeNumber;

@property (nonatomic, retain) NSMutableArray *cellMap;

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UITableView *chatContent;
@property (nonatomic, retain) UIImageView *chatBar;
@property (nonatomic, retain) UITextView *chatInput;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) UIButton *deleteChatButton;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIImage *clearballoon;
@property (nonatomic, retain) UIImage *greenballoon;

@property (nonatomic, assign) int tabBarHeight;
@property (nonatomic, assign) int navBarHeight;

@property (nonatomic, retain) CustomHTTPRequest *request;
@property (nonatomic, assign) id<ChatViewControllerDelegate> delegate;
@property (nonatomic, retain) MBProgressHUD *spinner;
@property (nonatomic, retain) UITapGestureRecognizer *gestureRecognizer;

- (void)enableSendButton;
- (void)disableSendButton;
- (void)resetSendButton;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)slideFrame:(BOOL)up curve:(UIViewAnimationCurve)curve duration:(NSTimeInterval)duration;
- (void)scrollToBottomAnimated:(BOOL)animated;

- (void)sendMessage;
- (void)clearChatInput;
- (NSUInteger)addMessage:(Chat *)message;
//- (NSUInteger)removeMessageAtIndex:(NSUInteger)index;
//- (void)clearAll;

- (void)fetchMessages;
- (void) stopRetryingSendingMessage;
- (void)backgroundTap:(id)sender ;

@end
