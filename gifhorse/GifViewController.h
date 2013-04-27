//
//  GifViewController.h
//  Gif Horse
//
//  Created by Jeff Carpenter on 1/22/13.
//  Copyright (c) 2013 Jeff Carpenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifViewController : UIViewController

- (void)fetchAndSetCurrentSequence;
- (void)storeCurrentSequence;

@end
