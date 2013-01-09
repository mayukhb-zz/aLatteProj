//
//  RevealTutorialViewController.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/18/12.
//  Copyright (c) 2012 Individual. All rights reserved.
//

#import "RevealTutorialViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation RevealTutorialViewController

@synthesize nextButton;
@synthesize revealButton;
@synthesize cancelButton;
@synthesize okButton;
@synthesize revealTutorialDelegate;
@synthesize showReveal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fromDatesTable:(BOOL)hideRevealButton 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.showReveal = !hideRevealButton;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *font = @"HelveticaNeue";
    int fontSize = 14;
    NSArray *fontFamilies = [UIFont familyNames];
   
    for (int i = 0; i < [fontFamilies count]; i++)
    {
        NSString *fontFamily = [fontFamilies objectAtIndex:i];
        if ([fontFamily isEqualToString:@"Bradley Hand"]) {
            NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
            if ([fontNames containsObject:@"BradleyHandITCTT-Bold"]) {
                font = @"BradleyHandITCTT-Bold";
                fontSize = 16;
                break;
            }
        }
        
    }
    //Bradley Hand
    //"BradleyHandITCTT-Bold"
                                                               
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL isFemaleFlag = [prefs boolForKey:@"userSex"];
    
    currentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 63)] autorelease];
    currentLabel.font = [UIFont fontWithName:font size:fontSize];
    currentLabel.textColor = [UIColor darkTextColor];
    currentLabel.backgroundColor = [UIColor clearColor];
    currentLabel.textAlignment = UITextAlignmentCenter;
    currentLabel.numberOfLines = 2;
    
    nextLabel = [[[UILabel alloc] initWithFrame:CGRectMake(340, 0, 280, 63)] autorelease];
    nextLabel.font = [UIFont fontWithName:@"BradleyHandITCTT-Bold" size:16];
    nextLabel.textColor = [UIColor darkTextColor];
    nextLabel.textAlignment = UITextAlignmentCenter;
    nextLabel.backgroundColor = [UIColor clearColor];
    
    if (isFemaleFlag) {
        if (self.showReveal) {
            currentPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_f_nonrevealed.png"]] autorelease];
            nextPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_f.png"]] autorelease];
            
            currentLabel.text = @"For your security men cannot see your pics unless you reveal yourself ..";
            nextLabel.text = @"After reveal";
        }else {
            currentPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_m_nonrevealed.png"]] autorelease];
            nextPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_m.png"]] autorelease];
            currentLabel.text = @"For security and because he chose to, you cannot see him unless he reveals";
            nextLabel.text = @"Start a chat and ask him to reveal";
        }    
    }
    else
    {
        if (self.showReveal) {
            currentPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_m_nonrevealed.png"]] autorelease];
            nextPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_m.png"]] autorelease];
            
            currentLabel.text = @"For your security women cannot see your pics unless you reveal yourself ..";
            nextLabel.text = @"After reveal";
        }else {
            currentPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_f_nonrevealed.png"]] autorelease];
            nextPage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_f.png"]] autorelease];
            currentLabel.text = @"For security and because she chose to, you cannot see her unless she reveals";
            nextLabel.text = @"Start a chat and ask her to reveal";
        }    

    }
    // Do any additional setup after loading the view from its nib.    
    
    currentPage.frame = CGRectMake(20, 0, 280, 330);
    currentPage.layer.shadowColor = [[UIColor blackColor] CGColor];	
	currentPage.layer.shadowOffset = CGSizeMake(8.0f, 12.0f);
	currentPage.layer.shadowOpacity = 0.3f;
    currentPage.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:currentPage.bounds];
    currentPage.layer.shadowPath = path.CGPath;	
    
    
    nextPage.frame = CGRectMake(340, 0, 280, 330);
    nextPage.layer.shadowColor = [[UIColor blackColor] CGColor];	
	nextPage.layer.shadowOffset = CGSizeMake(8.0f, 12.0f);
	nextPage.layer.shadowOpacity = 0.3f;
    nextPage.layer.masksToBounds = NO;
    path = [UIBezierPath bezierPathWithRect:nextPage.bounds];
    nextPage.layer.shadowPath = path.CGPath;	
    
	[scrollView addSubview:currentPage];
    [scrollView addSubview:currentLabel];
	[scrollView addSubview:nextPage];
    [scrollView addSubview:nextLabel];
    
	NSInteger widthCount = 2;

    scrollView.contentSize =
    CGSizeMake(
               scrollView.frame.size.width * widthCount,
               scrollView.frame.size.height);
	scrollView.contentOffset = CGPointMake(0, 0);
    
	pageControl.numberOfPages = 2;
	pageControl.currentPage = 0;
    
    CAGradientLayer *glayer = [CAGradientLayer layer];
	glayer.frame = self.view.bounds;
	UIColor *topColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]; //light blue-gray
	UIColor *bottomColor = [UIColor blackColor];//[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]; //dark blue-gray
	glayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
	[self.view.layer insertSublayer:glayer atIndex:0];

    self.revealButton.hidden = YES;
    self.cancelButton.hidden = YES;
	self.okButton.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.nextButton = nil;
    self.cancelButton = nil;
    self.revealButton = nil;
    self.okButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissTutorial:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


/*- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
	
	if (lowerNumber == currentPage.pageIndex)
	{
		if (upperNumber != nextPage.pageIndex)
		{
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	else if (upperNumber == currentPage.pageIndex)
	{
		if (lowerNumber != nextPage.pageIndex)
		{
			[self applyNewIndex:lowerNumber pageController:nextPage];
		}
	}
	else
	{
		if (lowerNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:upperNumber pageController:currentPage];
		}
		else if (upperNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
		}
		else
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	
	[currentPage updateTextViews:NO];
	[nextPage updateTextViews:NO];*/
//}

/*- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)newScrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
    
	if (currentPage.pageIndex != nearestNumber)
	{
		PageViewController *swapController = currentPage;
		currentPage = nextPage;
		nextPage = swapController;
	}
    
	[currentPage updateTextViews:YES];*/
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)newScrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    
    pageControl.currentPage = nearestNumber;
    if (nearestNumber == 0) {
        
        if (self.showReveal) {
            self.revealButton.hidden = YES;
            self.cancelButton.hidden = YES;
        }
        else {
            self.okButton.hidden = YES;
        }
        self.nextButton.hidden = NO;
        
    }
    else {
        self.nextButton.hidden = YES;
        
        if (self.showReveal) {
            self.revealButton.hidden = NO;
            self.cancelButton.hidden = NO;
        }
        else {
            self.okButton.hidden = NO;
        }
    }

}

- (IBAction)next:(id)sender
{
    NSInteger pageIndex = pageControl.currentPage;
    
    if (pageIndex == 0) {
        pageControl.currentPage = 1;
        pageIndex = 1;
        if (self.showReveal) {
            self.revealButton.hidden = NO;
            self.cancelButton.hidden = NO;
        }
        else {
            self.okButton.hidden = NO;
        }
        self.nextButton.hidden = YES;

    }
    else {
        pageControl.currentPage = 0;
        pageIndex = 0;
        self.nextButton.hidden = NO;
        
        if (self.showReveal) {
            self.revealButton.hidden = YES;
            self.cancelButton.hidden = YES;
        }
        else {
            self.okButton.hidden = YES;
        }
        
    }
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageIndex;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
}
- (IBAction)changePage:(id)sender
{
	NSInteger pageIndex = pageControl.currentPage;
    
    if (pageIndex == 0) {
        if (self.showReveal) {
            self.revealButton.hidden = YES;
            self.cancelButton.hidden = YES;
        }
        else {
            self.okButton.hidden = YES;
        }
        self.nextButton.hidden = NO;
    }
    else {
        self.nextButton.hidden = YES;
        if (self.showReveal) {
            self.revealButton.hidden = NO;
            self.cancelButton.hidden = NO;
        }
        else {
            self.okButton.hidden = NO;
        }
    }
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageIndex;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
   // [scrollView addSubview:nextPage];
}

- (IBAction)reveal:(id)sender
{
    [self.revealTutorialDelegate didClickReveal];
    [self dismissTutorial:sender];
}

- (void) dealloc
{
    [nextButton release]; nextButton = nil;
    [revealButton release]; revealButton = nil;
    [cancelButton release]; cancelButton = nil;
    [okButton release]; okButton = nil;
    [super dealloc];
}
@end
