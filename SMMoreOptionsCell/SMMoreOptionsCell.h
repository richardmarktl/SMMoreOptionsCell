//
//  SMMoreOptionsCell.h
//  SMMoreOptionsCell
//
//  Created by Richard Marktl (@richmarktl) on 23.08.13.
//  Copyright (c) 2013 Richard Marktl (@richmarktl). All rights reserved.
//
//

#import <UIKit/UIKit.h>


@protocol SMMoreOptionsDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMMoreOptionsCell : UITableViewCell

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *scrollViewContentView;  // This content view is above the more options view.

// This scrollViewOptionsView contains per default the following 2 buttons, feel free to set your own options view. In
// the case you set your own custom scrollViewOptionsView, the -didTouchOnDelete: and -didTouchOnMore: are not called.
// The options view is always set to hidden if not visible through the scroll behaviour.
@property (nonatomic, strong) UIView *scrollViewOptionsView;
@property (nonatomic, strong) UIButton *moreButton;  // set your own button or modify the existing button
@property (nonatomic, strong) UIButton *deleteButton;  // set your own button or modify the existing button
@property (nonatomic, assign) CGFloat scrollViewOptionsWidth;  // set width of the scrollViewOptionsView, default 150 px

@property (nonatomic, weak) id<SMMoreOptionsDelegate> delegate;

- (void)dismissOptionsAnimated:(BOOL)animated;  // in the case the options are visble the view will dismiss them

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol SMMoreOptionsDelegate <NSObject>
@required
- (void)didTouchOnDelete:(SMMoreOptionsCell *)cell;
- (void)didTouchOnMore:(SMMoreOptionsCell *)cell;

@optional
- (void)cellDidHideOptions:(SMMoreOptionsCell *)cell;
- (void)cellDidShowOptions:(SMMoreOptionsCell *)cell;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface UIImage (SMMoreOptionsCell)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extern CGFloat const SMMoreOptionsDefaultContentWidth;
extern NSString * const SMMoreOptionsShouldHideNotification;       // post this notification to hide currently visible options