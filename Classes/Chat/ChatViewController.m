//
//  ChatViewController.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/8/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ChatViewController.h"
#import "Chat.h"
#import "NSString+Additions.h"
#import "Constants.h"
#import "Common.h"
#import "ErrorHandler.h"

#define CHAT_BACKGROUND_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"chatBackground.png"]];

#define VIEW_WIDTH    self.contentView.frame.size.width
#define VIEW_HEIGHT    self.contentView.frame.size.height

#define RESET_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight1)
#define EXPAND_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight4)

#define    SET_CHAT_BAR_HEIGHT(HEIGHT)\
    CGRect chatContentFrame = chatContent.frame;\
    chatContentFrame.size.height = VIEW_HEIGHT - HEIGHT;\
    [UIView beginAnimations:nil context:NULL];\
    [UIView setAnimationDuration:0.1f];\
    chatContent.frame = chatContentFrame;\
    chatBar.frame = CGRectMake(chatBar.frame.origin.x, chatContentFrame.size.height,\
            VIEW_WIDTH, HEIGHT);\
    [UIView commitAnimations]

#define BAR_BUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE\
    style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define ClearConversationButtonIndex 0

// 15 mins between messages before we show the date
#define SECONDS_BETWEEN_MESSAGES        (60*15)


@implementation ChatViewController

@synthesize receiveMessageSound;
@synthesize contentView;
@synthesize chatContent;

@synthesize chatBar;
@synthesize chatInput;
@synthesize previousContentHeight;
@synthesize sendButton;
@synthesize deleteChatButton;

@synthesize cellMap;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

@synthesize clearballoon;
@synthesize greenballoon;
@synthesize keyboardIsShowing;
@synthesize userId, chatUserName, badgeNumber;
@synthesize tabBarHeight, navBarHeight;
@synthesize request;
@synthesize delegate;
@synthesize spinner;
@synthesize gestureRecognizer;

#pragma mark NSObject

- (void)dealloc {
    if (receiveMessageSound) AudioServicesDisposeSystemSoundID(receiveMessageSound);
    
    [contentView release]; contentView = nil;
    [chatContent release]; chatContent = nil;
    
    [sendButton release]; sendButton = nil;
    [deleteChatButton release]; deleteChatButton = nil;
    [chatInput release]; chatInput = nil;
    [chatBar release]; chatBar = nil;
    
    [cellMap release]; cellMap = nil;
    
    [managedObjectContext release]; managedObjectContext = nil;
    [clearballoon release]; clearballoon = nil;
    [greenballoon release]; greenballoon = nil;
    [chatUserName release]; chatUserName = nil;
    [badgeNumber release]; badgeNumber = nil;
   
    [self.request clearDelegatesAndCancel];
    self.request.customHTTPDelegate = nil;
    [request release]; request = nil;
    
    [spinner release]; spinner = nil;
    [gestureRecognizer release]; gestureRecognizer = nil;
    [super dealloc];
}

#pragma mark UIViewController

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.contentView = nil;
    self.chatContent = nil;
    self.sendButton = nil;
    self.chatInput = nil;
    self.chatBar = nil;
    self.cellMap = nil;
    self.fetchedResultsController = nil;
    self.clearballoon = nil;
    self.greenballoon = nil;
    self.deleteChatButton = nil;
    self.spinner = nil;
    self.gestureRecognizer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];    
    
    // Create contentView.
    CGRect navFrame = [[UIScreen mainScreen] applicationFrame];
    //Get the tabBarHeight and navBarHeight
    Common *com = [Common sharedInstance];
    self.tabBarHeight = com.tabBarHeight;
    self.navBarHeight= com.navBarHeight;
    navFrame.size.height -= self.navBarHeight;//44;//self.navigationController.navigationBar.frame.size.height;
    navFrame.size.height -= self.tabBarHeight;//50;//self.tabBarController.tabBar.frame.size.height;

    self.view.backgroundColor = CHAT_BACKGROUND_COLOR; // shown during rotation    
    UIView* tempView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 
                                                                0.0f, 
                                                                navFrame.size.width,
                                                                navFrame.size.height)];
    self.contentView = tempView;
    [tempView release]; tempView = nil;
    
    self.contentView.backgroundColor = CHAT_BACKGROUND_COLOR; // shown during rotation
    self.contentView.autoresizingMask = UIViewAutoresizingNone;
    
    [self.view addSubview:self.contentView];
    
    // Create chatContent.
    self.chatContent = [[[UITableView alloc] initWithFrame:
                   CGRectMake(0.0f, 0.0f, contentView.frame.size.width,
                              contentView.frame.size.height-kChatBarHeight1)] autorelease];
    self.chatContent.clearsContextBeforeDrawing = NO;
    self.chatContent.delegate = self;
    self.chatContent.dataSource = self;
    self.chatContent.contentInset = UIEdgeInsetsMake(7.0f, 0.0f, 0.0f, 0.0f);
    self.chatContent.backgroundColor = [UIColor clearColor] ;//CHAT_BACKGROUND_COLOR;
    self.chatContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatContent.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.chatContent];
    
    // Create chatBar.
    self.chatBar = [[[UIImageView alloc] initWithFrame:
               CGRectMake(0.0f, self.contentView.frame.size.height-kChatBarHeight1,
                          self.contentView.frame.size.width, kChatBarHeight1)] autorelease];
    self.chatBar.clearsContextBeforeDrawing = NO;
    self.chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth;
    self.chatBar.image = [[UIImage imageNamed:@"ChatBar.png"]
                     stretchableImageWithLeftCapWidth:18 topCapHeight:20];
    self.chatBar.userInteractionEnabled = YES;
    
    // Create chatInput.
    self.chatInput = [[[UITextView alloc] initWithFrame:CGRectMake(10.0f, 9.0f, 234.0f, 22.0f)] autorelease];
    self.chatInput.contentSize = CGSizeMake(234.0f, 22.0f);
    self.chatInput.keyboardType = UIKeyboardTypeASCIICapable; // bugfix-v1 prevent emoji crash
    self.chatInput.delegate = self;
    self.chatInput.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.chatInput.scrollEnabled = NO; // not initially
    self.chatInput.scrollIndicatorInsets = UIEdgeInsetsMake(5.0f, 0.0f, 4.0f, -2.0f);
    self.chatInput.clearsContextBeforeDrawing = NO;
    self.chatInput.font = [UIFont systemFontOfSize:kMessageFontSize];
    self.chatInput.dataDetectorTypes = UIDataDetectorTypeAll;
    self.chatInput.backgroundColor = [UIColor clearColor];
    previousContentHeight = self.chatInput.contentSize.height;
    [self.chatBar addSubview:self.chatInput];
    
    // Create sendButton.
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.clearsContextBeforeDrawing = NO;
    self.sendButton.frame = CGRectMake(self.chatBar.frame.size.width - 70.0f, 8.0f, 64.0f, 26.0f);
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | // multi-line input
    UIViewAutoresizingFlexibleLeftMargin;                       // landscape
    UIImage *sendButtonBackground = [UIImage imageNamed:@"SendButton.png"];
    [self.sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateDisabled];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.sendButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    UIColor *shadowColor = [[UIColor alloc] initWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [self.sendButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [shadowColor release];
    [self.sendButton addTarget:self action:@selector(sendMessage)
         forControlEvents:UIControlEventTouchUpInside];
    //    // The following three lines aren't necessary now that we'are using background image.
    //    sendButton.backgroundColor = [UIColor clearColor];
    //    sendButton.layer.cornerRadius = 13; 
    //    sendButton.clipsToBounds = YES;
    [self resetSendButton]; // disable initially
    [self.chatBar addSubview:self.sendButton];
    
    [self.contentView addSubview:self.chatBar];
    [self.contentView sendSubviewToBack:self.chatBar];
    
    // Listen for keyboard.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // optimization FTW.
    self.clearballoon = [[UIImage imageNamed:@"ChatBubbleGray"] stretchableImageWithLeftCapWidth:23.0f topCapHeight:15.0f];
    self.greenballoon = [[UIImage imageNamed:@"ChatBubbleOrange"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:13.0f];

    [self fetchMessages];
    
    // Construct cellMap from fetchedObjects.
    self.cellMap = [[[NSMutableArray alloc]
               initWithCapacity:[[self.fetchedResultsController fetchedObjects] count]*2] autorelease];
    
   
    for (Chat *message in [self.fetchedResultsController fetchedObjects]) {
        [self addMessage:message];
    }
    
    //MBProgressHUD start
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [HUD setCenter:CGPointMake(160.0, 100.0)];
  
    self.spinner = HUD;
    [HUD release]; HUD = nil;
	[self.view addSubview:self.spinner];
	
	
    //MBProgressHUD end
    
    self.gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)] autorelease];
    self.gestureRecognizer.numberOfTapsRequired=1;
    self.gestureRecognizer.numberOfTouchesRequired=1;
    self.gestureRecognizer.cancelsTouchesInView = NO;
    [self.chatContent addGestureRecognizer:self.gestureRecognizer];
    
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated]; // below: work around for [chatContent flashScrollIndicators]
    [self.chatContent performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.0];
    [self scrollToBottomAnimated:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    //return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

/*- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    [chatContent setEditing:(BOOL)editing animated:(BOOL)animated]; // forward method call
//    chatContent.separatorStyle = editing ?
//            UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    
    if (editing) {
        UIBarButtonItem *clearAllButton = BAR_BUTTON(NSLocalizedString(@"Clear All", nil),
                                                     @selector(clearAll));
        self.navigationItem.leftBarButtonItem = clearAllButton;
        [clearAllButton release];
    } else {
        UIBarButtonItem *pageButton = BAR_BUTTON(NSLocalizedString(@"Page", nil),
                                                 @selector(paginate));
        self.navigationItem.leftBarButtonItem = pageButton;
        [pageButton release];
    }
    
//    if ([chatInput isFirstResponder]) {
//        NSLog(@"resign first responder");
//        [chatInput resignFirstResponder];
//    }
}*/

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat contentHeight = textView.contentSize.height - kMessageFontSize + 2.0f;
    NSString *rightTrimmedText = @"";
        
    if ([textView hasText]) {
        rightTrimmedText = [textView.text
                            stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
        
        if (textView.text.length > 160) { // truncate text to 160 chars
            textView.text = [textView.text substringToIndex:160];
        }
        
        // Resize textView to contentHeight
        if (contentHeight != previousContentHeight) {
            if (contentHeight <= kContentHeightMax) { // limit chatInputHeight <= 4 lines
                CGFloat chatBarHeight = contentHeight + 18.0f;
                SET_CHAT_BAR_HEIGHT(chatBarHeight);
                if (previousContentHeight > kContentHeightMax) {
                    textView.scrollEnabled = NO;
                }
                textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
                [self scrollToBottomAnimated:YES];
           } else if (previousContentHeight <= kContentHeightMax) { // grow
                textView.scrollEnabled = YES;
                textView.contentOffset = CGPointMake(0.0f, contentHeight-68.0f); // shift to bottom
                if (previousContentHeight < kContentHeightMax) {
                    EXPAND_CHAT_BAR_HEIGHT;
                    [self scrollToBottomAnimated:YES];
                }
            }
        }
    } else { // textView is empty
        if (previousContentHeight > 22.0f) {
            RESET_CHAT_BAR_HEIGHT;
            if (previousContentHeight > kContentHeightMax) {
                textView.scrollEnabled = NO;
            }
        }
        textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
    }
    
    // Enable sendButton if chatInput has non-blank text, disable otherwise.
    if (rightTrimmedText.length > 0) {
        [self enableSendButton];
        
    } else {
        [self disableSendButton];
       
    }
    
    previousContentHeight = contentHeight;
}

// Fix a scrolling quirk.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
    return YES;
}

#pragma mark ChatViewController

- (void)enableSendButton {
    if (sendButton.enabled == NO) {
        sendButton.enabled = YES;
        sendButton.titleLabel.alpha = 1.0f;
    }
}

- (void)disableSendButton {
    if (sendButton.enabled == YES) {
        [self resetSendButton];
    }
}

- (void)resetSendButton {
    sendButton.enabled = NO;
    sendButton.titleLabel.alpha = 0.5f; //  0.4f
}

// Prepare to resize for keyboard.
- (void)keyboardWillShow:(NSNotification *)notification 
{
 	NSDictionary *userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
	//keyboardIsShowing = YES;
    
    [self slideFrame:YES 
               curve:animationCurve 
            duration:animationDuration];
    //UIBarButtonItem *cancelBarButtonItem = BAR_BUTTON(NSLocalizedString(@"Cancel", nil),
                                                 //@selector(hideCancelButton));
    //self.navigationItem.rightBarButtonItem = cancelBarButtonItem;
    //[cancelBarButtonItem release]; cancelBarButtonItem = nil;
    //self.navigationItem.leftBarButtonItem.enabled = NO;
	
}

/*- (void) hideCancelButton
{
    [self.chatInput resignFirstResponder];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self clearChatInput];
}
*/

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification 
{
 	NSDictionary *userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
	//keyboardIsShowing = NO;
    
    [self slideFrame:NO 
               curve:animationCurve 
            duration:animationDuration];
    //[self hideCancelButton];
}

// Shorten height of UIView when keyboard pops up
// TODO: Test on different SDK versions; make more flexible if desired.
- (void)slideFrame:(BOOL)up curve:(UIViewAnimationCurve)curve duration:(NSTimeInterval)duration
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    CGRect viewFrame = self.contentView.frame;
    if (up) {
        viewFrame.size.height -= keyboardEndFrame.size.height;
        viewFrame.size.height += self.tabBarHeight;//self.tabBarController.tabBar.frame.size.height;
    }
    else{
        viewFrame.size.height += keyboardEndFrame.size.height;
        viewFrame.size.height -= self.tabBarHeight;//self.tabBarController.tabBar.frame.size.height;
    }
    
    self.contentView.frame = viewFrame;
    [UIView commitAnimations];
    
    [self scrollToBottomAnimated:YES];
    
    self.chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
    self.chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger bottomRow = [self.cellMap count] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.chatContent scrollToRowAtIndexPath:indexPath
                           atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark Message

- (void)sendMessage {

    NSString *rightTrimmedMessage =
        [self.chatInput.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    
    // Don't send blank messages.
    if (rightTrimmedMessage.length == 0) {
        [self clearChatInput];
        return;
    }
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self disableSendButton];
    [self.spinner show:YES];
    
    NSNumber *num = [NSNumber numberWithInt:self.userId];
   
    // Write new message to server
    
    // Retrieve appuserid from NSUSerDefaults
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSNumber *appUserId = [[NSNumber alloc ] initWithInt:[prefs integerForKey:@"userId"]];
    NSString *appUserName = [[NSString alloc ] initWithString:[prefs stringForKey:@"userName"]];
  
    self.request.customHTTPDelegate = nil;
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:appUserId forKey:@"from_userid"];
    [params setValue:appUserName forKey:@"from_username"];
    [params setValue:num forKey:@"to_userid"];
    [params setValue:self.userName forKey:@"to_username"];
    [params setValue:rightTrimmedMessage forKey:@"text"];
    [params setValue:@"write" forKey:@"mode"];
    [params setValue:@"messages" forKey:@"script"];
     
    [self.request setCustomHTTPDelegate:self];
    self.request.tag = REQUEST_FOR_SEND_CHAT_MESSAGE;
    [self.request setPostValues:params];
    
    [appUserId release]; appUserId = nil;
    [appUserName release]; appUserName = nil;
    // Write to server block complete
    
 
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {	
    [textView resignFirstResponder];
    return YES;	
}


- (void)clearChatInput {
    self.chatInput.text = @"";
    if (previousContentHeight > 22.0f) {
        RESET_CHAT_BAR_HEIGHT;
        self.chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
        self.chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
        [self scrollToBottomAnimated:YES];       
    }
}

// Returns number of objects added to cellMap (1 or 2).
- (NSUInteger)addMessage:(Chat *)message 
{
    // Show sentDates at most every 15 minutes.
    NSDate *currentSentDate = [message sentDate];
    NSUInteger numberOfObjectsAdded = 1;
    NSUInteger prevIndex = [self.cellMap count] - 1;
    
    // Show sentDates at most every 15 minutes.

    if([self.cellMap count])
    {
        BOOL prevIsMessage = [[self.cellMap objectAtIndex:prevIndex] isKindOfClass:[Chat class]];
        if(prevIsMessage)
        {
            Chat * temp = [self.cellMap objectAtIndex:prevIndex];
            NSDate * previousSentDate = temp.sentDate;
            // if there has been more than a 15 min gap between this and the previous message!
            if([currentSentDate timeIntervalSinceDate:previousSentDate] > SECONDS_BETWEEN_MESSAGES) 
            { 
                [self.cellMap addObject:currentSentDate];
                numberOfObjectsAdded = 2;
            }
        }
    }
    else
    {
        // there are NO messages, definitely add a timestamp!
        [self.cellMap addObject:currentSentDate];
        numberOfObjectsAdded = 2;
    }
    
    [self.cellMap addObject:message];
    
    return numberOfObjectsAdded;

}

// Returns number of objects removed from cellMap (1 or 2).
/*- (NSUInteger)removeMessageAtIndex:(NSUInteger)index {
    
    // Remove message from cellMap.
    [self.cellMap removeObjectAtIndex:index];
    NSUInteger numberOfObjectsRemoved = 1;
    NSUInteger prevIndex = index - 1;
    NSUInteger cellMapCount = [self.cellMap count];
    
    BOOL isLastObject = index == cellMapCount;
    BOOL prevIsDate = [[self.cellMap objectAtIndex:prevIndex] isKindOfClass:[NSDate class]];
    
    if (isLastObject && prevIsDate ||
        prevIsDate && [[self.cellMap objectAtIndex:index] isKindOfClass:[NSDate class]]) {
        [self.cellMap removeObjectAtIndex:prevIndex];
        numberOfObjectsRemoved = 2;
    }
    return numberOfObjectsRemoved;
}*/

/*- (void)clearAll {
    UIActionSheet *confirm = [[UIActionSheet alloc]
                              initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:NSLocalizedString(@"Clear Conversation", nil)
                              otherButtonTitles:nil];
	
	// use the same style as the nav bar
	confirm.actionSheetStyle = self.navigationController.navigationBar.barStyle;
    
    [confirm showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
//    [confirm showInView:self.view];
	[confirm release];
    
}
*/
/*#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case ClearConversationButtonIndex: {
            NSError *error;
            fetchedResultsController.delegate = nil;               // turn off delegate callbacks
            for (Chat *message in [fetchedResultsController fetchedObjects]) {
                [self.managedObjectContext deleteObject:message];
            }
            if (![self.managedObjectContext save:&error]) {
                // Handle the error appropriately.
                NSLog(@"Delete message error %@, %@", error, [error userInfo]);
            }
            fetchedResultsController.delegate = self;              // reconnect after mass delete
            if (![fetchedResultsController performFetch:&error]) { // resync controller
                // Handle the error appropriately.
                NSLog(@"fetchMessages error %@, %@", error, [error userInfo]);
            }
            
            [cellMap removeAllObjects];
            [chatContent reloadData];
            
            [self setEditing:NO animated:NO];
            break;
		}
	}
}
*/
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.cellMap count];
}

#define SENT_DATE_TAG 101
#define TEXT_TAG 102
#define BACKGROUND_TAG 103

static NSString *kMessageCell = @"MessageCell";

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *msgSentDate;
    UIImageView *msgBackground;
    UILabel *msgText;

    NSObject *object = [self.cellMap objectAtIndex:[indexPath row]];
    UITableViewCell *cell;
    
    // Handle sentDate (NSDate).
    if ([object isKindOfClass:[NSDate class]]) {
        static NSString *kSentDateCellId = @"SentDateCell";
        cell = [tableView dequeueReusableCellWithIdentifier:kSentDateCellId];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:kSentDateCellId] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Create message sentDate lable
            msgSentDate = [[UILabel alloc] initWithFrame:
                            CGRectMake(-2.0f, 0.0f,
                                       self.chatContent.frame.size.width, kSentDateFontSize+5.0f)];
            msgSentDate.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            msgSentDate.clearsContextBeforeDrawing = NO;
            msgSentDate.tag = SENT_DATE_TAG;
            msgSentDate.font = [UIFont boldSystemFontOfSize:kSentDateFontSize];
            msgSentDate.lineBreakMode = UILineBreakModeTailTruncation;
            msgSentDate.textAlignment = UITextAlignmentCenter;
            msgSentDate.backgroundColor = [UIColor clearColor];//CHAT_BACKGROUND_COLOR; // clearColor slows performance
            msgSentDate.textColor = [UIColor grayColor];
            [cell.contentView addSubview:msgSentDate];
            [msgSentDate release];

        } else {
            msgSentDate = (UILabel *)[cell.contentView viewWithTag:SENT_DATE_TAG];
        }
        
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // Jan 1, 2010
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];  // 1:43 PM
            
            // TODO: Get locale from iPhone system prefs. Then, move this to viewDidAppear.
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            [usLocale release];
        }
        
        msgSentDate.text = [dateFormatter stringFromDate:(NSDate *)object];
        //NSLog(@"date: %@", [dateFormatter stringFromDate:(NSDate *)object]);
        return cell;
    }
    
    // Handle Message object.
    cell = [tableView dequeueReusableCellWithIdentifier:kMessageCell];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kMessageCell] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Create message background image view
        msgBackground = [[UIImageView alloc] init];
        msgBackground.clearsContextBeforeDrawing = NO;
        msgBackground.tag = BACKGROUND_TAG;
        msgBackground.backgroundColor = CHAT_BACKGROUND_COLOR; // clearColor slows performance
        [cell.contentView addSubview:msgBackground];
        [msgBackground release];
        
        // Create message text label
        msgText = [[UILabel alloc] init];
        msgText.clearsContextBeforeDrawing = NO;
        msgText.tag = TEXT_TAG;
        msgText.backgroundColor = [UIColor clearColor];
        msgText.numberOfLines = 0;
        msgText.lineBreakMode = UILineBreakModeWordWrap;
        msgText.font = [UIFont systemFontOfSize:kMessageFontSize];
        [cell.contentView addSubview:msgText];
        [msgText release];
    } else {
        msgBackground = (UIImageView *)[cell.contentView viewWithTag:BACKGROUND_TAG];
        msgText = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
    }
    
    // Configure the cell to show the message in a bubble. Layout message cell & its subviews.
    CGSize size = [[(Chat *)object text] sizeWithFont:[UIFont systemFontOfSize:kMessageFontSize]
                                       constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap];
    UIImage *bubbleImage;
    if ( [[(Chat *)object inBound] isEqualToNumber:[NSNumber numberWithInt:0]]) { // right bubble
        CGFloat editWidth = self.chatContent.editing ? 32.0f : 0.0f;
        msgBackground.frame = CGRectMake(self.chatContent.frame.size.width-size.width-34.0f-editWidth,
                                         kMessageFontSize-13.0f, size.width+34.0f,
                                         size.height+12.0f);
        bubbleImage = self.greenballoon;
        msgText.frame = CGRectMake(self.chatContent.frame.size.width-size.width-22.0f-editWidth,
                                   kMessageFontSize-9.0f, size.width+5.0f, size.height);
        msgBackground.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        msgText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        // Uncomment for view layout debugging.
//        cell.contentView.backgroundColor = [UIColor blueColor];
    } else { // left bubble
        msgBackground.frame = CGRectMake(0.0f, kMessageFontSize-13.0f,
                                         size.width+34.0f, size.height+12.0f);
        bubbleImage = self.clearballoon;
        msgText.frame = CGRectMake(22.0f, kMessageFontSize-9.0f, size.width+5.0f, size.height);
        msgBackground.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        msgText.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    }
    msgBackground.image = bubbleImage;
    msgText.text = [(Chat *)object text];
  
    //Mayukh commented the following code out as we do not want to mark messages read.
    //Also note the bad access as object read and object text are all null
    
    // Mark message as read.
    // Let's instead do this (asynchronously) from loadView and iterate over all messages
    /*if (![(Chat *)object read]) { // not read, so save as read
        [(Chat *)object setRead:[NSNumber numberWithInt:1]]; //FIXME bad access here 
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error appropriately.
            [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];

        }
    }*/
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
    //return [[self.cellMap objectAtIndex:[indexPath row]] isKindOfClass:[Chat class]];
//    return [[chatContent cellForRowAtIndexPath:indexPath] reuseIdentifier] == kMessageCell;
}

// Override to support editing the table view.
/*- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSObject *object = [self.cellMap objectAtIndex:[indexPath row]];
        if ([object isKindOfClass:[NSData class]]) {
            return;
        }
        
//        NSLog(@"Delete %@", object);
        
        // Remove message from managed object context by index path.
        [self.managedObjectContext deleteObject:(Chat *)object];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            //  Handle the error appropriately.
            NSLog(@"Delete message error %@, %@", error, [error userInfo]);
        }
    }
}*/

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"height for row: %d", [indexPath row]);
    
    NSObject *object = [self.cellMap objectAtIndex:[indexPath row]];
    
    // Set SentDateCell height.
    if ([object isKindOfClass:[NSDate class]]) {
        return kSentDateFontSize + 7.0f;
    }
    
    // Set MessageCell height.
    CGSize size = [[(Chat *)object text] sizeWithFont:[UIFont systemFontOfSize:kMessageFontSize]
                                       constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap];
    return size.height + 17.0f;
}

/*- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) { // disable slide to delete
        return UITableViewCellEditingStyleDelete;
//        return 3; // used to work for check boxes
    }
    return UITableViewCellEditingStyleNone;
}*/

#pragma mark NSFetchedResultsController

- (void)fetchMessages {
    
    if (self.fetchedResultsController != nil) {
        return;
    }
    
    // Create and configure a fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %d", self.userId];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:20];
    
    // Create the sort descriptors array.
    NSSortDescriptor *tsDesc = [[NSSortDescriptor alloc] initWithKey:@"sentDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:tsDesc, nil];
    [tsDesc release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    
    // Create and initialize the fetchedResultsController.
    self.fetchedResultsController = [[[NSFetchedResultsController alloc]
                                initWithFetchRequest:fetchRequest
                                managedObjectContext:self.managedObjectContext
                                sectionNameKeyPath:nil /* one section */ cacheName:nil/*@"Chat"*/] autorelease];
    [fetchRequest release];
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle the error appropriately.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];
        exit(-1);
    }
}    

#pragma mark NSFetchedResultsControllerDelegate

// // beginUpdates & endUpdates cause the cells to get mixed up when scrolling aggressively.
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [chatContent beginUpdates];
//}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSArray *indexPaths;
    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            NSUInteger cellCount = [self.cellMap count];
            
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:cellCount inSection:0];
            
            if ([self addMessage:anObject] == 1) {
                indexPaths = [[NSArray alloc] initWithObjects:firstIndexPath, nil];
            } else { 
                indexPaths = [[NSArray alloc] initWithObjects:firstIndexPath,
                              [NSIndexPath indexPathForRow:cellCount+1 inSection:0], nil];
            }
            
            [self.chatContent insertRowsAtIndexPaths:indexPaths
                               withRowAnimation:UITableViewRowAnimationNone];
            [indexPaths release];
            [self scrollToBottomAnimated:YES];
            break;
        }
        case NSFetchedResultsChangeDelete: 
            break;
            /*{
            NSUInteger objectIndex = [self.cellMap indexOfObjectIdenticalTo:anObject];
            NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow:objectIndex inSection:0];
            
            if ([self removeMessageAtIndex:objectIndex] == 1) {
                indexPaths = [[NSArray alloc] initWithObjects:objectIndexPath, nil];
            } else { 
                indexPaths = [[NSArray alloc] initWithObjects:objectIndexPath,
                              [NSIndexPath indexPathForRow:objectIndex-1 inSection:0], nil];
            }
            
            [self.chatContent deleteRowsAtIndexPaths:indexPaths
                               withRowAnimation:UITableViewRowAnimationNone];
            [indexPaths release];
            break;
        }*/
    }
}

#pragma mark - PageScrollerHeaderInfo

- (NSString*) userName
{

    return self.chatUserName;
}


/*- (NSString*) pageSubtitle
{
    return [NSString stringWithFormat:@"%@ - %@", [_days objectAtIndex:0], [_days lastObject]];
}*/

// // beginUpdates & endUpdates cause the cells to get mixed up when scrolling aggressively.
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [chatContent endUpdates];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
    self.navigationItem.leftBarButtonItem.enabled = YES;

    if (buttonIndex == 0) {
        [self stopRetryingSendingMessage];
    }
    else if (buttonIndex == 1)
    {
        [self sendMessage];
    }
        
}

- (void) stopRetryingSendingMessage
{
    [self clearChatInput];
    
    [self scrollToBottomAnimated:NO]; // must come after RESET_CHAT_BAR_HEIGHT above
    [self.chatInput resignFirstResponder];
    
}

- (void) sendMessageFailed: (NSString*) status
{
    [self.spinner hide:YES];
   
    if ([@"fail" isEqualToString:status]) {
        [ErrorHandler displayString:@"Failed to send message. Check internet connection." forDelegate:self otherButton:@"Retry"];
    }
    else if ([@"not authenticated" isEqualToString:status])
    {
         [ErrorHandler displayString:@"Failed to send message. Invalid login info." forDelegate:self otherButton:@"Retry"];
    }
    else
    {
         [ErrorHandler displayString:@"Failed to send message. Please try again later." forDelegate:self otherButton:@"Retry"];
    }
}

- (void)sendMessageDidComplete
{
    NSString *rightTrimmedMessage =
    [chatInput.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    
    // Create new message and save to Core Data.
    Chat *newMessage = (Chat *)[NSEntityDescription
                                insertNewObjectForEntityForName:@"Chat"
                                inManagedObjectContext:self.managedObjectContext];
    newMessage.text = rightTrimmedMessage;
    NSNumber *num = [NSNumber numberWithInt:self.userId];
    newMessage.userId = num;
  
    NSDate *now = [[NSDate alloc] init]; 
 
    newMessage.sentDate = now;  
    newMessage.userName = self.userName;
    newMessage.read = [NSNumber numberWithInt:1];
    newMessage.inBound = [NSNumber numberWithInt:0];
    [now release];now = nil;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
        exit(-1);
    }
    
    [self clearChatInput];
    
    [self scrollToBottomAnimated:NO]; // must come after RESET_CHAT_BAR_HEIGHT above
    
    // Play sound or buzz, depending on user settings.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL sound = [prefs boolForKey:@"sound"];
    
    if (sound) {
        NSString *sendPath = [[NSBundle mainBundle] pathForResource:@"basicsound" ofType:@"wav"];
        CFURLRef baseURL = (CFURLRef)[NSURL fileURLWithPath:sendPath];
        AudioServicesCreateSystemSoundID(baseURL, &receiveMessageSound);
        AudioServicesPlaySystemSound(receiveMessageSound);
        
    }
    [self.chatInput resignFirstResponder];
    
    //    AudioServicesPlayAlertSound(receiveMessageSound); // use for receiveMessage (sound & vibrate)
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // explicit vibrate
    
    [self.delegate resetTimer:YES];
    [self.spinner hide:YES];   
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
}

- (void)backgroundTap:(id)sender { 
    
    if ([self.chatInput isFirstResponder]) {
        [self clearChatInput];
        [self scrollToBottomAnimated:NO];
        [self resetSendButton];
        [self.chatInput resignFirstResponder];   
    }
 
}


@end
