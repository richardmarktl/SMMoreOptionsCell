//
//  SMMoreOptionsCell.h
//  iTranslate
//
//  Created by Richard Marktl on 23.08.13.
//
//

#import <UIKit/UIKit.h>


@protocol SMMoreOptionsDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMMoreOptionsCell : UITableViewCell

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *scrollViewContentView;  // This content view is above the more options view.

// This scrollViewOptionsView contains per default the following 2 buttons, feel free to set your own options view.
@property (nonatomic, strong) UIView *scrollViewOptionsView;
@property (nonatomic, strong) UIButton *moreButton;  // set your own button or modify the existing button
@property (nonatomic, strong) UIButton *deleteButton;  // set your own button or modify the existing button
@property (nonatomic, assign) CGFloat scrollViewOptionsWidth;  // set width of the scrollViewOptionsView, default 150 px

@property (nonatomic, weak) id<SMMoreOptionsDelegate> delegate;

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
extern NSString * const SMMoreOptionsHideNotification;       // post this notification to hide currently visible options