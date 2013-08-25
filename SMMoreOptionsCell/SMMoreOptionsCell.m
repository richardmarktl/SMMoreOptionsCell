//
//  SMMoreOptionsCell.m
//  iTranslate
//
//  Created by Richard Marktl on 23.08.13.
//
//

#import "SMMoreOptionsCell.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat const SMMoreOptionsDefaultContentWidth = 150.0f;
NSString * const SMMoreOptionsShouldHideNotification = @"SMMoreOptionsHideNotification";


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMMoreOptionsCell () <UIScrollViewDelegate> {
    UITapGestureRecognizer *_tapGesture;
    UIPanGestureRecognizer *_panGesture;
    
    CGPoint _start;
    
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
        self.selectionStyle = UITableViewCellSelectionStyleGray;
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
    _scrollView.bounces = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = NO; // Set NO to enable the tableView:didSelectRowAtIndexPath: behaviour.
    _scrollView.delegate = self;
    [self.contentView addSubview:_scrollView];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    // Is only usable if the userInteractionEnabled property of the scrollview is set to YES.
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    
    // Is only usable if the userInteractionEnabled property of the scrollview is set to NO.
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    _panGesture.minimumNumberOfTouches = 1;
    
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
    [_scrollView setContentOffset:CGPointZero];
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
        targetContentOffset->x = 0.0f;
        
        _scrollView.userInteractionEnabled = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat x = _scrollView.contentOffset.x;
    if ( x < 0 ) {
        [_scrollView setContentOffset:CGPointZero]; // prevent scrolling into the left direction
    }
    
    self.scrollViewOptionsView.frame = CGRectMake(x + CGRectGetWidth(self.contentView.bounds) - _scrollViewOptionsWidth,
                                                  0.0f,
                                                  _scrollViewOptionsWidth,
                                                  CGRectGetHeight(self.contentView.bounds));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ( _scrollView.contentOffset.x == 0.0f ) {
        if ( _optionsFlags.delegateDidHideOptions && _optionsFlags.optionsVisible ) {
            [_delegate cellDidHideOptions:self];
        }
        _scrollViewOptionsView.hidden = YES;
        _optionsFlags.optionsVisible = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ( _scrollView.contentOffset.x == _scrollViewOptionsWidth ) {
        if ( _optionsFlags.delegateDidShowOptions && !_optionsFlags.optionsVisible ) {
            [_delegate cellDidShowOptions:self];
        }
        _optionsFlags.optionsVisible = YES;
    }
    _scrollViewOptionsView.hidden = (scrollView.contentOffset.x == 0.0f);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Action Methods

- (void)_touchOnDelete:(UIButton *)button {
    [_delegate didTouchOnDelete:self];
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)_touchOnMore:(UIButton *)button {
    [_delegate didTouchOnMore:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gesture Methods

- (void)_handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:_scrollView];
    if ( CGRectContainsPoint(_scrollViewContentView.frame, point) ) {
        [_scrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    if ( self.selected ) // Is the cell selected to nothing to prevent undefined behaviour.
        return;
    
    CGPoint position = [recognizer locationInView:self];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _start = position;
            _scrollViewOptionsView.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:SMMoreOptionsShouldHideNotification object:self];
        } break;
        case UIGestureRecognizerStateChanged: {
            [_scrollView setContentOffset:CGPointMake(MAX((_start.x - position.x), 0.0f), 0.0f)];
        } break;
        case UIGestureRecognizerStateEnded: {
            if ( _scrollView.contentOffset.x > ceilf(_scrollViewOptionsWidth/2.0f) ) {
                [_scrollView setContentOffset:CGPointMake(_scrollViewOptionsWidth, 0.0f) animated:YES];
                _scrollView.userInteractionEnabled = YES;
            } else {
                [_scrollView setContentOffset:CGPointZero animated:YES];
                _scrollView.userInteractionEnabled = NO;
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