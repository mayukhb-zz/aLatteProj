//
//  ChatPageViewController.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 7/29/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ChatPageViewController.h"
#import "MyPageData.h"
#import "ChatViewController.h"
#import "Chat.h"
#import "Revelations.h"
#import "Common.h"
#import "Constants.h"
#import "CustomBadge.h"
#import "ViewHandler.h"
#import "ErrorHandler.h"

@interface ChatPageViewController(internal)
- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index;
- (void) addPagesAtIndexSet : (NSIndexSet *) indexSet;
- (void) removePagesAtIndexSet : (NSIndexSet *) indexSet;
- (void) reloadPagesAtIndexSet : (NSIndexSet*) indexSet; 

@end

@implementation ChatPageViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize usersArray, userIds, numPages, activeUserId, activeUserName, selectedUserId;
@synthesize deleteChatButton;
@synthesize request, timer, reloadFlag, revealByDefault, requestPollMsg;
@synthesize revealButton;
@synthesize revealAnimatedButton;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Populate the shared instance tabBarHeight and navBarHeight - Such that chatViewController can access it if needed.
    Common *com = [Common sharedInstance];
    
    [com setTabBarHeight:self.tabBarController.tabBar.frame.size.height];
    [com setNavBarHeight:self.navigationController.navigationBar.frame.size.height];
     
    [self loadChatPageView];

    //Create deleteChatButton (Red cross Icon)
    /*[self addDeleteButton];
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    UIView *view = [[UIView alloc] initWithFrame:pageScrollView.frame];
    view.transform = CGAffineTransformMakeScale(0.6,0.6);
    if ([_myPageDataArray count] > 0 && self.activeUserId == nil) {
        deleteChatButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.origin.x - 10.0f, view.frame.origin.y- 10.0f, 20.0f, 20.0f)];
        [deleteChatButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        deleteChatButton.tag = 2;
        [deleteChatButton addTarget:self action:@selector(didClickRemovePage)    forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:deleteChatButton];
        [deleteChatButton release]; deleteChatButton = nil;
        
    }
    [view release]; view = nil;
 */
    //Add info view if no chat window exists
    if ([_myPageDataArray count] == 0) {
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,130,320,60)];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.tag = 3;
        infoLabel.text = @"Find someone near to start chatting";
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.textColor = [UIColor darkGrayColor];
        infoLabel.font = [UIFont fontWithName:@"BradleyHandITCTT-Bold" size:24];
        infoLabel.numberOfLines = 2;
        [self.view addSubview:infoLabel];
        [infoLabel release]; infoLabel = nil;
        
    }
 
    //Add the toolbar buttons - Deck Button
    UIImage *image = [UIImage imageNamed:@"browse.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    button.titleLabel.font            = [UIFont systemFontOfSize: 12];
    button.titleLabel.lineBreakMode   = UILineBreakModeTailTruncation;
    button.titleLabel.shadowOffset    = CGSizeMake (1.0, 4.0);  
    button.titleLabel.enabled = YES;
    [button setTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]] forState:UIControlStateNormal];
    button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [button addTarget:self action:@selector(didClickBrowsePages)    forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deckButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = deckButton;
    [deckButton release];
    

    if (self.activeUserId != nil) {
        //Set selected userid to the activeuserid. This will be used to write to revelations table.
        self.selectedUserId = self.activeUserId;
    }
    else if ([_myPageDataArray count] > 0){
         [_myPageScrollView selectPageAtIndex:0 animated:YES];
    }
  
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.fetchedResultsController = nil;
    self.revealButton = nil;
    self.revealAnimatedButton = nil;
    self.deleteChatButton = nil;

}

- (void) viewWillAppear:(BOOL)animated
{
    
    [self setupRevealButton];
    if(self.reloadFlag)
    {
        [self reloadChatPageView];
    }
    


    NSInteger selectedPageIndex = [_myPageScrollView indexForSelectedPage];
    if (selectedPageIndex != NSNotFound) {
        MyPageData *pageData = [_myPageDataArray objectAtIndex:selectedPageIndex];
        if (pageData.badgeNumber > 0 && _myPageScrollView.viewMode == HGPageScrollViewModePage) {
            
            int newBadgeValue = [self.navigationController.tabBarItem.badgeValue intValue] - [pageData.badgeNumber intValue];
            if (newBadgeValue > 0) {
                self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newBadgeValue ];
                
            }
            else{
                self.navigationController.tabBarItem.badgeValue = nil;
            }
            pageData.badgeNumber = [NSNumber numberWithInt:0];
            [(ChatViewController*)pageData.viewController setBadgeNumber:0];
        }    
    }
   
    
    
    if (self.activeUserId == nil) {
        return;
    }
    //This flag says yes if there is an active user id whose chat history already exists. 
    BOOL activeChatHistory = NO;
    int i=0;
    
    for (MyPageData *pdata in _myPageDataArray) {
        if ([self.activeUserId isEqualToNumber:pdata.userId]) {
            activeChatHistory = YES;
            selectedIndex = i;
            break;
        }
        i++;
    } 
    
    if (activeChatHistory == NO) {
        [self didClickAddPage];
    }
    else{
        //bugfix-v1 start
        if (_myPageScrollView.viewMode == HGPageScrollViewModePage ) {
            [_myPageScrollView deselectPageAnimated:NO];
        }
        if ((selectedIndex == [_myPageDataArray count] - 1) && ([_myPageDataArray count] > 2)) {
            if([_myPageScrollView indexForSelectedPage] != 0 && [_myPageScrollView indexForSelectedPage] != selectedIndex){
                [_myPageScrollView scrollToPageAtIndex:selectedIndex animated:NO];
            }
            
        }
        //bugfix-v1 end
        [_myPageScrollView selectPageAtIndex:selectedIndex animated:YES];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        int tutorial = [prefs integerForKey:@"tutorial"] ;
        BOOL revealButtonEnabledFlag = [self revleaLButtonEnabledFlag:self.selectedUserId];
        
        if (tutorial == 2 || (tutorial < 2 && !revealButtonEnabledFlag)) {
            self.navigationItem.rightBarButtonItem = self.revealButton;
        }
        else
        {
            self.navigationItem.rightBarButtonItem = self.revealAnimatedButton;
            for (UIView *subView in [self.revealAnimatedButton.customView subviews]) {
                //Only remove the subview with tag 
                if ([subView isMemberOfClass:[UIImageView class]]) {
                    [(UIImageView*)subView startAnimating];
                    break;
                }
                
                
            }
        }
        [self setRevealState];
            
    }
   
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.activeUserId = nil;
}

#pragma mark - refresh/reload methods

- (void) setupRevealButton
{
    //Display reveal button only if the user has indicated so in Settings. Derive the revealByDefault flag here.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.revealByDefault = [prefs boolForKey:@"revealByDefault"];
    if (!self.revealByDefault && !self.revealButton) {
        
        //[prefs setInteger:0 forKey:@"tutorial"]; [prefs synchronize]; 
        int tutorial = [prefs integerForKey:@"tutorial"] ;
        UIBarButtonItem *reveal = [[UIBarButtonItem alloc] initWithTitle:@"Reveal" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickRevealButton)];
        self.revealButton = reveal;
        [reveal release]; reveal = nil;
        
        if (tutorial != 2) 
        {
            NSArray *myImages = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal1.png"],
                                 [UIImage imageNamed:@"lreveal2.png"],
                                 [UIImage imageNamed:@"lreveal3.png"],
                                 [UIImage imageNamed:@"lreveal4.png"],
                                 [UIImage imageNamed:@"lreveal5.png"],
                                 [UIImage imageNamed:@"lreveal6.png"],
                                 [UIImage imageNamed:@"lreveal7.png"],
                                 [UIImage imageNamed:@"lreveal8.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 [UIImage imageNamed:@"lreveal0.png"],
                                 nil];
            
            UIImageView *myAnimatedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 59, 30)];
            myAnimatedView.animationImages = myImages;
            UIButton *revealButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
            revealButton2.bounds = myAnimatedView.bounds;
            
            myAnimatedView.animationDuration = 1; // seconds
            myAnimatedView.animationRepeatCount = 0; // 0 = loops forever
            [revealButton2 addSubview:myAnimatedView];
            [revealButton2 addTarget:self action:@selector(didClickRevealButton) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *revealAnimated = [[UIBarButtonItem alloc] initWithCustomView:revealButton2];
            [myAnimatedView release]; myAnimatedView = nil;
            self.revealAnimatedButton = revealAnimated;
            [revealAnimated release]; revealAnimated = nil;
            BOOL revealButtonEnabledFlag = [self revleaLButtonEnabledFlag:self.selectedUserId];
            if ([_myPageDataArray count] > 0 && _myPageScrollView.viewMode == HGPageScrollViewModePage){
                if (!revealButtonEnabledFlag) {
                    self.navigationItem.rightBarButtonItem = self.revealButton;
                    [self setRevealState];
                }
                else
                {
                    self.navigationItem.rightBarButtonItem = self.revealAnimatedButton;
                    for (UIView *subView in [self.revealAnimatedButton.customView subviews]) {
                        //Only remove the subview with tag 
                        if ([subView isMemberOfClass:[UIImageView class]]) {
                            [(UIImageView*)subView startAnimating];
                            break;
                        }
                        
                        
                    }
                }
                
            }
            
        }
        else 
        {
            if ([_myPageDataArray count] > 0 && _myPageScrollView.viewMode == HGPageScrollViewModePage){
                self.navigationItem.rightBarButtonItem = self.revealButton;
                [self setRevealState];
            }
        }
    }
    else if(self.revealByDefault)
    {
        self.revealButton = nil;
        self.revealAnimatedButton = nil;
        self.navigationItem.rightBarButtonItem = nil;

    }
}

- (void) loadChatPageView
{
    
    //Query Core Data to figure out the number of pages to display which is equal
    //to number of users. Also get the username and userid
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    // Create the sort descriptors array.
    NSSortDescriptor *tsDesc = [[NSSortDescriptor alloc] initWithKey:@"sentDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:tsDesc, nil];
    [tsDesc release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    
    // Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
	if (mutableFetchResults == nil) {
		// Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];

        exit(-1);  // Fail	
    }
    
	//This is to account for the page to be selected in the chat page view mode
    selectedIndex = 0;
    //This is to store the value of total number of new messages when the view loads first
    //int chatTabBadgeNumber = 0;
    
    self.userIds = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
    
    //Initialize users array
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:3];
    self.usersArray = tempArray;
    [tempArray release]; tempArray = nil;
    
    NSMutableDictionary *readCount = [[NSMutableDictionary alloc] init];
    int readMessage;
    for (NSManagedObject *obj in mutableFetchResults) {
        
        readMessage = [[(Chat*)obj read] intValue];
        readMessage = (readMessage == 0)? 1:0; 
        
        //chatTabBadgeNumber += readMessage;
        readMessage +=  [[readCount valueForKey:[NSString stringWithFormat:@"%@", [(Chat*)obj userId]]] intValue];
        [readCount setValue:[NSNumber numberWithInt:readMessage] forKey:[NSString stringWithFormat:@"%@", [(Chat*)obj userId]]];
        
        if ([(Chat*)obj userId] != nil) {
            if (![self.userIds containsObject:[(Chat*)obj userId]]) {
                [self.userIds addObject:[(Chat*)obj userId]];
                [self.usersArray addObject:obj];
                
            }
            
		}
    }
   
    [mutableFetchResults release]; mutableFetchResults = nil;
    [fetchRequest release]; fetchRequest = nil;
    self.numPages = [self.usersArray count];
    
    _myPageDataArray = [[NSMutableArray alloc] initWithCapacity : self.numPages];
    
    for (int i=0; i < self.numPages; i++) {
        ChatViewController *myViewController = [[[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil] autorelease];
        myViewController.delegate = self;
        myViewController.userId = [[(Chat*)[self.usersArray objectAtIndex:i] userId] intValue];
        myViewController.chatUserName = [(Chat*)[self.usersArray objectAtIndex:i] userName];
        myViewController.badgeNumber = [readCount valueForKey:[NSString stringWithFormat:@"%@", [(Chat*)[self.usersArray objectAtIndex:i] userId]]];
        myViewController.managedObjectContext = self.managedObjectContext;
        MyPageData *pageData = [[[MyPageData alloc] init] autorelease];
        pageData.viewController = myViewController;
        pageData.userName = [(Chat*)[self.usersArray objectAtIndex:i] userName];
        pageData.userId = [(Chat*)[self.usersArray objectAtIndex:i] userId];
        pageData.badgeNumber = [readCount valueForKey:[NSString stringWithFormat:@"%@", [(Chat*)[self.usersArray objectAtIndex:i] userId]]];
        
        [_myPageDataArray addObject:pageData];
        
        if ([self.activeUserId isEqualToNumber:[(Chat*)[self.usersArray objectAtIndex:i] userId]]) {
            selectedIndex = i;
        }
        
	}
    [readCount release]; readCount = nil;
    
    //Set the badge number for the Chat tab
    /*if (chatTabBadgeNumber > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", chatTabBadgeNumber];
    }*/
    
	// now that we have the data, initialize the page scroll view
	_myPageScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] objectAtIndex:0];
	[self.view addSubview:_myPageScrollView];
    
}

- (void) reloadChatPageView
{
    BOOL deckViewMode = YES;
    
    [self removeDeleteButton];
    [self removeInfoLabel];
    
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    selectedIndex = [pageScrollView indexForSelectedPage];
    self.activeUserId = self.selectedUserId;
    
    //Store the view mode such that after reloading, the original view mode is restored
    if(pageScrollView.viewMode == HGPageScrollViewModePage){  
		deckViewMode = NO;
	}
    [_myPageDataArray removeAllObjects];
    
    //Remove all subviews first
    [ViewHandler removeSubviewsFrom:self.view];
    
    [self loadChatPageView];
   
    // update deckButton
    UIBarButtonItem *deckButton = self.navigationItem.leftBarButtonItem;
    [(UIButton*)deckButton.customView setTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]] forState:UIControlStateNormal]; 
 
    if (!deckViewMode) {
        self.reloadFlag = NO;
    }
    
   /* if(selectedIndex == NSIntegerMax)
    {
        selectedIndex = 0;
    }*/
    [_myPageScrollView selectPageAtIndex:selectedIndex animated:NO];
    
    if (deckViewMode) {
        [_myPageScrollView deselectPageAnimated:NO];
        
    }
    self.reloadFlag = NO;
}



#pragma mark -
#pragma mark HGPageScrollViewDataSource


- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView;   // Default is 0 if not implemented
{
	return [_myPageDataArray count];
}

- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{    
    
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    assert(pageData.viewController != nil); 
    return (HGPageView*)pageData.viewController.view; 
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index;  
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return [headerInfo userName];
    
}

/*- (NSString *)pageScrollView:(HGPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index;  
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return [headerInfo userLocationTitle];
    
}*/
- (NSNumber *)pageScrollView:(HGPageScrollView *)scrollView badgeNumberForPageAtIndex:(NSInteger)index;  
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return [headerInfo badgeNumber];
    
}

- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    assert(pageData.viewController != nil);
    return pageData.viewController;
    
}

#pragma mark - 
#pragma mark HGPageScrollViewDelegate

- (void) pageScrollViewWillBeginDragging:(HGPageScrollView *)scrollView
{
    [self removeDeleteButton];
}
- (void)pageScrollViewDidEndDecelerating:(HGPageScrollView *)scrollView
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    NSInteger currentIndex = [pageScrollView indexForSelectedPage];
    if (currentIndex != NSNotFound) {
        self.selectedUserId = [(MyPageData*)[_myPageDataArray objectAtIndex:currentIndex] userId];
    }
    else {
        self.selectedUserId = nil;
    }
        
    //Create deleteChatButton (Red cross Icon)
    UIView *view = [[UIView alloc] initWithFrame:pageScrollView.frame];
    view.transform = CGAffineTransformMakeScale(0.6,0.6);

    deleteChatButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.origin.x - 10.0f, view.frame.origin.y- 10.0f, 20.0f, 20.0f)];
    [deleteChatButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteChatButton addTarget:self action:@selector(didClickRemovePage)    forControlEvents:UIControlEventTouchUpInside];
    deleteChatButton.tag = 2;
    [self.view addSubview:deleteChatButton];
    [view release]; view = nil;
    [deleteChatButton release]; deleteChatButton = nil;
    
}

- (void)pageScrollView:(HGPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
{
    [self removeDeleteButton];
    
}

- (void) pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    
    if ([pageData badgeNumber] > 0 && !self.reloadFlag) {
       
        //Call core data to set chat messages read
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:managedObjectContext];
        
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userId = %@", pageData.userId]];
        // Execute the fetch -- create a mutable copy of the result.
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error
            [ErrorHandler displayString:@"Unexpected issue while retrieving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];

            exit(-1);  // Fail		
        }
        for (Chat *chat in mutableFetchResults) {
            chat.read = [NSNumber numberWithInt:1];
        }
        
        error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
            [ErrorHandler displayString:@"Unexpected issue while saving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];

            exit(-1);  // Fail
        }	
        
        [mutableFetchResults release]; mutableFetchResults = nil;
        [fetchRequest release]; fetchRequest = nil;
        
        int newBadgeValue = [self.navigationController.tabBarItem.badgeValue intValue] - [pageData.badgeNumber intValue];
        if (newBadgeValue > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newBadgeValue ];
            
        }
        else{
            self.navigationController.tabBarItem.badgeValue = nil;
        }
        pageData.badgeNumber = [NSNumber numberWithInt:0];

    }
    if (pageData.viewController) {
        if (!self.reloadFlag) {
            [(ChatViewController*)pageData.viewController setBadgeNumber:[NSNumber numberWithInt:0]] ;
        }
        self.selectedUserId = pageData.userId;
        self.navigationItem.title = pageData.userName;
        BOOL revealButtonEnabledFlag = [self revleaLButtonEnabledFlag:self.selectedUserId];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        int tutorial = [prefs integerForKey:@"tutorial"] ;
        if (tutorial == 2 || (tutorial < 2 && !revealButtonEnabledFlag)) {
            self.navigationItem.rightBarButtonItem = self.revealButton;
        }
        else
        {
            self.navigationItem.rightBarButtonItem = self.revealAnimatedButton;
            for (UIView *subView in [self.revealAnimatedButton.customView subviews]) {
                //Only remove the subview with tag 
                if ([subView isMemberOfClass:[UIImageView class]]) {
                    [(UIImageView*)subView startAnimating];
                    break;
                }
                
                
            }
            
        }
        [self setRevealState];
         
    }
}

- (void)pageScrollView:(HGPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = @"Chat";
    // Now the page scroller is in DECK mode. 
    
    [self addDeleteButton];
    
    // Complete an add/remove pages request if one is pending
    if (indexesToDelete) {
        [self removePagesAtIndexSet:indexesToDelete];
        [indexesToDelete release];
        indexesToDelete = nil;
    }
    if (indexesToInsert) {
        [self addPagesAtIndexSet:indexesToInsert];
        [indexesToInsert release];
        indexesToInsert = nil;
    }
}



#pragma mark - toolbar Actions

- (void) didClickBrowsePages
{
    if ([_myPageDataArray count] == 0) {
        return;
    }

    [self removeDeleteButton];
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];

	if(pageScrollView.viewMode == HGPageScrollViewModePage){ 
        if ([self.userIds count] != [_myPageDataArray count]) {
            [self reloadChatPageView];
            [self didClickBrowsePages];
            return;
        }
        
        //return;
		[pageScrollView deselectPageAnimated:YES];
        

	}
	else {
		[pageScrollView selectPageAtIndex:[pageScrollView indexForSelectedPage] animated:YES];
	}
}

- (void)didClickReveal{
       
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.request clearDelegatesAndCancel]; 
    NSNumber* userId = [[NSNumber alloc ] initWithInt:[prefs integerForKey:@"userId"]];
    
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setValue:userId forKey:@"revealer_userid"];
    [userId release]; userId = nil;
    [params setValue:self.selectedUserId forKey:@"revealed_to_userid"];
    [params setValue:@"reveal" forKey:@"script"];
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_REVELATION;
    [self.request setPostValues:params];
    
}

- (void) didClickRevealButton
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int tutorial = [prefs integerForKey:@"tutorial"] ;
    
    if (tutorial != 2) {
       
        RevealTutorialViewController *tutorialViewController = [[RevealTutorialViewController alloc] initWithNibName:@"RevealTutorialViewController" bundle:nil fromDatesTable:NO];
        tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        tutorialViewController.revealTutorialDelegate = self;
        [self.navigationController presentModalViewController:tutorialViewController animated:YES]; 
        [tutorialViewController release];
        [prefs setInteger:tutorial+1 forKey:@"tutorial"];
        [prefs synchronize];
        self.navigationItem.rightBarButtonItem = self.revealButton;
        [self setRevealState];
        return;
    }
    
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reveal my pics", nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	actionSheet.tag = 1;
	[actionSheet showInView:self.parentViewController.tabBarController.view];
	
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self didClickReveal];
		
	} 
}



- (void) revealFinished
{
    // Create new revelation record and save to Core Data.
    Revelations *newReveal = (Revelations *)[NSEntityDescription
                                insertNewObjectForEntityForName:@"Revelations"
                                inManagedObjectContext:self.managedObjectContext];
   
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber* userId = [[NSNumber alloc ] initWithInt:[prefs integerForKey:@"userId"]];
    
    newReveal.revealerUserId = userId ;
    newReveal.revealedToUserId = self.selectedUserId;
    [userId release]; userId = nil;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];

        exit(-1);  // If save fails, do not want to crash application	
    }
    
    // update reveal button
    assert(self.navigationItem.rightBarButtonItem != nil);
    [self.navigationItem.rightBarButtonItem setTitle:@"Revealed"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
   
}

- (void) didClickAddPage
{
    [self removeDeleteButton];
    [self removeInfoLabel];
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    // create an index set of the pages we wish to add
    [indexesToInsert release];
    
    // inserting one page at the current index 
    NSInteger selectedPageIndex = [pageScrollView indexForSelectedPage];
    //NSInteger insertionPageIndex = [pageScrollView numberOfPages];
    indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:(selectedPageIndex == NSNotFound)? 0 : selectedPageIndex];
    //indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:insertionPageIndex];
    
    // we can only insert pages in DECK mode
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [self didClickBrowsePages];
    }
    else{
        [self addPagesAtIndexSet:indexesToInsert];
        [indexesToInsert release];
        indexesToInsert = nil;
    }
    
}

- (void) addPagesAtIndexSet : (NSIndexSet *) indexSet 
{
    // create new pages and add them to the data set 
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        ChatViewController *myViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        myViewController.delegate = self;
        myViewController.userId = [self.activeUserId intValue];
        if (![self.userIds containsObject:self.activeUserId]) {
            [self.userIds addObject:self.activeUserId];
        }
        myViewController.chatUserName = self.activeUserName;
        myViewController.managedObjectContext = self.managedObjectContext;
        MyPageData *pageData = [[MyPageData alloc] init];
        pageData.viewController = myViewController;
        pageData.userName = self.activeUserName;
        pageData.userId = self.activeUserId;
       
        [_myPageDataArray insertObject:pageData atIndex:idx];
        [myViewController release]; myViewController = nil;
        [pageData release]; pageData =nil;
        
        
    }];
    
    // update the page scroller 
    [self removeDeleteButton];
    
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    [pageScrollView insertPagesAtIndexes:indexSet animated:YES];
    
    NSInteger currentIndex = [pageScrollView indexForSelectedPage];
    if (currentIndex != NSNotFound) {
        self.selectedUserId = [(MyPageData*)[_myPageDataArray objectAtIndex:currentIndex] userId];
        
    }
    else {
        self.selectedUserId = nil;
    }
    

    //Create deleteChatButton (Red cross Icon)
    //[self addDeleteButton];
    //[self performSelector:@selector(addDeleteButton) withObject:nil afterDelay:0.4];
    
    // update deckButton
    UIBarButtonItem *deckButton = self.navigationItem.leftBarButtonItem;
    [(UIButton*)deckButton.customView setTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]] forState:UIControlStateNormal]; 
    
    //Move the page into Page mode
    [self performSelector:@selector(didClickBrowsePages) withObject:nil afterDelay:0.4];
     
}

- (void) didClickRemovePage 
{
    [self removeDeleteButton];
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    //HGPageScrollView *pageScrollView = [[self.view subviews] objectAtIndex:[[self.view subviews] count]-2];
    
    // create an index set of the pages we wish to delete
    [indexesToDelete release];
    
    // deleting the page at the current index
    indexesToDelete = [[NSMutableIndexSet alloc] initWithIndex:[pageScrollView indexForSelectedPage]];
    MyPageData *pageData = [_myPageDataArray objectAtIndex:[indexesToDelete firstIndex]];
    
    int newBadgeValue = [self.navigationController.tabBarItem.badgeValue intValue] - [pageData.badgeNumber intValue];
    if (newBadgeValue > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newBadgeValue ];
        
    }
    else{
        self.navigationController.tabBarItem.badgeValue = nil;
        
    }
    
    // we can only delete pages in DECK mode
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [pageScrollView deselectPageAnimated:YES];
    }
    else{
        [self removePagesAtIndexSet:indexesToDelete];
        [indexesToDelete release];
        indexesToDelete = nil;
    }
    
}


- (void) removePagesAtIndexSet : (NSIndexSet *) indexSet 
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
  
    //Remove Chat messages from CoreData
    MyPageData *pageData = [_myPageDataArray objectAtIndex:[indexSet firstIndex]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userId = %@", pageData.userId]];
    // Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];

		exit(-1);  // Fail		
	}
    for (Chat *chat in mutableFetchResults) {
        [self.managedObjectContext deleteObject:(Chat*)chat];
        
    }
     
     error = nil;
     if (![self.managedObjectContext save:&error]) {
         // Handle the error.
         [ErrorHandler displayString:@"Unexpected issue while saving data. A Latte is going to shut down. Please try restarting." forDelegate:nil];

         exit(-1);  // Fail
     }	
    
    [mutableFetchResults release]; mutableFetchResults = nil;
    [fetchRequest release]; fetchRequest = nil;
    
    
    // remove from the data set
    [self.userIds removeObject:pageData.userId];
    [_myPageDataArray removeObjectsAtIndexes:indexSet];
    
    // update the page scroller
    [pageScrollView deletePagesAtIndexes:indexSet animated:YES]; 
    
    //update selecteduserid
    NSInteger currentIndex = [pageScrollView indexForSelectedPage];
    if (currentIndex != NSNotFound) {
        self.selectedUserId = [(MyPageData*)[_myPageDataArray objectAtIndex:currentIndex] userId];
    }
    else {
        self.selectedUserId = nil;
    }
    
    if ([_myPageDataArray count] != 0) {
       
        [self performSelector:@selector(addDeleteButton) withObject:nil afterDelay:0.4];
    }
    else
    {
        //Add info view if no chat window exists
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,130,320,60)];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.tag = 3;
        infoLabel.text = @"Find someone near to start chatting";
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.textColor = [UIColor darkGrayColor];
        infoLabel.font = [UIFont fontWithName:@"BradleyHandITCTT-Bold" size:24];
        infoLabel.numberOfLines = 2;
        [self.view addSubview:infoLabel];
        [infoLabel release]; infoLabel = nil;          
        
    }
    
    // update deckButton
    UIBarButtonItem *deckButton = self.navigationItem.leftBarButtonItem;
    [(UIButton*)deckButton.customView setTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]] forState:UIControlStateNormal]; 
    
}

- (void) reloadPagesAtIndexSet : (NSIndexSet*) indexSet 
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    [pageScrollView reloadPagesAtIndexes:indexesToReload];
}

- (void) addDeleteButton
{
    //Create deleteChatButton (Red cross Icon)
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    UIView *view = [[UIView alloc] initWithFrame:pageScrollView.frame];
    view.transform = CGAffineTransformMakeScale(0.6,0.6);
    
    deleteChatButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.origin.x - 10.0f, view.frame.origin.y- 10.0f, 20.0f, 20.0f)];
    [deleteChatButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    deleteChatButton.tag = 2;
    [deleteChatButton addTarget:self action:@selector(didClickRemovePage)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteChatButton];
    [view release]; view = nil;
    [deleteChatButton release]; deleteChatButton = nil;
    
}

- (void) removeDeleteButton
{
    [ViewHandler removeSubviewsFrom:self.view withTag:2];   
}

- (void) removeInfoLabel
{
    [ViewHandler removeSubviewsFrom:self.view withTag:3];
}

- (void) pollForNewMessages
{
    // Retrieve appuserid and messageid from NSUSerDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *appUserId = [[NSNumber alloc ] initWithInt:[prefs integerForKey:@"userId"]];
    NSNumber *messageId = [[NSNumber alloc ] initWithInt:[prefs integerForKey:@"messageId"]];
    NSNumber *messageStartDate = [prefs objectForKey:@"messageStartDate"];
   /* if ([self.request isExecuting]) {
        [self resetTimer:YES];
        return;
        
    }*/
    [self.requestPollMsg clearDelegatesAndCancel]; 
    self.requestPollMsg = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:NO] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:appUserId forKey:@"userid"];
    [params setValue:messageId forKey:@"messageid"];
    if ([messageId isEqualToNumber:[NSNumber numberWithInt:0]] && ![messageStartDate isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        [params setValue:messageStartDate forKey:@"messagestartdate"];
    }
    [params setValue:@"read" forKey:@"mode"];
    [params setValue:@"messages" forKey:@"script"];
    
    self.requestPollMsg.customHTTPDelegate = self;
    self.requestPollMsg.tag = REQUEST_FOR_POLLING;
    [self.requestPollMsg setPostValues:params];

    [appUserId release]; appUserId = nil;
    [messageId release]; messageId = nil;
}

#pragma mark - HTTPRequest asynchronous methods

- (void) doneLoadingNewMessages:(int)numNewMessages messageId:(NSArray *)messageIdArray userId:(NSArray *)useridArray username:(NSMutableArray *)userNameArray message:(NSMutableArray *)messageArray timestamp:(NSMutableArray *)timeStampArray
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //Date coming from server is in UTC/GMT. Need to convert to local timezone
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormat setTimeZone:gmt];
    
    self.reloadFlag = NO;
    int tabBadge = 0;
    
    
    //[pageData badgeNumber]
    
    for (int i=0; i<numNewMessages; i++) {
        
        // Create new message and save to Core Data.
        Chat *newMessage = (Chat *)[NSEntityDescription
                                    insertNewObjectForEntityForName:@"Chat"
                                    inManagedObjectContext:self.managedObjectContext];
        newMessage.text = [messageArray objectAtIndex:i];
        newMessage.userId = [f numberFromString:[useridArray objectAtIndex:i]];
        newMessage.userName = [userNameArray objectAtIndex:i];    
        newMessage.sentDate = [dateFormat dateFromString:[timeStampArray objectAtIndex:i]]; 
        newMessage.inBound = [NSNumber numberWithInt:1]; 
   
        if ([self.selectedUserId isEqualToNumber:newMessage.userId] && _myPageScrollView.viewMode == HGPageScrollViewModePage && self.tabBarController.selectedIndex == 2) {
            newMessage.read = [NSNumber numberWithInt:1];
        }
        else {
            newMessage.read = [NSNumber numberWithInt:0];
            [self incrementPageBadge:newMessage.userId];
            tabBadge++;
        }
        
        
        //Save the new messageid in NSUserDefaults
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:[[messageIdArray objectAtIndex:i] intValue] forKey:@"messageId"];
        [prefs synchronize];
        
        //Need to update userIds array if this is a chat message from a new user
        if (![self.userIds containsObject:newMessage.userId]) {
            [self.userIds addObject:newMessage.userId];
            
            if (_myPageScrollView.viewMode == HGPageScrollViewModeDeck) {
                self.reloadFlag = YES;
            }
            UIBarButtonItem *deckButton = self.navigationItem.leftBarButtonItem;
            [(UIButton*)deckButton.customView setTitle:[NSString stringWithFormat:@"%d", [self.userIds count]] forState:UIControlStateNormal]; 
            
        }
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error appropriately.
            [ErrorHandler displayString:@"Unexpected issue while saving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];
            
            exit(-1);
        }
        
        if(_myPageScrollView.viewMode == HGPageScrollViewModeDeck){
            //NSInteger index = [self indexOfCurrentPage:newMessage.userId];
            [_myPageScrollView reloadData];//FIXME v2 why reload everything and not just the commented code below? 
            /*NSLog(@"%d", index);
            if (index != NSNotFound) {
                [_myPageScrollView reloadPagesAtIndexes:[NSIndexSet indexSetWithIndex:index]];
                
            }*/
            
        }
    }
    [f release]; f= nil;
    [dateFormat release]; dateFormat = nil;
    
    if (tabBadge > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", tabBadge + [self.navigationController.tabBarItem.badgeValue intValue]];
        
    }
    
    if (self.tabBarController.selectedIndex == 2 && self.reloadFlag) {
        [self reloadChatPageView];
        [_myPageScrollView scrollToPageAtIndex:[self indexOfCurrentPage:self.selectedUserId] animated:NO];// bugfix-v1
    }
    
    //[_myPageScrollView scrollToPageAtIndex:[self indexOfCurrentPage:self.selectedUserId] animated:NO]; // bugfix-v1 Moved up inside the self.tabBarController.selectedIndex == 2 loop above
    //Restart the timer
    [self resetTimer:YES];
    
}

-(void) incrementPageBadge:(NSNumber *)newMsgUserId{
    
    NSInteger userIndex = [_myPageDataArray indexOfObjectPassingTest:
                           ^(id obj, NSUInteger idx, BOOL *stop) {
                               // Return true if obj has the date that you are looking for.
                               BOOL res;
                               if ([newMsgUserId isEqualToNumber:[(MyPageData*)obj userId]]) {
                                   res = YES;
                                   *stop = YES;
                               } else {
                                   res = NO;
                               }
                               return res;
                           }];
    if (userIndex != NSNotFound) {
        MyPageData *pageData = [_myPageDataArray objectAtIndex:userIndex];
        pageData.badgeNumber = [NSNumber numberWithInt:[pageData.badgeNumber intValue]+1];
        [(ChatViewController*)pageData.viewController setBadgeNumber:pageData.badgeNumber];
    }
    
}

-(NSInteger) indexOfCurrentPage:(NSNumber *)newMsgUserId{
    
    return  [_myPageDataArray indexOfObjectPassingTest:
                           ^(id obj, NSUInteger idx, BOOL *stop) {
                               // Return true if obj has the date that you are looking for.
                               BOOL res;
                               if ([newMsgUserId isEqualToNumber:[(MyPageData*)obj userId]]) {
                                   res = YES;
                                   *stop = YES;
                               } else {
                                   res = NO;
                               }
                               return res;
                           }];
   
    
}
#pragma mark - polling algorithm
- (void) stopPollingForMessages
{
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void) resetTimer: (BOOL) lastFireRetrivedMessage 
{
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    static double interval = 0;
    if (lastFireRetrivedMessage) {
        interval = 0;
    }
    interval += 5;
    if (interval > 60) {
        interval = 60;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(timerCallback)]];
	[invocation setTarget:self];
	[invocation setSelector:@selector(timerCallback)];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:interval invocation:invocation repeats:NO];

}

- (void)timerCallback {
   
    [self.timer invalidate]; 
	self.timer = nil;
	[self pollForNewMessages];
}

- (void) saveNewMessageCount 
{
    //Save the number of new messages in NSUserDefaults such that when the app starts next time, Chat tab badge can be
    //updated accordingly 
    int badgeNum = 0;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.navigationController.tabBarItem.badgeValue != nil) {
        badgeNum = [self.navigationController.tabBarItem.badgeValue intValue];
    }
    [prefs setInteger: badgeNum forKey:@"newMessageCount"];
    [prefs synchronize];

}

- (BOOL) revleaLButtonEnabledFlag: (NSNumber *) revealedToUserId
{
    BOOL returnFlag = YES;
    //Query Core Data to figure out if the user has revealed herself to the current chat user
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"Revelations" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"revealedToUserId = %@", revealedToUserId];
    [fetchRequest setPredicate:predicate];

    // Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
	if (mutableFetchResults == nil) {
		// Handle the error.
        [ErrorHandler displayString:@"Unexpected issue while retrieving data. aLatte is going to shut down. Please try restarting." forDelegate:nil];

        exit(-1);  // Fail	
    }
    for (NSManagedObject *obj in mutableFetchResults) {
        returnFlag = NO;
        break;
    }     
    [fetchRequest release]; fetchRequest = nil;
    [mutableFetchResults release]; mutableFetchResults = nil;
    return returnFlag;
}

- (void) setRevealState
{
    BOOL revealButtonEnabledFlag = [self revleaLButtonEnabledFlag:self.selectedUserId];
    if (revealButtonEnabledFlag) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Reveal"];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } 
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"Revealed"];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    
}

- (void)backgroundTap:(id)sender { 
    
}

- (void)dealloc
{
    [fetchedResultsController release]; fetchedResultsController = nil;
    [managedObjectContext release]; managedObjectContext = nil;
    [usersArray release]; usersArray = nil;
    [userIds release]; userIds = nil;
    [activeUserId release]; activeUserId = nil;
    [selectedUserId release]; selectedUserId = nil;
    [activeUserName release]; activeUserName = nil;
    [_myPageDataArray release];_myPageDataArray = nil;
    [deleteChatButton release]; deleteChatButton = nil;
    
    [self.request clearDelegatesAndCancel];
    self.request.customHTTPDelegate = nil;
    [request release]; request = nil;
    
    [self.requestPollMsg clearDelegatesAndCancel];
    self.requestPollMsg.customHTTPDelegate = nil;
    [requestPollMsg release]; requestPollMsg = nil;
    
    [timer release]; timer = nil;
    [revealButton release]; revealButton = nil;
    [revealAnimatedButton release]; revealAnimatedButton = nil;

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
