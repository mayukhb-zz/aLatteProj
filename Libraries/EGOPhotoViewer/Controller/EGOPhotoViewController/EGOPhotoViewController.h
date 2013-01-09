//
//  EGOPhotoController.h
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

#import <MessageUI/MessageUI.h>
#import "EGOPhotoSource.h"
#import "EGOPhotoGlobal.h"
#import "CustomHTTPRequest.h"

@class EGOPhotoImageView, EGOPhotoCaptionView;

/* Code additions by mayukh bhaowal - start */
@protocol EGOPhotoViewControllerDelegate 

- (BOOL) isSelectedPicThumbnail: (NSNumber*) photoId;
- (void) setPhoto:(NSString *)path withServerPhotoId: (NSNumber*) photoId;
- (void) setProfilePhoto:(NSData *)photoData withId:(NSNumber *)photoId;
- (void) deletePhoto:(NSNumber*) photoId;

@end

/* Code additions by mayukh bhaowal - end */
@interface EGOPhotoViewController : UIViewController <UINavigationControllerDelegate,UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, CustomHTTPRequestDelegate> {
@private
	id <EGOPhotoSource> _photoSource;
	EGOPhotoCaptionView *_captionView;
	NSMutableArray *_photoViews;
	UIScrollView *_scrollView;	
	
	NSInteger _pageIndex;
	BOOL _rotating;
	BOOL _barsHidden;
	
	UIBarButtonItem *_leftButton;
	UIBarButtonItem *_rightButton;
	//UIBarButtonItem *_actionButton;
	
	BOOL _storedOldStyles;
	UIStatusBarStyle _oldStatusBarSyle;
	UIBarStyle _oldNavBarStyle;
	BOOL _oldNavBarTranslucent;
	UIColor* _oldNavBarTintColor;	
	UIBarStyle _oldToolBarStyle;
	BOOL _oldToolBarTranslucent;
	UIColor* _oldToolBarTintColor;	
	BOOL _oldToolBarHidden;

	//BOOL _autoresizedPopover;
	id _popover;
	
	BOOL _fullScreen;
	BOOL _fromPopover;
	UIView *_popoverOverlay;
	UIView *_transferView;
    
    BOOL _viewOnlyMode;
    
    CustomHTTPRequest *request;
    id<EGOPhotoViewControllerDelegate> photoDelegate;
    
    //Mayukh: Code additions
    NSData *imageData;
    NSNumber *photoId;
    UIActivityIndicatorView *spinner;
	
}

- (id)initWithPhoto:(id<EGOPhoto>)aPhoto;

- (id)initWithImage:(UIImage*)anImage;
- (id)initWithImageURL:(NSURL*)anImageURL;

- (id)initWithPhotoSource:(id <EGOPhotoSource>)aPhotoSource andViewOnlyMode:(BOOL)mode;
- (id)initWithPopoverController:(id)aPopoverController photoSource:(id <EGOPhotoSource>)aPhotoSource;

@property(nonatomic,readonly) id <EGOPhotoSource> photoSource;
@property(nonatomic,retain) NSMutableArray *photoViews;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,assign) BOOL _fromPopover;
@property(nonatomic,assign) BOOL _viewOnlyMode;
@property (retain, nonatomic) CustomHTTPRequest *request;
@property (nonatomic, assign) id<EGOPhotoViewControllerDelegate> photoDelegate;

//Mayukh: Code additions
@property(nonatomic,retain) NSData *imageData;
@property(nonatomic,retain) NSNumber *photoId;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIBarButtonItem *_leftButton;
@property (nonatomic, retain) UIBarButtonItem *_rightButton;


- (NSInteger)currentPhotoIndex;
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void) makeProfilePic;
- (void) stopSpinner;
@end