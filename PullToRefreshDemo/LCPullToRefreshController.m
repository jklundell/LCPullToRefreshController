//
//  LCPullToRefreshController.m
//
//  Created by John Wu on 3/5/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//  Modified by Jonathan Lundell 2013-05
//

#import "LCPullToRefreshController.h"

@interface LCPullToRefreshController ()

// the main object
@property (nonatomic, strong) UIScrollView *scrollView;

// flags to indicate where we are in the refresh sequence
@property (nonatomic, assign) LCRefreshingDirections refreshingDirections;
@property (nonatomic, assign) LCRefreshableDirections refreshableDirections;

@property (nonatomic, weak) id <LCPullToRefreshDelegate> delegate;

// used internally to capture the did end dragging state
@property (nonatomic, assign) BOOL wasDragging;

@property (nonatomic, assign) UIEdgeInsets scrollview_contentinset;
@property (nonatomic, assign) UIEdgeInsets ptr_contentinset;
@property (nonatomic, readonly) UIEdgeInsets netContentInset;

@end

@implementation LCPullToRefreshController

#pragma mark - Object Life Cycle

- (id)initWithScrollView:(UIScrollView *)scrollView delegate:(id <LCPullToRefreshDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.scrollView = scrollView;

        // observe the contentOffset. NSKeyValueObservingOptionPrior is CRUCIAL!
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior context:NULL];

    }
    return self;
}

- (void)dealloc
{
    // basic clean up
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        // for each direction, check to see if refresh sequence needs to be updated.
        for (LCRefreshDirection direction = LCRefreshDirectionTop; direction <= LCRefreshDirectionRight; direction++) {
            BOOL canRefresh = [self.delegate pullToRefreshController:self canRefreshInDirection:direction];
            if (canRefresh)
                [self _checkOffsetsForDirection:direction change:change];
        }

        self.wasDragging = self.scrollView.dragging;
    }
}

#pragma mark - scrollView.contentInset proxy

- (UIEdgeInsets)scrollViewContentInset
{
    return self.scrollview_contentinset;
}

- (void)setScrollViewContentInset:(UIEdgeInsets)scrollViewContentInset
{
    self.scrollview_contentinset = scrollViewContentInset;
    self.scrollView.contentInset = self.netContentInset;
}

- (UIEdgeInsets)netContentInset
{
    return UIEdgeInsetsMake(self.scrollview_contentinset.top + self.ptr_contentinset.top,
                                                    self.scrollview_contentinset.left + self.ptr_contentinset.left,
                                                    self.scrollview_contentinset.bottom + self.ptr_contentinset.bottom,
                                                    self.scrollview_contentinset.right + self.ptr_contentinset.right);
}

#pragma mark - Public Methods

- (void)startRefreshingDirection:(LCRefreshDirection)direction
{
    [self startRefreshingDirection:direction animated:NO];
}

- (void)startRefreshingDirection:(LCRefreshDirection)direction animated:(BOOL)animated
{
    LCRefreshingDirections refreshingDirection = LCRefreshingDirectionNone;
    LCRefreshableDirections refreshableDirection = LCRefreshableDirectionNone;
    UIEdgeInsets contentInset = self.ptr_contentinset;
    CGPoint contentOffset = CGPointZero;

    CGFloat refreshingInset = [self.delegate pullToRefreshController:self refreshingInsetForDirection:direction];

    CGFloat contentSizeArea = self.scrollView.contentSize.width*self.scrollView.contentSize.height;
    CGFloat frameArea = self.scrollView.frame.size.width*self.scrollView.frame.size.height;
    CGSize adjustedContentSize = contentSizeArea < frameArea ? self.scrollView.frame.size : self.scrollView.contentSize;

    switch (direction) {
        case LCRefreshDirectionTop:
            refreshableDirection = LCRefreshableDirectionTop;
            refreshingDirection = LCRefreshingDirectionTop;
            self.ptr_contentinset = UIEdgeInsetsMake(refreshingInset, contentInset.left, contentInset.bottom, contentInset.right);
            contentOffset = CGPointMake(0, -refreshingInset);
            break;
        case LCRefreshDirectionLeft:
            refreshableDirection = LCRefreshableDirectionLeft;
            refreshingDirection = LCRefreshingDirectionLeft;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, refreshingInset, contentInset.bottom, contentInset.right);
            contentOffset = CGPointMake(-refreshingInset, 0);
            break;
        case LCRefreshDirectionBottom:
            refreshableDirection = LCRefreshableDirectionBottom;
            refreshingDirection = LCRefreshingDirectionBottom;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, contentInset.left, refreshingInset, contentInset.right);
            contentOffset = CGPointMake(0, adjustedContentSize.height + refreshingInset);
            break;
        case LCRefreshDirectionRight:
            refreshableDirection = LCRefreshableDirectionRight;
            refreshingDirection = LCRefreshingDirectionRight;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, contentInset.left, contentInset.bottom, refreshingInset);
            contentOffset = CGPointMake(adjustedContentSize.width + refreshingInset, 0);
            break;
    }
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentInset = self.netContentInset;
            self.scrollView.contentOffset = contentOffset;
        }];
    } else {
        self.scrollView.contentInset = self.netContentInset;
        self.scrollView.contentOffset = contentOffset;
    }
    self.refreshingDirections |= refreshingDirection;
    self.refreshableDirections &= ~refreshableDirection;
    if ([self.delegate respondsToSelector:@selector(pullToRefreshController:didEngageRefreshDirection:)]) {
        [self.delegate pullToRefreshController:self didEngageRefreshDirection:direction];
    }
}

- (void)finishRefreshingDirection:(LCRefreshDirection)direction
{
    [self finishRefreshingDirection:direction animated:NO];
}

- (void)finishRefreshingDirection:(LCRefreshDirection)direction animated:(BOOL)animated
{
    LCRefreshingDirections refreshingDirection = LCRefreshingDirectionNone;
    UIEdgeInsets contentInset = self.ptr_contentinset;
    switch (direction) {
        case LCRefreshDirectionTop:
            refreshingDirection = LCRefreshingDirectionTop;
            self.ptr_contentinset = UIEdgeInsetsMake(0, contentInset.left, contentInset.bottom, contentInset.right);
            break;
        case LCRefreshDirectionLeft:
            refreshingDirection = LCRefreshingDirectionLeft;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, contentInset.right);
            break;
        case LCRefreshDirectionBottom:
            refreshingDirection = LCRefreshingDirectionBottom;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, contentInset.left, 0, contentInset.right);
            break;
        case LCRefreshDirectionRight:
            refreshingDirection = LCRefreshingDirectionRight;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, contentInset.left, contentInset.bottom, 0);
            break;
    }
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentInset = self.netContentInset;
        }];
    } else {
        self.scrollView.contentInset = self.netContentInset;
    }
    self.refreshingDirections &= ~refreshingDirection;
}

#pragma mark - Private Methods

- (void)_checkOffsetsForDirection:(LCRefreshDirection)direction change:(NSDictionary *)change
{
    // define some local ivars that disambiguates according to direction
    CGPoint oldOffset = [change[NSKeyValueChangeOldKey] CGPointValue];

    LCRefreshingDirections refreshingDirection = LCRefreshingDirectionNone;
    LCRefreshableDirections refreshableDirection = LCRefreshableDirectionNone;
    BOOL canEngage = NO;
    UIEdgeInsets contentInset = self.ptr_contentinset;

    CGFloat refreshableInset = [self.delegate pullToRefreshController:self refreshableInsetForDirection:direction];
    CGFloat refreshingInset = [self.delegate pullToRefreshController:self refreshingInsetForDirection:direction];

    CGFloat contentSizeArea = self.scrollView.contentSize.width*self.scrollView.contentSize.height;
    CGFloat frameArea = self.scrollView.frame.size.width*self.scrollView.frame.size.height;
    CGSize adjustedContentSize = contentSizeArea < frameArea ? self.scrollView.frame.size : self.scrollView.contentSize;

    switch (direction) {
        case LCRefreshDirectionTop:
            refreshingDirection = LCRefreshingDirectionTop;
            refreshableDirection = LCRefreshableDirectionTop;
            canEngage = oldOffset.y < - refreshableInset;
            self.ptr_contentinset = UIEdgeInsetsMake(refreshingInset, contentInset.left, contentInset.bottom, contentInset.right);
            break;
        case LCRefreshDirectionLeft:
            refreshingDirection = LCRefreshingDirectionLeft;
            refreshableDirection = LCRefreshableDirectionLeft;
            canEngage = oldOffset.x < -refreshableInset;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, refreshingInset, contentInset.bottom, contentInset.right);
            break;
        case LCRefreshDirectionBottom:
            refreshingDirection = LCRefreshingDirectionBottom;
            refreshableDirection = LCRefreshableDirectionBottom;
            canEngage = (oldOffset.y + self.scrollView.frame.size.height - adjustedContentSize.height  > refreshableInset);
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, contentInset.left, refreshingInset, contentInset.right);
            break;
        case LCRefreshDirectionRight:
            refreshingDirection = LCRefreshingDirectionRight;
            refreshableDirection = LCRefreshableDirectionRight;
            canEngage = oldOffset.x + self.scrollView.frame.size.width - adjustedContentSize.width > refreshableInset;
            self.ptr_contentinset = UIEdgeInsetsMake(contentInset.top, contentInset.left, contentInset.bottom, refreshingInset);
            break;
    }

    if (!(self.refreshingDirections & refreshingDirection)) {
        // only go in here if the requested direction is enabled and not refreshing
        if (canEngage) {
            // only go in here if user pulled past the inflection offset
            if (self.wasDragging != self.scrollView.dragging && self.scrollView.decelerating && change[NSKeyValueChangeNotificationIsPriorKey] && (self.refreshableDirections & refreshableDirection)) {

                // if you are decelerating, it means you've stopped dragging.
                self.refreshingDirections |= refreshingDirection;
                self.refreshableDirections &= ~refreshableDirection;
                self.scrollView.contentInset = self.netContentInset;
                if ([self.delegate respondsToSelector:@selector(pullToRefreshController:didEngageRefreshDirection:)]) {
                    [self.delegate pullToRefreshController:self didEngageRefreshDirection:direction];
                }
            } else if (self.scrollView.dragging && !self.scrollView.decelerating && !(self.refreshableDirections & refreshableDirection)) {
                // only go in here the first time you've dragged past releasable offset
                self.refreshableDirections |= refreshableDirection;
                if ([self.delegate respondsToSelector:@selector(pullToRefreshController:canEngageRefreshDirection:)]) {
                    [self.delegate pullToRefreshController:self canEngageRefreshDirection:direction];
                }
            }
        } else if ((self.refreshableDirections & refreshableDirection) ) {
            // if you're here it means you've crossed back from the releasable offset
            self.refreshableDirections &= ~refreshableDirection;
            if ([self.delegate respondsToSelector:@selector(pullToRefreshController:didDisengageRefreshDirection:)]) {
                [self.delegate pullToRefreshController:self didDisengageRefreshDirection:direction];
            }
        }
    }
}

@end
