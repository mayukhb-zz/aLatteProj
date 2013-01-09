//
//  TermsController.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 5/9/12.
//  Copyright (c) 2012 Individual. All rights reserved.
//

#import "TermsController.h"

@interface TermsController ()

@end

@implementation TermsController
@synthesize content;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Terms of Services";
    [super viewDidLoad];
    UIImage* img = [UIImage imageNamed:@"background.png"];
    UIImageView *imgView = [[[UIImageView alloc] initWithImage: img] autorelease];
    [self.view addSubview: imgView];
    [self.view sendSubviewToBack:imgView];
    imgView.center = CGPointMake(160, 175); 
    
    self.content.backgroundColor = [UIColor clearColor];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc
{
    [content release]; content = nil;
    [super dealloc];
}
@end
