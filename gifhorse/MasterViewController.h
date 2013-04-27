//
//  MasterViewController.h
//  gifhorse
//
//  Created by Jeff Carpenter on 4/27/13.
//  Copyright (c) 2013 Jeff Carpenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
