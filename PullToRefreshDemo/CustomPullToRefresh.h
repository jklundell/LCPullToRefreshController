//
//  CustomPullToRefresh.h
//  PullToRefreshDemo
//
//  Created by John Wu on 3/22/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCPullToRefreshController.h"

@protocol CustomPullToRefreshDelegate;

@interface CustomPullToRefresh : NSObject <LCPullToRefreshDelegate>

- (id)initWithScrollView:(UIScrollView *)scrollView delegate:(id <CustomPullToRefreshDelegate>)delegate;
- (void)endRefresh;
- (void)startRefresh;

@end

@protocol CustomPullToRefreshDelegate <NSObject>

- (void)customPullToRefreshShouldRefresh:(CustomPullToRefresh *)ptr;

@end