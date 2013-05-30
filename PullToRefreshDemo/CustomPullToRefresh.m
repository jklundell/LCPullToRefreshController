//
//  CustomPullToRefresh.m
//  PullToRefreshDemo
//
//  Created by John Wu on 3/22/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "CustomPullToRefresh.h"

@interface CustomPullToRefresh ()

@property (nonatomic, strong) UIImageView *rainbowTop;
@property (nonatomic, strong) UIImageView *rainbowBot;
@property (nonatomic, strong) UIImageView *arrowTop;
@property (nonatomic, strong) UIImageView *arrowBot;

@property (nonatomic, strong) LCPullToRefreshController *ptrc;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) id <CustomPullToRefreshDelegate> delegate;

@end

@implementation CustomPullToRefresh

- (id)initWithScrollView:(UIScrollView *)scrollView delegate:(id<CustomPullToRefreshDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.scrollView = scrollView;
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];

        self.ptrc = [[LCPullToRefreshController alloc] initWithScrollView:self.scrollView delegate:self];

        NSMutableArray *animationImages = [NSMutableArray arrayWithCapacity:19];
        for (int i=1; i<20; i++)
            [animationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading-%d.png",i]]];

        self.rainbowTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading-1.png"]];
        self.rainbowTop.frame = CGRectMake(0, -self.scrollView.frame.size.height, self.scrollView.frame.size.width, scrollView.frame.size.height);
        self.rainbowTop.animationImages = animationImages;
        self.rainbowTop.animationDuration = 2;
        [scrollView addSubview:self.rainbowTop];

        self.rainbowBot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading-1.png"]];
        self.rainbowBot.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.rainbowBot.frame = CGRectMake(0, self.scrollView.frame.size.height, self.scrollView.frame.size.width, scrollView.frame.size.height);
        self.rainbowBot.animationImages = animationImages;
        self.rainbowBot.animationDuration = 2;
        [scrollView addSubview:self.rainbowBot];

        self.arrowTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_arrow.png"]];
        self.arrowTop.frame = CGRectMake(floorf((self.rainbowTop.frame.size.width-self.arrowTop.frame.size.width)/2), self.rainbowTop.frame.size.height - self.arrowTop.frame.size.height - 10 , self.arrowTop.frame.size.width, self.arrowTop.frame.size.height);
        [self.rainbowTop addSubview:self.arrowTop];

        self.arrowBot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_arrow.png"]];
        self.arrowBot.frame = CGRectMake(floorf((self.rainbowBot.frame.size.width-self.arrowBot.frame.size.width)/2), 10 , self.arrowBot.frame.size.width, self.arrowBot.frame.size.height);
        self.arrowBot.transform  = CGAffineTransformMakeRotation(M_PI);
        [self.rainbowBot addSubview:self.arrowBot];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@",NSStringFromCGSize(self.scrollView.contentSize));
    CGFloat contentSizeArea = self.scrollView.contentSize.width*self.scrollView.contentSize.height;
    CGFloat frameArea = self.scrollView.frame.size.width*self.scrollView.frame.size.height;
    CGSize adjustedContentSize = contentSizeArea < frameArea ? self.scrollView.frame.size : self.scrollView.contentSize;
    self.rainbowBot.frame = CGRectMake(0, adjustedContentSize.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)endRefresh
{
    [self.ptrc finishRefreshingDirection:LCRefreshDirectionTop animated:YES];
    [self.ptrc finishRefreshingDirection:LCRefreshDirectionBottom animated:YES];
    [self.rainbowTop stopAnimating];
    [self.rainbowBot stopAnimating];
    self.arrowBot.hidden = NO;
    self.arrowBot.transform  = CGAffineTransformMakeRotation(M_PI);
    self.arrowTop.hidden = NO;
    self.arrowTop.transform = CGAffineTransformIdentity;
}

- (void)startRefresh
{
    [self.ptrc startRefreshingDirection:LCRefreshDirectionTop];
}

#pragma mark - LCPullToRefreshDelegate Methods

- (BOOL)pullToRefreshController:(LCPullToRefreshController *)controller canRefreshInDirection:(LCRefreshDirection)direction
{
    return direction == LCRefreshDirectionTop || direction == LCRefreshDirectionBottom;
}

- (CGFloat)pullToRefreshController:(LCPullToRefreshController *)controller refreshingInsetForDirection:(LCRefreshDirection)direction
{
    return 30;
}

- (CGFloat)pullToRefreshController:(LCPullToRefreshController *)controller refreshableInsetForDirection:(LCRefreshDirection)direction
{
    return 30;
}

- (void)pullToRefreshController:(LCPullToRefreshController *)controller canEngageRefreshDirection:(LCRefreshDirection)direction
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.arrowTop.transform = CGAffineTransformMakeRotation(M_PI);
    self.arrowBot.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

- (void)pullToRefreshController:(LCPullToRefreshController *)controller didDisengageRefreshDirection:(LCRefreshDirection)direction
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.arrowTop.transform = CGAffineTransformIdentity;
    self.arrowBot.transform  = CGAffineTransformMakeRotation(M_PI);
    [UIView commitAnimations];
}

- (void)pullToRefreshController:(LCPullToRefreshController *)controller didEngageRefreshDirection:(LCRefreshDirection)direction
{
    self.arrowTop.hidden = YES;
    self.arrowBot.hidden = YES;
    [self.rainbowTop startAnimating];
    [self.rainbowBot startAnimating];
    [self.delegate customPullToRefreshShouldRefresh:self];
}

@end
