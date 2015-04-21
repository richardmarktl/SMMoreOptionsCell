//
//  SMMoreOptionsCell.m
//  SMMoreOptionsCell
//
//  Created by Richard Marktl (@richmarktl) on 23.08.13.
//  Copyright (c) 2013 Richard Marktl (@richmarktl). All rights reserved.
//
//

#import "SMMoreOptionsCell.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat const SMMoreOptionsDefaultContentWidth = 150.0f;
CGFloat const SMMoreOptionsAnimationDuration = 0.25f;
NSString *const SMMoreOptionsShouldHideNotification = @"SMMoreOptionsHideNotification";


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMMoreOptionsCellGestureDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UITableViewCell *cell;

- (instancetype)initWithCell:(UITableViewCell *)cell;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMMoreOptionsCell () <UIScrollViewDelegate> {
    struct {
        unsigned int delegateDidHideOptions:1;
        unsigned int delegateDidShowOptions:1;
        unsigned int optionsVisible:1;
    } _optionsFlags;
}

@property (nonatomic, strong) SMMoreOptionsCellGestureDelegate *gestureDelegate;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIButton *singleTapButton;
@property (nonatomic, assign) CGPoint start;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SMMoreOptionsCell

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter/Getter

- (void)setDelegate:(id<SMMoreOptionsDelegate>)delegate {
    if ( _delegate == delegate )
        return;
    
    _delegate = delegate;
    _optionsFlags.delegateDidHideOptions = [_delegate respondsToSelector:@selector(cellDidHideOptions:)];
    _optionsFlags.delegateDidShowOptions = [_delegate respondsToSelector:@selector(cellDidShowOptions:)];
}

- (void)setScrollViewContentView:(UIView *)swipeContentView {
    if ( _scrollViewContentView == swipeContentView )
        return;
    
    [_scrollViewContentView removeFromSuperview]; // remove the old view
    
    _scrollViewContentView = swipeContentView;
    [self.contentView addSubview:_scrollViewContentView];
    [self setNeedsLayout];
}

- (void)setScrollViewOptionsView:(UIView *)optionsContentView {
    if ( _scrollViewOptionsView == optionsContentView )
        return;
    
    [_scrollViewOptionsView removeFromSuperview];  // remove the old view
    
    _scrollViewOptionsView = optionsContentView;
    _scrollViewOptionsView.hidden = !_optionsFlags.optionsVisible;
    [self.contentView insertSubview:_scrollViewOptionsView belowSubview:self.scrollViewContentView];
    [self setNeedsLayout];
}

- (void)setDeleteButton:(UIButton *)deleteButton {
    if ( _deleteButton == deleteButton )
        return;
    [_deleteButton removeFromSuperview];
    
    _deleteButton = deleteButton;
    [_deleteButton addTarget:self action:@selector(_touchOnDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollViewOptionsView addSubview:_deleteButton];
    [self setNeedsLayout];
}

- (void)setMoreButton:(UIButton *)moreButton {
    if ( _moreButton == moreButton )
        return;
    [_moreButton removeFromSuperview];
    
    _moreButton = moreButton;
    [_moreButton addTarget:self action:@selector(_touchOnMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollViewOptionsView addSubview:_moreButton];
    [self setNeedsLayout];
}

- (void)setScrollViewOptionsWidth:(CGFloat)optionsContentWidth {
    if ( _scrollViewOptionsWidth == optionsContentWidth )
        return;
    
    _scrollViewOptionsWidth = optionsContentWidth;
    [self setNeedsLayout];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initializeCellContent];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super initWithCoder:aDecoder] ) {
        [self initializeCellContent];
    }
    return self;
}

- (void)initializeCellContent {
    self.scrollViewOptionsWidth = SMMoreOptionsDefaultContentWidth;
    _optionsFlags.optionsVisible = NO;
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    // The cell is already delegate of some gesture recognizer classes and to prevent conflicts use this object.
    self.gestureDelegate = [[SMMoreOptionsCellGestureDelegate alloc] initWithCell:self];
    
    // Is only usable if the userInteractionEnabled property of the scrollview is set to NO.
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.delegate = self.gestureDelegate;
    
    self.scrollViewContentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.scrollViewContentView.backgroundColor = [UIColor whiteColor];
    
    self.scrollViewOptionsView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.singleTapButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.singleTapButton.backgroundColor = [UIColor clearColor];
    [self.singleTapButton addTarget:self action:@selector(_handleSingleTap:) forControlEvents:UIControlEventTouchUpInside];

    UIColor *red = [UIColor colorWithRed:(251.0f/255.0f) green:(59.0f/255.0f) blue:(56.0f/255) alpha:1.0f];
    UIImage *redImage = [UIImage imageWithColor:red];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:NSLocalizedString(@"Delete", @"") forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:redImage forState:UIControlStateNormal];
    [deleteButton setAdjustsImageWhenHighlighted:YES];
    [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
    self.deleteButton = deleteButton;

    UIColor *gray = [UIColor colorWithRed:(199.0f/255.0f) green:(199.0f/255.0f) blue:(204.0f/255) alpha:1.0f];
    UIImage *grayImage = [UIImage imageWithColor:gray];
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setTitle:NSLocalizedString(@"More", @"") forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreButton setBackgroundImage:grayImage forState:UIControlStateNormal];
    [moreButton setAdjustsImageWhenHighlighted:YES];
    [moreButton.titleLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
    self.moreButton = moreButton;
    
    [self.contentView addGestureRecognizer:self.panGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_receivedHideNotification:)
                                                 name:SMMoreOptionsShouldHideNotification
                                               object:nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    
    self.scrollViewOptionsView.frame = CGRectMake(bounds.size.width - self.scrollViewOptionsWidth,
                                                  0.0f,
                                                  self.scrollViewOptionsWidth,
                                                  bounds.size.height);
    self.scrollViewContentView.frame = bounds;
    
    CGFloat buttonWidth = ceilf(self.scrollViewOptionsWidth/2);
    self.moreButton.frame = CGRectMake(0.0f, 0.0f, buttonWidth, bounds.size.height);
    self.deleteButton.frame = CGRectMake(buttonWidth, 0.0f, buttonWidth, bounds.size.height);
    self.singleTapButton.frame = bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.scrollViewContentView.frame = self.contentView.bounds;
    self.scrollViewOptionsView.hidden = YES;
    _optionsFlags.optionsVisible = NO;
    [self.singleTapButton removeFromSuperview];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if ( _optionsFlags.optionsVisible ) {
        [self dismissOptionsAnimated:animated];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods 

- (void)_optionsViewDidDisappear {
    if ( _optionsFlags.delegateDidHideOptions && _optionsFlags.optionsVisible ) {
        [self.delegate cellDidHideOptions:self];
    }

    _optionsFlags.optionsVisible = NO;
    self.scrollViewOptionsView.hidden = YES;
    [self.singleTapButton removeFromSuperview];

}

- (void)_optionsViewDidAppear {
    if ( _optionsFlags.delegateDidShowOptions && !_optionsFlags.optionsVisible ) {
        [self.delegate cellDidShowOptions:self];
    }
    
    _optionsFlags.optionsVisible = YES;
    self.scrollViewContentView.userInteractionEnabled = YES;
    [self.scrollViewContentView addSubview:self.singleTapButton];
}

- (CGPoint)_scrollContentViewCenterForOffset:(CGFloat)offset {
    CGFloat x = ceil(CGRectGetWidth(self.contentView.bounds)/2.0f);
    
    if ( _optionsFlags.optionsVisible == YES ) {
        x -= ( self.scrollViewOptionsWidth + offset);
    } else {
        x -= MAX(offset, 0.0f);
    }
    
    return CGPointMake(x, self.scrollViewContentView.center.y);
}

- (CGPoint)_scrollContentViewStartPoint {
    return CGPointMake(ceil(CGRectGetWidth(self.contentView.bounds)/2.0f), self.scrollViewContentView.center.y);
}

- (CGPoint)_scrollContentViewEndPoint {
    return CGPointMake(ceil(CGRectGetWidth(self.contentView.bounds)/2.0f) - self.scrollViewOptionsWidth,
                       self.scrollViewContentView.center.y);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

- (void)dismissOptionsAnimated:(BOOL)animated {
    [UIView animateWithDuration:(animated) ? SMMoreOptionsAnimationDuration : 0.0f animations:^(void) {
        self.scrollViewContentView.frame = self.contentView.bounds;
    } completion:^(BOOL finished) {
        [self _optionsViewDidDisappear];
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Action Methods

- (void)_touchOnDelete:(UIButton *)button {
    [self.delegate didTouchOnDelete:self];
    [self dismissOptionsAnimated:YES];
}

- (void)_touchOnMore:(UIButton *)button {
    [self.delegate didTouchOnMore:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gesture Methods

- (void)_handleSingleTap:(UIButton *)singleTabButton {
    [self dismissOptionsAnimated:YES];
}


- (void)_handlePanGesture:(UIPanGestureRecognizer *)gesture {
    // Is the cell selected or isEditing set do nothing to prevent undefined behaviour.
    if ( self.selected || self.isEditing )
        return;
    
    CGPoint position = [gesture locationInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.start = position;
            self.scrollViewOptionsView.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:SMMoreOptionsShouldHideNotification object:self];
        } break;
        case UIGestureRecognizerStateChanged: {
            self.scrollViewContentView.center = [self _scrollContentViewCenterForOffset:(self.start.x - position.x)];
        } break;
        case UIGestureRecognizerStateEnded: {
            CGFloat distance = self.start.x - position.x;
            CGFloat threshold = ceilf(_scrollViewOptionsWidth/2.0f);
            
            if ( _optionsFlags.optionsVisible == YES ) {
                if ( fabs(distance) >= threshold ) {
                    [UIView animateWithDuration:SMMoreOptionsAnimationDuration animations:^(void) {
                        self.scrollViewContentView.center = [self _scrollContentViewStartPoint];
                    } completion:^(BOOL finished) {
                        [self _optionsViewDidDisappear];
                    }];
                } else {
                    [UIView animateWithDuration:SMMoreOptionsAnimationDuration animations:^(void) {
                        self.scrollViewContentView.center = [self _scrollContentViewEndPoint];
                    }];
                }
            } else {
                if (  MAX(distance, 0.0f) >= threshold ) {
                    [UIView animateWithDuration:SMMoreOptionsAnimationDuration
                                          delay:0.0f
                         usingSpringWithDamping:0.8f
                          initialSpringVelocity:0.0f
                                        options:0
                                     animations:^(void) {
                                         self.scrollViewContentView.center = [self _scrollContentViewEndPoint];
                                     }
                                     completion:^(BOOL finished) {
                                         [self _optionsViewDidAppear];
                                     }];
                } else {
                    CGPoint center = [self _scrollContentViewStartPoint];
                    if ( CGPointEqualToPoint(center, self.scrollViewContentView.center) ) {
                        // In the case the pan gesture ended at the center point
                        self.scrollViewContentView.center = center;
                        [self _optionsViewDidDisappear];
                    } else {
                        [UIView animateWithDuration:SMMoreOptionsAnimationDuration animations:^(void) {
                            self.scrollViewContentView.center = center;
                        }];
                    }
                }
            }
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            self.scrollViewContentView.center = [self _scrollContentViewStartPoint];
        } break;
        default:
            break;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notification Methods

- (void)_receivedHideNotification:(NSNotification *)ntf {
    if ( ntf.object == self )
        return;
    
    [self dismissOptionsAnimated:YES];
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SMMoreOptionsCellGestureDelegate

- (instancetype)initWithCell:(UITableViewCell *)cell {
    if (self = [super init]) {
        self.cell = cell;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gesture {
    // The cell only reacts on horizontal gestures, otherwise the table will block
    CGPoint translation = [gesture translationInView:self.cell.superview];
    return (fabs(translation.x) > fabs(translation.y));
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIImage (SMMoreOptionsCell)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end