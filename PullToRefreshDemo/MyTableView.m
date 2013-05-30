//
//  MyTableView.m
//  PullToRefreshDemo
//
//  Created by John Z Wu on 9/23/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "MyTableView.h"

@implementation MyTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setContentSize:(CGSize)contentSize
{
    CGFloat contentSizeArea = contentSize.width*contentSize.height;
    CGFloat frameArea = self.frame.size.width*self.frame.size.height;
    CGSize adjustedContentSize = contentSizeArea < frameArea ? self.frame.size : contentSize;
    [super setContentSize:adjustedContentSize];
}

@end
