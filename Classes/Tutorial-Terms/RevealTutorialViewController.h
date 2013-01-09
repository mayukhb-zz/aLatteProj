//
//  RevealTutorialViewController.h
//  DateMe
//
//  Created by Mayukh Bhaowal on 3/18/12.
//  Copyright (c) 2012 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RevealTutorialDelegate;

@interface RevealTutorialViewController : UIViewController <UIScrollViewDelegate>{
    
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *revealButton;
    IBOutlet UIButton *okButton;
    
    IBOutlet UIScrollView *scrollView;
	IBOutlet UIPageControl *pageControl;
	
	UIImageView *currentPage;
    UIImageView *nextPage;
    UILabel *currentLabel;
    UILabel *nextLabel;
    
    BOOL showReveal;
}

@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *revealButton;
@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, assign) id <RevealTutorialDelegate> revealTutorialDelegate;
@property (nonatomic, assign) BOOL showReveal;

- (IBAction)dismissTutorial:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)changePage:(id)sender;
- (IBAction)reveal:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fromDatesTable:(BOOL)showRevealButton;

@end

@protocol RevealTutorialDelegate 

@optional

- (void) didClickReveal;

@end