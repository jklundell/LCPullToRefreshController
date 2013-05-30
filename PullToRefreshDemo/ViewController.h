//
//  ViewController.h
//  PullToRefreshDemo
//
//  Created by John Wu on 3/22/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPullToRefresh.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomPullToRefreshDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;

@end
