//
//  LCPullToRefreshController.h
//
//  Created by John Wu on 3/5/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//  Modified by Jonathan Lundell 2013-05
//

/**************************||||-ABSTRACT-||||**********************************
 *
 *  This is the a generic pull-to-refresh library.
 *
 *  This library attempts to abstract away the core pull-
 *  to-refresh logic, and allow the users to implement custom
 *  views on top and update them at key points in the refresh cycle.
 *
 *  Hence, this class is NOT meant to be used directly. You
 *  are meant to write a wrapper which uses this class to implement
 *  your own pull-to-refresh solutions.
 *  
 *  Instead of overriding the delegate like most PTF libraries,
 *  we merely observe the contentOffset property of the scrollview
 *  using KVO.
 *
 *  This library allows refreshing in any direction and/or any combination
 *  of directions.
 *
 *  It is up to the user to inform the library when to end a refresh sequence
 *  for each direction.
 *
 *  Do NOT use a scrollview with a contentSize that is smaller than the frame.
 *
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>

/**
 * flags that determine the directions that can be engaged.
 */
typedef enum {
    LCRefreshableDirectionNone    = 0,
    LCRefreshableDirectionTop     = 1 << 0,
    LCRefreshableDirectionLeft    = 1 << 1,
    LCRefreshableDirectionBottom  = 1 << 2,
    LCRefreshableDirectionRight   = 1 << 3
} LCRefreshableDirections;

/**
 * flags that determine the directions that are currently refreshing.
 */
typedef enum {
    LCRefreshingDirectionNone    = 0,
    LCRefreshingDirectionTop     = 1 << 0,
    LCRefreshingDirectionLeft    = 1 << 1,
    LCRefreshingDirectionBottom  = 1 << 2,
    LCRefreshingDirectionRight   = 1 << 3
} LCRefreshingDirections;

/**
 * simple enum that specifies the direction related to delegate callbacks.
 */
typedef enum {
    LCRefreshDirectionTop = 0,
    LCRefreshDirectionLeft,
    LCRefreshDirectionBottom,
    LCRefreshDirectionRight
} LCRefreshDirection;

@protocol LCPullToRefreshDelegate;

@interface LCPullToRefreshController : NSObject

/*
 * the only constructor you should use.
 * pass in the scrollview to be observed and
 * the delegate to receive call backs
 */
- (id)initWithScrollView:(UIScrollView *)scrollView delegate:(id <LCPullToRefreshDelegate>)delegate;

/*
 * Call this function with a direction to end the refresh sequence
 * in that direction. With or without animation.
 */
- (void)finishRefreshingDirection:(LCRefreshDirection)direction animated:(BOOL)animated;

/*
 * calls the above with animated = NO
 */
- (void)finishRefreshingDirection:(LCRefreshDirection)direction;

/*
 * Programmatically start a refresh in the given direction, animated or not.
 */
- (void)startRefreshingDirection:(LCRefreshDirection)direction animated:(BOOL)animated;

/*
 * calls the above with animated = NO
 */
- (void)startRefreshingDirection:(LCRefreshDirection)direction;

@end

@protocol LCPullToRefreshDelegate <NSObject>

@required

/*
 * asks the delegate which refresh directions it would like enabled
 */
- (BOOL)pullToRefreshController:(LCPullToRefreshController *)controller canRefreshInDirection:(LCRefreshDirection)direction;

/*
 * inset threshold to engage refresh
 */
- (CGFloat)pullToRefreshController:(LCPullToRefreshController *)controller refreshableInsetForDirection:(LCRefreshDirection)direction;

/*
 * inset that the direction retracts back to after refresh started
 */
- (CGFloat)pullToRefreshController:(LCPullToRefreshController *)controller refreshingInsetForDirection:(LCRefreshDirection)direction;

@optional

/*
 * informs the delegate that lifting your finger will trigger a refresh
 * in that direction. This is only called when you cross the refreshable
 * offset defined in the respective LCInflectionOffsets.
 */
- (void)pullToRefreshController:(LCPullToRefreshController *)controller canEngageRefreshDirection:(LCRefreshDirection)direction;

/*
 * informs the delegate that lifting your finger will NOT trigger a refresh
 * in that direction. This is only called when you cross the refreshable
 * offset defined in the respective LCInflectionOffsets.
 */
- (void)pullToRefreshController:(LCPullToRefreshController *)controller didDisengageRefreshDirection:(LCRefreshDirection)direction;

/*
 * informs the delegate that refresh sequence has been started by the user
 * in the specified direction. A good place to start any async work.
 */
- (void)pullToRefreshController:(LCPullToRefreshController *)controller didEngageRefreshDirection:(LCRefreshDirection)direction;

@end
