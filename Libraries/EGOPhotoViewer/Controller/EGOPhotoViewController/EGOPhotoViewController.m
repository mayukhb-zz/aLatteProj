//
//  EGOPhotoController.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOPhotoViewController.h"
#import "Constants.h"
#import "UIImage+Thumbnail.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ErrorHandler.h"
#import "UIImage+Thumbnail.h"
#import "MyPhoto.h"


@interface EGOPhotoViewController (Private)
- (void)loadScrollViewWithPage:(NSInteger)page;
- (void)layoutScrollViewSubviews;
- (void)setupScrollViewContentSize;
- (void)enqueuePhotoViewAtIndex:(NSInteger)theIndex;
- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (NSInteger)centerPhotoIndex;
- (void)setupToolbar;
- (void)setViewState;
- (void)setupViewForPopover;
- (void)autosizePopoverToImageSize:(CGSize)imageSize photoImageView:(EGOPhotoImageView*)photoImageView;
@end


@implementation EGOPhotoViewController

@synthesize scrollView=_scrollView;
@synthesize photoSource=_photoSource; 
@synthesize photoViews=_photoViews;
@synthesize _fromPopover;
@synthesize _viewOnlyMode;
@synthesize request;
@synthesize photoDelegate;
@synthesize imageData, photoId;
@synthesize spinner;
@synthesize _leftButton;
@synthesize _rightButton;

#define USE_SCREEN_IMAGE 1

- (id)initWithPhoto:(id<EGOPhoto>)aPhoto {
	return [self initWithPhotoSource:[[[EGOQuickPhotoSource alloc] initWithPhotos:[NSArray arrayWithObjects:aPhoto,nil]] autorelease] andViewOnlyMode:YES];
}

- (id)initWithImage:(UIImage*)anImage {
	return [self initWithPhoto:[[[EGOQuickPhoto alloc] initWithImage:anImage] autorelease]];
}

- (id)initWithImageURL:(NSURL*)anImageURL {
	return [self initWithPhoto:[[[EGOQuickPhoto alloc] initWithImageURL:anImageURL] autorelease]];
}

//Mayukh: the one used to initalize 
- (id)initWithPhotoSource:(id <EGOPhotoSource> )aSource andViewOnlyMode:(BOOL)mode{
	if (self = [super init]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"EGOPhotoViewToggleBars" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoViewDidFinishLoading:) name:@"EGOPhotoDidFinishLoading" object:nil];
		
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;
		self._viewOnlyMode = mode;
		_photoSource = [aSource retain];
		_pageIndex=0;
		
	}
	
	return self;
}

- (id)initWithPopoverController:(id)aPopoverController photoSource:(id <EGOPhotoSource>)aPhotoSource {
	if (self = [self initWithPhotoSource:aPhotoSource andViewOnlyMode:NO]) {
		_popover = aPopoverController;
	}
	
	return self;
}


#pragma mark -
#pragma mark View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	self.wantsFullScreenLayout = YES;
	
	if (!_scrollView) {
		
		_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		_scrollView.delegate=self;
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_scrollView.multipleTouchEnabled=YES;
		_scrollView.scrollEnabled=YES;
		_scrollView.directionalLockEnabled=YES;
		_scrollView.canCancelContentTouches=YES;
		_scrollView.delaysContentTouches=YES;
		_scrollView.clipsToBounds=YES;
		_scrollView.alwaysBounceHorizontal=YES;
		_scrollView.bounces=YES;
		_scrollView.pagingEnabled=YES;
		_scrollView.showsVerticalScrollIndicator=NO;
		_scrollView.showsHorizontalScrollIndicator=NO;
		_scrollView.backgroundColor = self.view.backgroundColor;
		[self.view addSubview:_scrollView];

	}
	
	/*if (!_captionView) {
		
		EGOPhotoCaptionView *view = [[EGOPhotoCaptionView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 1.0f)];
		[self.view addSubview:view];
		_captionView=view;
		[view release];
     
		
	}*/
	
	//  load photoviews lazily
	NSMutableArray *views = [[NSMutableArray alloc] init];
	for (unsigned i = 0; i < [self.photoSource numberOfPhotos]; i++) {
		[views addObject:[NSNull null]];
	}
	self.photoViews = views;
	[views release];


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if ([self.photoSource numberOfPhotos] == 1 && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
		
		[self.navigationController setNavigationBarHidden:YES animated:NO];
		[self.navigationController setToolbarHidden:YES animated:NO];
		
		[self enqueuePhotoViewAtIndex:_pageIndex];
		[self loadScrollViewWithPage:_pageIndex];
		[self setViewState];
		
	}
#endif
	

    UIActivityIndicatorView *activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle) UIActivityIndicatorViewStyleWhiteLarge];
    [activitySpinner setCenter:CGPointMake(160.0, 200.0)]; 
    self.spinner = activitySpinner;
    
    [activitySpinner release]; activitySpinner = nil;
    [self.view addSubview:self.spinner]; 
    
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		
		UIView *view = self.view;
		if (self.navigationController) {
			view = self.navigationController.view;
		}
		
		while (view != nil) {
			
			if ([view isKindOfClass:NSClassFromString(@"UIPopoverView")]) {
				
				_popover = view;
				break;
			
			} 
			view = view.superview;
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
		if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad && _popover==nil) {
			[self.navigationController setNavigationBarHidden:NO animated:NO];
		}
#endif
		
	} else {
		
		_popover = nil;
		
	}
	
	if(!_storedOldStyles) {
		_oldStatusBarSyle = [UIApplication sharedApplication].statusBarStyle;
		
		_oldNavBarTintColor = [self.navigationController.navigationBar.tintColor retain];
		_oldNavBarStyle = self.navigationController.navigationBar.barStyle;
		_oldNavBarTranslucent = self.navigationController.navigationBar.translucent;
		
		_oldToolBarTintColor = [self.navigationController.toolbar.tintColor retain];
		_oldToolBarStyle = self.navigationController.toolbar.barStyle;
		_oldToolBarTranslucent = self.navigationController.toolbar.translucent;
		_oldToolBarHidden = [self.navigationController isToolbarHidden];
		
		_storedOldStyles = YES;
	}	
	
	if ([self.navigationController isToolbarHidden] && (!_popover || ([self.photoSource numberOfPhotos] > 1))) {
		[self.navigationController setToolbarHidden:NO animated:YES];
	}
	
	if (!_popover) {
		self.navigationController.navigationBar.tintColor = nil;
		self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
		self.navigationController.navigationBar.translucent = YES;
		
		self.navigationController.toolbar.tintColor = nil;
		self.navigationController.toolbar.barStyle = UIBarStyleBlack;
		self.navigationController.toolbar.translucent = YES;
	}

	
	[self setupToolbar];
	[self setupScrollViewContentSize];
	[self moveToPhotoAtIndex:_pageIndex animated:NO];
	
	if (_popover) {
		[self addObserver:self forKeyPath:@"contentSizeForViewInPopover" options:NSKeyValueObservingOptionNew context:NULL];
	}
	
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationController.navigationBar.barStyle = _oldNavBarStyle;
	self.navigationController.navigationBar.tintColor = _oldNavBarTintColor;
	self.navigationController.navigationBar.translucent = _oldNavBarTranslucent;
	
	[[UIApplication sharedApplication] setStatusBarStyle:_oldStatusBarSyle animated:YES];
	
	if(!_oldToolBarHidden) {
		
		if ([self.navigationController isToolbarHidden]) {
			[self.navigationController setToolbarHidden:NO animated:YES];
		}
		
		self.navigationController.toolbar.barStyle = _oldNavBarStyle;
		self.navigationController.toolbar.tintColor = _oldNavBarTintColor;
		self.navigationController.toolbar.translucent = _oldNavBarTranslucent;
		
	} else {
		
		[self.navigationController setToolbarHidden:_oldToolBarHidden animated:YES];
		
	}
	
	if (_popover) {
		[self removeObserver:self forKeyPath:@"contentSizeForViewInPopover"];
	}
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
#endif
	
   	return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	_rotating = YES;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && !_popover) {
		CGRect rect = [[UIScreen mainScreen] bounds];
		self.scrollView.contentSize = CGSizeMake(rect.size.height * [self.photoSource numberOfPhotos], rect.size.width);
	}
	
	//  set side views hidden during rotation animation
	NSInteger count = 0;
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			if (count != _pageIndex) {
				[view setHidden:YES];
			}
		}
		count++;
	}
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			[view rotateToOrientation:toInterfaceOrientation];
		}
	}
		
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	
	[self setupScrollViewContentSize];
	[self moveToPhotoAtIndex:_pageIndex animated:NO];
	[self.scrollView scrollRectToVisible:((EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).frame animated:YES];
	
	//  unhide side views
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			[view setHidden:NO];
		}
	}
	_rotating = NO;
	
}

- (void)done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)setupToolbar {
	
	[self setupViewForPopover];

	if(_popover && [self.photoSource numberOfPhotos] == 1) {
		[self.navigationController setToolbarHidden:YES animated:NO];
		return;
	}
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (!_popover && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad && !_fromPopover) {
		if (self.modalPresentationStyle == UIModalPresentationFullScreen) {
			UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
			self.navigationItem.rightBarButtonItem = doneButton;
			[doneButton release];
		}
	} else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	}
#else 
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
#endif
	
	UIBarButtonItem *makeProfilePic = [[UIBarButtonItem alloc] initWithTitle:@"Face"style:UIBarButtonItemStyleBordered target:self action:@selector(makeProfilePicButtonHit:)];
	UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonHit:)];
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	if ([self.photoSource numberOfPhotos] > 1) {
		
		UIBarButtonItem *fixedCenter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		fixedCenter.width = 80.0f;
		UIBarButtonItem *fixedLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		fixedLeft.width = 40.0f;
		
		if (_popover && [self.photoSource numberOfPhotos] > 1) {
			UIBarButtonItem *scaleButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"egopv_fullscreen_button.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFullScreen:)];
			self.navigationItem.rightBarButtonItem = scaleButton;
			[scaleButton release];
		}		

		
		UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"egopv_left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveBack:)];
		UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"egopv_right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveForward:)];
		
        if (self._viewOnlyMode) {
            [self setToolbarItems:[NSArray arrayWithObjects: flex, left, fixedCenter, right, flex,  nil]];
        }
        else{
            [self setToolbarItems:[NSArray arrayWithObjects:makeProfilePic /*fixedLeft*/, flex, left, fixedCenter, right, flex, delete, nil]];
		}
		self._rightButton = right;
		self._leftButton = left;
		
		[fixedCenter release];
		[fixedLeft release];
		[right release];
		[left release];
		
	} else {
        if (self._viewOnlyMode) {
            [self setToolbarItems:[NSArray arrayWithObjects: flex, nil]];
        }
        else{
            [self setToolbarItems:[NSArray arrayWithObjects:makeProfilePic, flex, delete, nil]];
        }
	}
	
	//_actionButton=action;
	
	[delete release];
	[makeProfilePic release];
	[flex release];
	
}

- (NSInteger)currentPhotoIndex{
	
	return _pageIndex;
	
}


#pragma mark -
#pragma mark Popver ContentSize Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{	
	[self setupScrollViewContentSize];
	[self layoutScrollViewSubviews];
}


#pragma mark -
#pragma mark Bar/Caption Methods

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated{
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) return; 
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
		
	} else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30200
		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:animated];
#endif
	}

}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
	if (hidden&&_barsHidden) return;
	
	if (_popover && [self.photoSource numberOfPhotos] == 0) {
		[_captionView setCaptionHidden:hidden];
		return;
	}
		
	[self setStatusBarHidden:hidden animated:animated];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		if (!_popover) {
			
			if (animated) {
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.3f];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			}
			
			self.navigationController.navigationBar.alpha = hidden ? 0.0f : 1.0f;
			self.navigationController.toolbar.alpha = hidden ? 0.0f : 1.0f;
			
			if (animated) {
				[UIView commitAnimations];
			}
			
		} 
		
	} else {
		
		[self.navigationController setNavigationBarHidden:hidden animated:animated];
		[self.navigationController setToolbarHidden:hidden animated:animated];
		
	}
#else
	
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	[self.navigationController setToolbarHidden:hidden animated:animated];
	
#endif
	
	if (_captionView) {
		[_captionView setCaptionHidden:hidden];
	}
	
	_barsHidden=hidden;
	
}

- (void)toggleBarsNotification:(NSNotification*)notification{
	[self setBarsHidden:!_barsHidden animated:YES];
}


#pragma mark -
#pragma mark FullScreen Methods

- (void)setupViewForPopover{
	
	if (!_popoverOverlay && _popover && [self.photoSource numberOfPhotos] == 1) {
				
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 40.0f)];
		view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
		_popoverOverlay = view;
		[self.view addSubview:view];
		[view release];
		
		UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _popoverOverlay.frame.size.width, 1.0f)];
		borderView.autoresizingMask = view.autoresizingMask;
		[_popoverOverlay addSubview:borderView];
		[borderView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.4f]];
		[borderView release];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setImage:[UIImage imageNamed:@"egopv_fullscreen_button.png"] forState:UIControlStateNormal];
		button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[button addTarget:self action:@selector(toggleFullScreen:) forControlEvents:UIControlEventTouchUpInside];
		button.frame = CGRectMake(view.frame.size.width - 40.0f, 0.0f, 40.0f, 40.0f);
		[view addSubview:button];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		view.frame = CGRectMake(0.0f, self.view.bounds.size.height - 40.0f, self.view.bounds.size.width, 40.0f);
		[UIView commitAnimations];
		
	}
	
}

- (CATransform3D)transformForCurrentOrientation{
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	switch (orientation) {
		case UIInterfaceOrientationPortraitUpsideDown:
			return CATransform3DMakeRotation((M_PI/180)*180, 0.0f, 0.0f, 1.0f);
			break;
		case UIInterfaceOrientationLandscapeRight:
			return CATransform3DMakeRotation((M_PI/180)*90, 0.0f, 0.0f, 1.0f);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			return CATransform3DMakeRotation((M_PI/180)*-90, 0.0f, 0.0f, 1.0f);
			break;
		default:
			return CATransform3DIdentity;
			break;
	}
	
}

- (void)toggleFullScreen:(id)sender{
	
	_fullScreen = !_fullScreen;
	
	if (!_fullScreen) {
		
		NSInteger pageIndex = 0;
		if (self.modalViewController && [self.modalViewController isKindOfClass:[UINavigationController class]]) {
			UIViewController *controller = [((UINavigationController*)self.modalViewController) visibleViewController];
			if ([controller isKindOfClass:[self class]]) {
				pageIndex = [(EGOPhotoViewController*)controller currentPhotoIndex];
			}
		}		
		[self moveToPhotoAtIndex:pageIndex animated:NO];
		[self.navigationController dismissModalViewControllerAnimated:NO];
		
	}
	
	EGOPhotoImageView *_currentView = [self.photoViews objectAtIndex:_pageIndex];
	BOOL enabled = [UIView areAnimationsEnabled];
	[UIView setAnimationsEnabled:NO];
	[_currentView killScrollViewZoom];
	[UIView setAnimationsEnabled:enabled];
	UIImageView *_currentImage = _currentView.imageView;
	
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	backgroundView.layer.transform = [self transformForCurrentOrientation];
	[keyWindow addSubview:backgroundView];
	backgroundView.frame = [[UIScreen mainScreen] applicationFrame];
	_transferView = backgroundView;
	[backgroundView release];
	
	CGRect newRect = [self.view convertRect:_currentView.scrollView.frame toView:_transferView];
	UIImageView *_imageView = [[UIImageView alloc] initWithFrame:_fullScreen ? newRect : _transferView.bounds];	
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	[_imageView setImage:_currentImage.image];
	[_transferView addSubview:_imageView];
	[_imageView release];
	
	self.scrollView.hidden = YES;
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
	animation.fromValue = _fullScreen ? (id)[UIColor clearColor].CGColor : (id)[UIColor blackColor].CGColor;
	animation.toValue = _fullScreen ? (id)[UIColor blackColor].CGColor : (id)[UIColor clearColor].CGColor;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.duration = 0.4f;
	[_transferView.layer addAnimation:animation forKey:@"FadeAnimation"];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fullScreenAnimationDidStop:finished:context:)];
	_imageView.frame = _fullScreen ? _transferView.bounds : newRect;
	[UIView commitAnimations];
	
}

- (void)fullScreenAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	
	if (finished) {
		
		self.scrollView.hidden = NO;
		
		if (_transferView) {
			[_transferView removeFromSuperview];
			_transferView=nil;
		}
		
		if (_fullScreen) {
			
			BOOL enabled = [UIView areAnimationsEnabled];
			[UIView setAnimationsEnabled:NO];
			
			EGOPhotoViewController *controller = [[EGOPhotoViewController alloc] initWithPhotoSource:self.photoSource andViewOnlyMode:NO];
			controller._fromPopover = YES;
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
			
			navController.modalPresentationStyle = UIModalPresentationFullScreen;
			[self.navigationController presentModalViewController:navController animated:NO];
			[controller moveToPhotoAtIndex:_pageIndex animated:NO];
			
			[navController release];
			[controller release];
			
			[UIView setAnimationsEnabled:enabled];
			
			UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"egopv_minimize_fullscreen_button.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFullScreen:)];
			controller.navigationItem.rightBarButtonItem = button;
			[button release];
			
		}
		
	}
	
}



#pragma mark -
#pragma mark Photo View Methods

- (void)photoViewDidFinishLoading:(NSNotification*)notification{
	if (notification == nil) return;
	
	if ([[[notification object] objectForKey:@"photo"] isEqual:[self.photoSource photoAtIndex:[self centerPhotoIndex]]]) {
		if ([[[notification object] objectForKey:@"failed"] boolValue]) {
			if (_barsHidden) {
				//  image failed loading
				[self setBarsHidden:NO animated:YES];
			}
		} 
		[self setViewState];
	}
}

- (NSInteger)centerPhotoIndex{
	
	CGFloat pageWidth = self.scrollView.frame.size.width;
    //NSLog(@"contentoffset %f",self.scrollView.contentOffset.x );
	return floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
}

- (void)moveForward:(id)sender{
	[self moveToPhotoAtIndex:[self centerPhotoIndex]+1 animated:NO];	
}

- (void)moveBack:(id)sender{
     //NSLog(@"contentoffset %d",[self centerPhotoIndex] );
	[self moveToPhotoAtIndex:[self centerPhotoIndex]-1 animated:NO];
}

- (void)setViewState {	
  	if (self._leftButton) {
		self._leftButton.enabled = !(_pageIndex-1 < 0);
	}
	
	if (self._rightButton) {
		self._rightButton.enabled = !(_pageIndex+1 >= [self.photoSource numberOfPhotos]);
	}
	
	/*if (_actionButton) {
		EGOPhotoImageView *imageView = [_photoViews objectAtIndex:[self centerPhotoIndex]];
		if ((NSNull*)imageView != [NSNull null]) {
			
			_actionButton.enabled = ![imageView isLoading];
			
		} else {
			
			_actionButton.enabled = NO;
		}
	}*/
    
	if ([self.photoSource numberOfPhotos] > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", _pageIndex+1, [self.photoSource numberOfPhotos]];
	} else {
		self.title = @"";
	}
	
	/*if (_captionView) {
		[_captionView setCaptionText:[[self.photoSource photoAtIndex:_pageIndex] caption] hidden:NO];
	}*/
    
	if (!self._viewOnlyMode) {
        UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionButtonHit:)];
        self.navigationItem.rightBarButtonItem = addButtonItem;
        [addButtonItem release];
    }
	
	
	UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonHit:)];
	self.navigationItem.leftBarButtonItem = leftBarButtonItem;
	
	[leftBarButtonItem release];
	
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
			
	//if([self respondsToSelector:@selector(setContentSizeForViewInPopover:)] && [self.photoSource numberOfPhotos] == 1) {
		
		EGOPhotoImageView *imageView = [_photoViews objectAtIndex:[self centerPhotoIndex]];
		if ((NSNull*)imageView != [NSNull null]) {
			self.contentSizeForViewInPopover = [imageView sizeForPopover];
		}
		
	//}
	
#endif
	
}

- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
	NSAssert(index < [self.photoSource numberOfPhotos] && index >= 0, @"Photo index passed out of bounds");
	
	_pageIndex = index;
	[self setViewState];

	[self enqueuePhotoViewAtIndex:index];
	
	[self loadScrollViewWithPage:index-1];
	[self loadScrollViewWithPage:index];
	[self loadScrollViewWithPage:index+1];
	
	
	[self.scrollView scrollRectToVisible:((EGOPhotoImageView*)[self.photoViews objectAtIndex:index]).frame animated:animated];
	
	if ([[self.photoSource photoAtIndex:_pageIndex] didFail]) {
		[self setBarsHidden:NO animated:YES];
	}
	
	//  reset any zoomed side views
	if (index + 1 < [self.photoSource numberOfPhotos] && (NSNull*)[self.photoViews objectAtIndex:index+1] != [NSNull null]) {
		[((EGOPhotoImageView*)[self.photoViews objectAtIndex:index+1]) killScrollViewZoom];
	} 
	if (index - 1 >= 0 && (NSNull*)[self.photoViews objectAtIndex:index-1] != [NSNull null]) {
		[((EGOPhotoImageView*)[self.photoViews objectAtIndex:index-1]) killScrollViewZoom];
	} 	
	
}

- (void)layoutScrollViewSubviews{
	
	NSInteger _index = [self currentPhotoIndex];
	
	for (NSInteger page = _index -1; page < _index+3; page++) {
		
		if (page >= 0 && page < [self.photoSource numberOfPhotos]){
			
			CGFloat originX = self.scrollView.bounds.size.width * page;
			
			if (page < _index) {
				originX -= EGOPV_IMAGE_GAP;
			} 
			if (page > _index) {
				originX += EGOPV_IMAGE_GAP;
			}
			
			if ([self.photoViews objectAtIndex:page] == [NSNull null] || !((UIView*)[self.photoViews objectAtIndex:page]).superview){
				[self loadScrollViewWithPage:page];
			}
			
			EGOPhotoImageView *_photoView = (EGOPhotoImageView*)[self.photoViews objectAtIndex:page];
			CGRect newframe = CGRectMake(originX, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
			
			if (!CGRectEqualToRect(_photoView.frame, newframe)) {	
				
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.1];
				_photoView.frame = newframe;
				[UIView commitAnimations];
			
			}
			
		}
	}
	
}

- (void)setupScrollViewContentSize{
	 //NSLog(@"contentoffset %f , %f , %d",self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, [self.photoSource numberOfPhotos] );
    
	CGFloat toolbarSize = _popover ? 0.0f : self.navigationController.toolbar.frame.size.height;	
	
	CGSize contentSize = self.view.bounds.size;
	contentSize.width = (contentSize.width * [self.photoSource numberOfPhotos]);
	
	if (!CGSizeEqualToSize(contentSize, self.scrollView.contentSize)) {
		self.scrollView.contentSize = contentSize;
	}
	 //NSLog(@"contentoffset %f",self.scrollView.contentOffset.x );
	_captionView.frame = CGRectMake(0.0f, self.view.bounds.size.height - (toolbarSize + 40.0f), self.view.bounds.size.width, 40.0f);

}
//Mayukh: enque figures if a EGOPhotoImageView is in the 3 pages bound of the selected index. If not, remove it from the superview and prepare it for reuse. (i.e. set it a tag of -1)
- (void)enqueuePhotoViewAtIndex:(NSInteger)theIndex{
	
	NSInteger count = 0;
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			if (count > theIndex+1 || count < theIndex-1) {
				[view prepareForReusue];
				[view removeFromSuperview];
			} else {
				view.tag = 0;
			}
			
		} 
		count++;
	}	
	
}

- (EGOPhotoImageView*)dequeuePhotoView{
	
	NSInteger count = 0;
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			if (view.superview == nil) {
				view.tag = count;
				return view;
			}
		}
		count ++;
	}	
	return nil;
	
}

- (void)loadScrollViewWithPage:(NSInteger)page {
	
    if (page < 0) return;
    if (page >= [self.photoSource numberOfPhotos]) return;
	
	EGOPhotoImageView * photoView = [self.photoViews objectAtIndex:page];
	if ((NSNull*)photoView == [NSNull null]) {
		
		photoView = [self dequeuePhotoView];
		if (photoView != nil) {
			[self.photoViews exchangeObjectAtIndex:photoView.tag withObjectAtIndex:page];
			photoView = [self.photoViews objectAtIndex:page];
		}
		
	}
	
	if (photoView == nil || (NSNull*)photoView == [NSNull null]) {
		
		photoView = [[EGOPhotoImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
		[self.photoViews replaceObjectAtIndex:page withObject:photoView];
		[photoView release];
		
	} 
	
	[photoView setPhoto:[self.photoSource photoAtIndex:page]];
	
    if (photoView.superview == nil) {
		[self.scrollView addSubview:photoView];
	}
	
	CGRect frame = self.scrollView.frame;
	NSInteger centerPageIndex = _pageIndex;
	CGFloat xOrigin = (frame.size.width * page);
	if (page > centerPageIndex) {
		xOrigin = (frame.size.width * page) + EGOPV_IMAGE_GAP;
	} else if (page < centerPageIndex) {
		xOrigin = (frame.size.width * page) - EGOPV_IMAGE_GAP;
	}
	
	frame.origin.x = xOrigin;
	frame.origin.y = 0;
	photoView.frame = frame;
}


#pragma mark -
#pragma mark UIScrollView Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	NSInteger _index = [self centerPhotoIndex];
	if (_index >= [self.photoSource numberOfPhotos] || _index < 0) {
		return;
	}
	
	if (_pageIndex != _index && !_rotating) {

		[self setBarsHidden:YES animated:YES];
		_pageIndex = _index;
		[self setViewState];
		
		if (![scrollView isTracking]) {
			[self layoutScrollViewSubviews];
		}
		
	}
		
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	NSInteger _index = [self centerPhotoIndex];
	if (_index >= [self.photoSource numberOfPhotos] || _index < 0) {
		return;
	}
	
	[self moveToPhotoAtIndex:_index animated:YES];

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
	[self layoutScrollViewSubviews];
}


#pragma mark -
#pragma mark Actions

- (void)savePhoto: (UIImage*) img withScaling: (BOOL) scale{
	
    if (scale) {
        UIImage *scaledImg = [img makeThumbnailOfSize:[[UIScreen mainScreen ] bounds].size];
        self.imageData = UIImageJPEGRepresentation(scaledImg, 0.5);
    }
    else
    {
        self.imageData = UIImageJPEGRepresentation(img, 0.5);
    }
    
   
    [self.request clearDelegatesAndCancel];
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];   
    [self.request addDataForImageContent:self.imageData withKey:@"img"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //Get userId from NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [params setValue:[NSNumber numberWithInt:[prefs integerForKey:@"userId"]] forKey:@"userid"];
    [params setValue:@"uploadphoto" forKey:@"script"];
    
    self.request.customHTTPDelegate = self;
    self.request.tag = REQUEST_FOR_ADD_PHOTO;
    [self.request setPostValues:params];
    
}

- (void)takePhoto{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
	{
	
		UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera; 
		picker.delegate = self;
		picker.allowsEditing = TRUE;
		[self presentModalViewController:picker animated:YES];
        [picker release]; picker = nil;

	}
}

- (void)choosePhoto{
    
	if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
	{
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
		picker.delegate = self;
		picker.allowsEditing = TRUE;
		[self presentModalViewController:picker animated:YES];
        [picker release]; picker = nil;
    }
}

/*
- (void)copyPhoto{
	
	[[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation(((EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).imageView.image) forPasteboardType:@"public.png"];
	
}
*/
/*
- (void)emailPhoto{
	
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject:@"Shared Photo"];
	[mailViewController addAttachmentData:[NSData dataWithData:UIImagePNGRepresentation(((EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).imageView.image)] mimeType:@"png" fileName:@"Photo.png"];
	mailViewController.mailComposeDelegate = self;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
		mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	}
#endif
	
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
	
}
*/
/*
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
	[self dismissModalViewControllerAnimated:YES];
	
	NSString *mailError = nil;
	
	switch (result) {
		case MFMailComposeResultSent: ; break;
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}
	
	if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}
*/

#pragma mark -
#pragma mark UIActionSheet Methods

- (void)actionButtonHit:(id)sender{
	
	UIActionSheet *actionSheet;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !_popover) {
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
		} else {
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
		}
#else
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
#endif
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	actionSheet.tag = 1;
	[actionSheet showInView:self.view];
	[self setBarsHidden:YES animated:YES];
	
	[actionSheet release];
	
}

- (void)leftButtonHit:(id)sender{
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)makeProfilePicButtonHit:(id)sender
{
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Make this profile pic", nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	actionSheet.tag = 2;
	[actionSheet showInView:self.view];
	[self setBarsHidden:YES animated:YES];
	
	[actionSheet release];
}

- (void) makeProfilePic
{
    NSString *caption = [[self.photoSource photoAtIndex:_pageIndex] caption];
    
    //Get the photoid from caption using number formatter
    //Extract the photo id using numberformatter
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    self.photoId = [f numberFromString:caption];
    [f release];
    
    if (photoId == nil) {
        [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:self];
        return;
    }
    
    BOOL isSelectedPicThumbnail = [self.photoDelegate isSelectedPicThumbnail:photoId];
   
    //If the current pic is thumbnail already, just return. Dont do anything.
    if (isSelectedPicThumbnail) {
       return;
    } 
    [self.spinner startAnimating];
    
    EGOPhotoImageView* _currentView = (EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex];
 	UIImageView *_currentImage = _currentView.imageView;
    UIImage *thumb = [_currentImage.image makeThumbnailOfSizeWithAspectFill:CGSizeMake(208,298)];    
    
    self.imageData = UIImageJPEGRepresentation(thumb, .2); 
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    [self.request addDataForImageContent:self.imageData withKey:@"img"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //Get userId from NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [params setValue:[NSNumber numberWithInt:[prefs integerForKey:@"userId"]] forKey:@"userid"];
    [params setValue:photoId forKey:@"photoid"];
    [params setValue:@"thumbnail" forKey:@"mode"];
    [params setValue:@"uploadphoto" forKey:@"script"];
    
    self.request.tag = REQUEST_FOR_PROFILE_PIC_LABEL;
    self.request.customHTTPDelegate = self;
    [self.request setPostValues:params];

}

- (void)deleteButtonHit:(id)sender{
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete Pic", nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	actionSheet.tag = 3;
	[actionSheet showInView:self.view];
	[self setBarsHidden:YES animated:YES];
	
	[actionSheet release];

}

- (void)deletePic {
	
    NSString *caption = [[self.photoSource photoAtIndex:_pageIndex] caption];
    
    //Get the photoid from caption using number formatter
    //Extract the photo id using numberformatter
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    self.photoId = [f numberFromString:caption];
    [f release];
    
    if (photoId == nil) {
        [ErrorHandler displayString:@"Something went wrong. Please try again later." forDelegate:nil];
        return;
    }
    
    [self.spinner startAnimating];
    [self.request clearDelegatesAndCancel]; 
    self.request = [[[CustomHTTPRequest alloc] initWithPath:PRIVATEPATH presentDialog:YES] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //Get userId from NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [params setValue:[NSNumber numberWithInt:[prefs integerForKey:@"userId"]] forKey:@"userid"];
    [params setValue:self.photoId forKey:@"photoid"];
    [params setValue:@"delete" forKey:@"mode"];
    [params setValue:@"uploadphoto" forKey:@"script"];

    self.request.tag = REQUEST_FOR_DELETE_PHOTO;
    self.request.customHTTPDelegate = self;
    [self.request setPostValues:params];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	[self setBarsHidden:NO animated:YES];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        if (actionSheet.tag == 1) {
            [self takePhoto];
        }
        else if (actionSheet.tag ==2 ){
            [self makeProfilePic];
        }
        else
        {
            [self deletePic];
        }
		
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
		[self choosePhoto];	
	} 
}


#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
	
	self.photoViews=nil;
	self.scrollView=nil;
	_captionView=nil;
	
}

#pragma mark - picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if(info){
        [self.spinner startAnimating];
        // Don't pay any attention if somehow someone picked something besides an image.
        if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]){
            
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                
                [self savePhoto:[info objectForKey:UIImagePickerControllerOriginalImage] withScaling:YES];
                [self dismissModalViewControllerAnimated:YES];
                return;
            }
            
            NSURL *url;
            url = [info objectForKey:UIImagePickerControllerReferenceURL];
            
#if USE_SCREEN_IMAGE      
            // To get an asset library reference we need an instance of the asset library.
            ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
            NSString *osVersion = [[UIDevice currentDevice] systemVersion];
            NSString *versionWithoutRotation = @"5.0";
            BOOL noRotationNeeded = ([versionWithoutRotation compare:osVersion options:NSNumericSearch] 
                                     != NSOrderedDescending);
            // The assetForURL: method of the assets library needs a block for success and
            // one for failure. The resultsBlock is used for the success case.
            ALAssetsLibraryAssetForURLResultBlock resultsBlock = ^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                CGImageRef image = [representation fullScreenImage];
                if(noRotationNeeded){
                    // Create a UIImage from the full screen image. The full screen image
                    // is already scaled and oriented properly.
                    [self savePhoto:[UIImage imageWithCGImage:image] withScaling:NO];
                    
                }else{
                    // prior to iOS 5.0, the screen image needed to be rotated so
                    // make sure that the UIImage we create from the CG image has the appropriate
                    // orientation, based on the EXIF data from the image.
                    ALAssetOrientation orientation = [representation orientation];
                    [self savePhoto:[UIImage imageWithCGImage:image scale:1.0 
                                                  orientation:(UIImageOrientation)orientation] withScaling:NO];
                }
            };
            ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
                /*  A failure here typically indicates that the user has not allowed this app access
                 to location data. In that case the error code is ALAssetsLibraryAccessUserDeniedError.
                 In principle you could alert the user to that effect, i.e. they have to allow this app
                 access to location services in Settings > General > Location Services and turn on access
                 for this application.
                 */
                [ErrorHandler displayString:@"Unable to access photos.\n Make sure location services are ON in iPhone Settings." forDelegate:nil];
                //NSLog(@"FAILED! due to error in domain %@ with error code %d", error.domain, error.code);
                // This sample will abort since a shipping product MUST do something besides logging a
                // message. A real app needs to inform the user appropriately.
                if ([self.spinner isAnimating]) {
                    [self.spinner stopAnimating];
                }
                return;
            };
            
            // Get the asset for the asset URL to create a screen image.
            [assetsLibrary assetForURL:url resultBlock:resultsBlock failureBlock:failureBlock];
            // Release the assets library now that we are done with it.
            [assetsLibrary release];
#else
            // If we aren't using a screen sized image we'll use the original one.
            [self savePhoto:[info objectForKey:UIImagePickerControllerOriginalImage] withScaling:YES];
       
           // imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
#endif
            
            // Dismiss the modal view controller if we weren't presented from a popover.
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}


- (void) profilePicUploaded 
{
    if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
    }
    [self.photoDelegate setProfilePhoto:self.imageData withId:self.photoId];
}

- (void)photoDeleteFinished
{
    if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
    }
    [self.photoDelegate deletePhoto:self.photoId];
    
    NSInteger currentPhotoIndex = [self currentPhotoIndex];
    [[self.photoViews objectAtIndex:currentPhotoIndex] removeFromSuperview];
    [self.photoSource deletePhotoAtIndex:currentPhotoIndex];
    [self.photoViews removeObjectAtIndex:currentPhotoIndex];
    
    if ([self.photoSource numberOfPhotos] == 0) {
        MyPhoto *photo = [[MyPhoto alloc ] initWithImage:[UIImage imageNamed:@"egopv_photo_placeholder.png"]];
        [self.photoSource addPhoto:photo];
        [self.photoViews addObject:[NSNull null]];
        [self setupScrollViewContentSize];
        [self layoutScrollViewSubviews];
        [photo release]; photo = nil;
        return;
        
    }
    [self setupScrollViewContentSize];
    [self layoutScrollViewSubviews];
    
    if ([self.photoSource numberOfPhotos] > currentPhotoIndex ) {
        [self setViewState];
        [self loadScrollViewWithPage:currentPhotoIndex];//test by removing this line
       // [self moveToPhotoAtIndex:currentPhotoIndex animated:YES];
        
    }
    else if (currentPhotoIndex > 0){
        [self moveToPhotoAtIndex:currentPhotoIndex-1 animated:YES];
        
    }
    
}

- (void) photoUploadFinished:(NSNumber *)photoIdentifier path:(NSString *)path
{
    if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
    }
    self.photoId = photoIdentifier;
    [self.photoDelegate setPhoto:path withServerPhotoId:self.photoId];
    MyPhoto *photo = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:path] name:[NSString stringWithFormat:@"%@",self.photoId]];
    
    NSString *caption = [[self.photoSource photoAtIndex:[self currentPhotoIndex]] caption];
    
    //Get the photoid from caption using number formatter
    //Extract the photo id using numberformatter
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    self.photoId = [f numberFromString:caption];
    [f release];
    
    if (self.photoId == nil) {
        NSInteger currentPhotoIndex = [self currentPhotoIndex];
        [self.photoSource deletePhotoAtIndex:currentPhotoIndex];
        [self.photoViews removeObjectAtIndex:currentPhotoIndex];
        
    }

    [self.photoSource addPhoto:photo];
    [self.photoViews addObject:[NSNull null]];
    [self setupScrollViewContentSize];
    [self layoutScrollViewSubviews];
    [photo release]; photo = nil;
    /*if ([self.photoSource numberOfPhotos] > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", _pageIndex+1, [self.photoSource numberOfPhotos]];
	} else {
		self.title = @"";
	}*/
	[self moveToPhotoAtIndex:[self.photoSource numberOfPhotos] - 1 animated:YES];
    
}

- (void) stopSpinner
{
    if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
    }
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_captionView = nil;
	[_photoViews release], _photoViews=nil;
	[_photoSource release], _photoSource=nil;
	[_scrollView release], _scrollView=nil;
	[_oldToolBarTintColor release], _oldToolBarTintColor = nil;
	[_oldNavBarTintColor release], _oldNavBarTintColor = nil;
	[imageData release]; imageData = nil;
    [photoId release]; photoId = nil;
    
    [self.request clearDelegatesAndCancel];
    self.request.customHTTPDelegate = nil;
    [request release]; request = nil;
    
    [spinner release]; spinner = nil;
    [_leftButton release]; _leftButton = nil;
    [_rightButton release]; _rightButton = nil;
    [super dealloc];
}


@end