//
//  CustomPullToRefresh.m
//  PullToRefreshDemo
//
//  Created by John Wu on 3/22/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "CustomPullToRefresh.h"

@interface CustomPullToRefresh ()

@property (nonatomic, weak) UIView *viewTop;
@property (nonatomic, weak) UIView *viewBot;
@property (nonatomic, weak) UIActivityIndicatorView *aiTop;
@property (nonatomic, weak) UIActivityIndicatorView *aiBot;
@property (nonatomic, weak) UIImageView *arrowTop;
@property (nonatomic, weak) UIImageView *arrowBot;

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

        CGRect frame = self.scrollView.frame;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height)];
        view.backgroundColor = [UIColor grayColor];
        [self.scrollView addSubview:view];
        self.viewTop = view;
        
        frame = CGRectMake(0, frame.size.height, frame.size.width, frame.size.height);
        view = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
        view.backgroundColor = [UIColor grayColor];
        [self.scrollView addSubview:view];
        self.viewBot = view;
        
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        frame = aiView.frame;
        frame.origin.x = floorf((self.viewTop.frame.size.width - frame.size.width) / 2);
        frame.origin.y = self.viewTop.frame.size.height - frame.size.height - 10;
        aiView.frame = frame;
        [self.viewTop addSubview:aiView];
        self.aiTop = aiView;
        
        aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        frame = aiView.frame;
        frame.origin.x = floorf((self.viewBot.frame.size.width - frame.size.width) / 2);
        frame.origin.y = 10;
        aiView.frame = frame;
        [self.viewBot addSubview:aiView];
        self.aiBot = aiView;
       
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_arrow.png"]]; // 19x13
        frame = imageView.frame;
        frame.origin.x = floorf((self.viewTop.frame.size.width - frame.size.width) / 2);
        frame.origin.y = self.aiTop.frame.origin.y + floorf((self.aiTop.frame.size.height - frame.size.height) / 2);
        imageView.frame = frame;
        [self.viewTop addSubview:imageView];
        self.arrowTop = imageView;

        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_arrow.png"]];
        frame = imageView.frame;
        frame.origin.x = floorf((self.viewBot.frame.size.width - frame.size.width) / 2);
        frame.origin.y = self.aiBot.frame.origin.y + floorf((self.aiBot.frame.size.height - frame.size.height) / 2);
        imageView.frame = frame;
        imageView.transform  = CGAffineTransformMakeRotation(M_PI);
        [self.viewBot addSubview:imageView];
        self.arrowBot = imageView;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@",NSStringFromCGSize(self.scrollView.contentSize));
    CGFloat contentSizeArea = self.scrollView.contentSize.width*self.scrollView.contentSize.height;
    CGFloat frameArea = self.scrollView.frame.size.width*self.scrollView.frame.size.height;
    CGSize adjustedContentSize = contentSizeArea < frameArea ? self.scrollView.frame.size : self.scrollView.contentSize;
    self.viewBot.frame = CGRectMake(0, adjustedContentSize.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)endRefresh
{
    [self.ptrc finishRefreshingDirection:LCRefreshDirectionTop animated:YES];
    [self.ptrc finishRefreshingDirection:LCRefreshDirectionBottom animated:YES];
    [self.aiTop stopAnimating];
    [self.aiBot stopAnimating];
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
    return self.aiTop.bounds.size.height + 20;
}

- (CGFloat)pullToRefreshController:(LCPullToRefreshController *)controller refreshableInsetForDirection:(LCRefreshDirection)direction
{
    return self.aiTop.bounds.size.height + 20;
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
    [self.aiTop startAnimating];
    [self.aiBot startAnimating];
    [self.delegate customPullToRefreshShouldRefresh:self];
}

@end
