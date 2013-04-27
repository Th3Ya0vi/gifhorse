//
//  AppDelegate.m
//  Gif Horse
//
//  Created by Jeff Carpenter on 1/22/13.
//  Copyright (c) 2013 Jeff Carpenter. All rights reserved.
//

#import "AppDelegate.h"
#import "GifViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) GifViewController *gifViewController;
@property (nonatomic, strong) UINavigationController *navController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    self.navController = [[UINavigationController alloc] init];
    self.window.rootViewController = self.navController;
    
    self.gifViewController = [[GifViewController alloc] init];
    NSArray *viewControllers = @[self.gifViewController];
    [self.navController setViewControllers:viewControllers];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.gifViewController storeCurrentSequence];
}

@end
