//
//  DetailViewController.h
//  gifhorse
//
//  Created by Jeff Carpenter on 4/27/13.
//  Copyright (c) 2013 Jeff Carpenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
