//
//  ViewController.m
//  PullToRefreshDemo
//
//  Created by John Wu on 3/22/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "ViewController.h"
#import "LCPullToRefreshController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *primes;
@property (nonatomic, strong) CustomPullToRefresh *ptr;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.primes = [[NSMutableArray alloc] initWithObjects:@2ULL, nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.ptr)
        self.ptr = [[CustomPullToRefresh alloc] initWithScrollView:self.table delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.ptr = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)isPrime:(unsigned long long)input
{
    for (unsigned long long i = 2; i < input/2+1; i++) {
        if (input % i == 0)
            return NO;
    }
    return YES;
}

#pragma mark - UITableView Delegate Methods

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.primes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    cell.textLabel.text = [self.primes[indexPath.row] stringValue];
    
    return cell;
}

#pragma mark - CustomPullToRefresh Delegate Methods

- (void)customPullToRefreshShouldRefresh:(CustomPullToRefresh *)ptr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        unsigned long long potentialPrime;
        @autoreleasepool {
            unsigned long long lastPrime = [[self.primes lastObject] unsignedLongLongValue];
            potentialPrime = lastPrime + 1;
            while ( [self isPrime:potentialPrime] == NO )
                potentialPrime++;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self.primes addObject:@(potentialPrime)];
            [self.ptr endRefresh];
            [self.table reloadData];
        });
    });
}



@end
