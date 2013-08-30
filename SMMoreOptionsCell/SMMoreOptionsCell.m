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
NSString * const SMMoreOptionsShouldHideNotification = @"SMMoreOptionsHideNotification";


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMMoreOptionsCellGestureDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UITableViewCell *cell;

- (instancetype)initWithCell:(UITableViewCell *)cell;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMMoreOptionsCell () <UIScrollViewDelegate> {
    UITapGestureRecognizer *_tapGesture;
    UIPanGestureRecognizer *_panGesture;
    
    CGPoint _start;
    SMMoreOptionsCellGestureDelegate *_gestureDelegate;
    
    struct {
        unsigned int delegateDidHideOptions:1;
        unsigned int delegateDidShowOptions:1;
        unsigned int optionsVisible:1;
    } _optionsFlags;
}

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
    [_scrollView addSubview:_scrollViewContentView];
    [self setNeedsLayout];
}

- (void)setScrollViewOptionsView:(UIView *)optionsContentView {
    if ( _scrollViewOptionsView == optionsContentView )
        return;
    
    [_scrollViewOptionsView removeFromSuperview];  // remove the old view
    
    _scrollViewOptionsView = optionsContentView;
    _scrollViewOptionsView.hidden = !_optionsFlags.optionsVisible;
    [_scrollView insertSubview:_scrollViewOptionsView atIndex:0];
    [self setNeedsLayout];
}

- (void)setDeleteButton:(UIButton *)deleteButton {
    if ( _deleteButton == deleteButton )
        return;
    [_deleteButton removeFromSuperview];
    
    _deleteButton = deleteButton;
    [_deleteButton addTarget:self action:@selector(_touchOnDelete:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollViewOptionsView addSubview:_deleteButton];
    [self setNeedsLayout];
}

- (void)setMoreButton:(UIButton *)moreButton {
    if ( _moreButton == moreButton )
        return;
    [_moreButton removeFromSuperview];
    
    _moreButton = moreButton;
    [_moreButton addTarget:self action:@selector(_touchOnMore:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollViewOptionsView addSubview:_moreButton];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeCellContent];
}

- (void)initializeCellContent {
    _scrollViewOptionsWidth = SMMoreOptionsDefaultContentWidth;
    _optionsFlags.optionsVisible = NO;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.directionalLockEnabled = YES;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = NO; // Set NO to enable the tableView:didSelectRowAtIndexPath: behaviour.
    _scrollView.delegate = self;
    [self.contentView addSubview:_scrollView];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    // The cell is already delegate of some gesture recognizer classes and to prevent conflicts use this object.
    _gestureDelegate = [[SMMoreOptionsCellGestureDelegate alloc] initWithCell:self];
    
    // Is only usable if the userInteractionEnabled property of the scrollview is set to YES.
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    
    // Is only usable if the userInteractionEnabled property of the scrollview is set to NO.
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    _panGesture.minimumNumberOfTouches = 1;
    _panGesture.delegate = _gestureDelegate;
    
    self.scrollViewContentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.scrollViewContentView.backgroundColor = [UIColor whiteColor];
    
    self.scrollViewOptionsView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
    
    [_scrollView addSubview:self.scrollViewContentView];
    [_scrollView addGestureRecognizer:_tapGesture];
    [self.contentView addGestureRecognizer:_panGesture];
    
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
    _scrollView.frame = bounds;
    _scrollView.contentSize = CGSizeMake(bounds.size.width + _scrollViewOptionsWidth, bounds.size.height);
    _scrollView.contentInset = UIEdgeInsetsMake(0.0f, _scrollViewOptionsWidth, 0.0f, 0.0f);
    
    self.scrollViewContentView.frame = bounds;
    
    CGFloat buttonWidth = ceilf(_scrollViewOptionsWidth/2);
    self.moreButton.frame = CGRectMake(0.0f, 0.0f, buttonWidth, bounds.size.height);
    self.deleteButton.frame = CGRectMake(buttonWidth, 0.0f, buttonWidth, bounds.size.height);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _scrollView.contentOffset = CGPointZero;
    _scrollView.userInteractionEnabled = NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if ( _optionsFlags.optionsVisible ) {
        [_scrollView setContentOffset:CGPointZero animated:animated];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods 

- (void)_optionsViewDidDisappear {
    if ( _optionsFlags.delegateDidHideOptions && _optionsFlags.optionsVisible ) {
        [_delegate cellDidHideOptions:self];
    }
    
    _optionsFlags.optionsVisible = NO;
    _panGesture.enabled = YES;
    _scrollViewOptionsView.hidden = YES;
    _scrollView.userInteractionEnabled = NO;
}

- (void)_optionsViewDidAppear {
    if ( _optionsFlags.delegateDidShowOptions && !_optionsFlags.optionsVisible ) {
        [_delegate cellDidShowOptions:self];
    }
    
    _optionsFlags.optionsVisible = YES;
    _panGesture.enabled = NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

- (void)dismissOptionsAnimated:(BOOL)animated {
    [_scrollView setContentOffset:CGPointZero animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ( targetContentOffset->x > ceilf(_scrollViewOptionsWidth/2.0f) ) {
        targetContentOffset->x = _scrollViewOptionsWidth;
        
        _scrollView.userInteractionEnabled = YES;
    } else {
        if ( targetContentOffset->x <= 0.0f && _scrollView.contentOffset.x <= 0.0f ) {
            
            [self _optionsViewDidDisappear];
        } else {
            targetContentOffset->x = 0.0f;

            _scrollView.userInteractionEnabled = NO;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat x = _scrollView.contentOffset.x;
    CGRect bounds = self.contentView.bounds;
    if ( x < 0 ) {
        [_scrollView setContentOffset:CGPointZero]; // prevent scrolling into the left direction
    }
    
    if ( self.isEditing )
        return;
    
    self.scrollViewOptionsView.frame = CGRectMake((x + bounds.size.width) - _scrollViewOptionsWidth,
                                                  0.0f,
                                                  _scrollViewOptionsWidth,
                                                  bounds.size.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ( _scrollView.contentOffset.x == 0.0f ) {
        [self _optionsViewDidDisappear];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ( _scrollView.contentOffset.x == _scrollViewOptionsWidth ) {
        [self _optionsViewDidAppear];
    } else if ( _scrollView.contentOffset.x == 0.0f ) {
        [self _optionsViewDidDisappear];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Action Methods

- (void)_touchOnDelete:(UIButton *)button {
    [_delegate didTouchOnDelete:self];
    [self dismissOptionsAnimated:YES];
}

- (void)_touchOnMore:(UIButton *)button {
    [_delegate didTouchOnMore:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gesture Methods

- (void)_handleSingleTap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_scrollView];
    if ( CGRectContainsPoint(_scrollViewContentView.frame, point) ) {
        [self dismissOptionsAnimated:YES];
    }
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)gesture {
    // Is the cell selected or isEditing set do nothing to prevent undefined behaviour.
    if ( self.selected || self.isEditing || _optionsFlags.optionsVisible)
        return;
    
    CGPoint position = [gesture locationInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _start = position;
            _scrollViewOptionsView.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:SMMoreOptionsShouldHideNotification object:self];
        } break;
        case UIGestureRecognizerStateChanged: {
            [_scrollView setContentOffset:CGPointMake(MAX((_start.x - position.x), 0.0f), 0.0f)];
        } break;
        case UIGestureRecognizerStateEnded: {
            if ( _scrollView.contentOffset.x >= ceilf(_scrollViewOptionsWidth/2.0f) ) {
                [_scrollView setContentOffset:CGPointMake(_scrollViewOptionsWidth, 0.0f) animated:YES];
                _scrollView.userInteractionEnabled = YES;
            } else {
                if ( _scrollView.contentOffset.x == 0.0f ) {
                    [self _optionsViewDidDisappear]; // In the case the pan gesture ended at 0.0
                } else {
                    [_scrollView setContentOffset:CGPointZero animated:YES];
                    _scrollView.userInteractionEnabled = NO;
                }
            }
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [_scrollView setContentOffset:CGPointZero animated:YES];
            _scrollView.userInteractionEnabled = NO;
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
    
    [_scrollView setContentOffset:CGPointZero animated:YES];
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
    return (fabsf(translation.x) > fabsf(translation.y));
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