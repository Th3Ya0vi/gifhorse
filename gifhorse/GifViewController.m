//
//  GifViewController.m
//  Gif Horse
//
//  Created by Jeff Carpenter on 1/22/13.
//  Copyright (c) 2013 Jeff Carpenter. All rights reserved.
//

//#define SERVER_URI @"http://gifhor.se/"
//#define SERVER_URI @"http://localhost:3000/"
#define SERVER_URI @"http://10.0.1.20:3000/"

#import "GifViewController.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface GifViewController () <UIWebViewDelegate, UIScrollViewDelegate>

// Confirmed being used
@property (nonatomic, strong) UIScrollView *gifNav;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIView *infoView;

@property (nonatomic, strong) NSMutableArray *gifViews;

@property NSInteger sequence;
@property NSInteger infoHeight;
@property (nonatomic, strong) NSString *uuid;

// Unconfirmed

@property (nonatomic, strong) NSMutableDictionary *gifs;
@property (nonatomic, strong) UILabel *currentSequenceLabel;


@property BOOL favButtonOn;

@property int requestsActive;
@end

@implementation GifViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"gifHorseNav3.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.gifs = [[NSMutableDictionary alloc] init];
    self.gifViews = [[NSMutableArray alloc] init];
    
    [self setupGifNav];
    // [self setupGifInfo]; // Temporarily disabled while I figure out :favorited data transfer
    
    [self fetchAndSetCurrentSequence];
    [self fetchAndSetUuid];
    
    
    [self refreshAllWindows];
}

- (void)refreshAllWindows
{
    [self displayGifInWindow:0 withSequence:self.sequence-1];
    [self displayGifInWindow:1 withSequence:self.sequence];
    [self displayGifInWindow:2 withSequence:self.sequence+1];
}




# pragma mark - unconfirmed methods

# pragma mark - Navigation actions

- (void)displayGifInWindow:(NSInteger)window withSequence:(NSInteger)sequence
{
    
    
    NSString *urlString = [NSString stringWithFormat: @"%@%@%@%@%@", SERVER_URI, @"users/", self.uuid, @"/pages/", [NSString stringWithFormat:@"%i", sequence]];
    NSLog(@"%@", urlString);
    [[self.gifViews objectAtIndex:window] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    //    // Note: index is not the same as sequence. We're assuming it is for now, since we'll always start at sequence = 0
    //    // index != sequence != page
    //    int sequence_int = self.sequence;
    //    if ([index isEqualToNumber:[NSNumber numberWithInt:0]]) {
    //        sequence_int -= 1;
    //    } else if ([index isEqualToNumber:[NSNumber numberWithInt:2]]) {
    //        sequence_int += 1;
    //    }
    //    NSNumber *sequence = [NSNumber numberWithInt:sequence_int];
    ////    NSLog(@"sequence requested: %d", sequence_int);
    //    // Todo: immediately make a key for this page in self.pages, so that multiple requests don't try to load the same page
    //
    //    NSString *protoUrl = [SERVER_URI stringByAppendingString:[NSString stringWithFormat:@"api/%@/%d", self.userID, [sequence intValue]]];
    //    NSURL *afurl = [NSURL URLWithString:protoUrl];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:afurl];
    //    self.requestsActive += 1;
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    //
    //        NSDictionary *data = [JSON objectForKey:@"gif"];
    //
    //        // Add returned data to Gifs dictionary
    //        NSNumber *sequence_id = [NSNumber numberWithInt:sequence_int];
    //        [self.gifs setObject:data forKey:sequence_id];
    //
    ////        NSLog(@"%@", [data objectForKey:@"id"]);
    //
    //        NSNumber *gif_id = [data objectForKey:@"id"];
    //        [self loadGif:gif_id IntoGifNavAtIndex:[index intValue]];
    //
    //        if (sequence_int == 1) {
    //            [self setInfoForGifOnSequence:[NSNumber numberWithInt:1]];
    //        }
    //
    //    } failure:nil];
    //    [operation start];
}

# pragma mark - Data Fetching Operations



# pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.requestsActive -= 1;
    if (self.requestsActive == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollViewPassed
{
    //    CGFloat pageWidth = scrollViewPassed.frame.size.width;
    //    float fractionalPage = scrollViewPassed.contentOffset.x / pageWidth;
    //    NSNumber *page = [NSNumber numberWithInt:lround(fractionalPage)];
    //
    //    if ([page intValue] != self.sequence) {
    //        self.sequence = [page intValue];
    //        NSLog(@"New sequence: %i", [page intValue]);
    //    }
    //    if ([page intValue] == 0) {
    //        [self setInfoForGifOnSequence:[NSNumber numberWithInt:(self.sequence - 1)]];
    //    } else if ([page intValue] == 1) {
    //        [self setInfoForGifOnSequence:[NSNumber numberWithInt:(self.sequence)]];
    //    } else if ([page intValue] == 2) {
    //        [self setInfoForGifOnSequence:[NSNumber numberWithInt:(self.sequence + 1)]];
    //    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    // Wuuuut why are we comparing floats to ints
    float fractionalPage = sender.contentOffset.x / sender.frame.size.width;
    NSLog(@"Stopped at page: %i", (int)fractionalPage);
    
    // If we moved forward or backward, update content on each page
    if (fractionalPage == 2) {
        // Increment self.sequence
        self.sequence += 1;
        [self storeCurrentSequence];

        // Cycle gifViews forward 1
        UIWebView *gifViewAtPage0 = [self.gifViews objectAtIndex:0];
        UIWebView *gifViewAtPage1 = [self.gifViews objectAtIndex:1];
        UIWebView *gifViewAtPage2 = [self.gifViews objectAtIndex:2];
        [self.gifViews setObject:gifViewAtPage0 atIndexedSubscript:2];
        [self.gifViews setObject:gifViewAtPage1 atIndexedSubscript:0];
        [self.gifViews setObject:gifViewAtPage2 atIndexedSubscript:1];
        
        // Cycle views forward 1
        [gifViewAtPage0 setFrame:CGRectMake(self.view.bounds.size.width*2, 0, gifViewAtPage0.frame.size.width, gifViewAtPage0.frame.size.height)];
        [gifViewAtPage1 setFrame:CGRectMake(self.view.bounds.size.width*0, 0, gifViewAtPage1.frame.size.width, gifViewAtPage1.frame.size.height)];
        [gifViewAtPage2 setFrame:CGRectMake(self.view.bounds.size.width*1, 0, gifViewAtPage2.frame.size.width, gifViewAtPage2.frame.size.height)];

        [self displayGifInWindow:2 withSequence:self.sequence+1];
        
        // Reset back to middle page
        [self.gifNav setContentOffset:CGPointMake(sender.frame.size.width, 0)];
        
    } else if (fractionalPage == 0) {
        if (self.sequence > 0) {
            // Decrement self.sequence
            self.sequence -= 1;
            [self storeCurrentSequence];

            // Cycle gifViews backward 1
            UIWebView *gifViewAtPage0 = [self.gifViews objectAtIndex:0];
            UIWebView *gifViewAtPage1 = [self.gifViews objectAtIndex:1];
            UIWebView *gifViewAtPage2 = [self.gifViews objectAtIndex:2];
            [self.gifViews setObject:gifViewAtPage0 atIndexedSubscript:1];
            [self.gifViews setObject:gifViewAtPage1 atIndexedSubscript:2];
            [self.gifViews setObject:gifViewAtPage2 atIndexedSubscript:0];
            
            // Cycle views backward 1
            [gifViewAtPage0 setFrame:CGRectMake(self.view.bounds.size.width*1, 0, gifViewAtPage0.frame.size.width, gifViewAtPage0.frame.size.height)];
            [gifViewAtPage1 setFrame:CGRectMake(self.view.bounds.size.width*2, 0, gifViewAtPage1.frame.size.width, gifViewAtPage1.frame.size.height)];
            [gifViewAtPage2 setFrame:CGRectMake(self.view.bounds.size.width*0, 0, gifViewAtPage2.frame.size.width, gifViewAtPage2.frame.size.height)];
            
            [self displayGifInWindow:0 withSequence:self.sequence-1];
            
            // Reset back to middle page
            [self.gifNav setContentOffset:CGPointMake(sender.frame.size.width, 0)];
        }
    }
}

# pragma mark - Target action... targets

- (void)favButtonWasPressed:(id)sender
{
//    UIButton *resultButton = (UIButton *)sender;
//    [resultButton setTitle:@"Loading..." forState:UIControlStateNormal];
//    
//    // Activate spinner
//    NSLog(@"%d", self.favButtonOn);
//    if (self.favButtonOn == NO) {
//        
    
        
//        NSString *protoPath = [NSString stringWithFormat:@"/pages/%@/%d/%d", self.userID, (int)self.sequence, 1];
        
//        NSURL *afUrl = [NSURL URLWithString:SERVER_URI];
//        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:afUrl];
        
        //        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        //                                @"height", @"user[height]",
        //                                @"weight", @"user[weight]",
        //                                nil];
//        [httpClient postPath:protoPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        
//            NSMutableDictionary *gifData = [NSMutableDictionary dictionaryWithDictionary:[self.gifs objectForKey:[NSNumber numberWithInt:(int)self.sequence]]];
//            //NSLog(@"%@", gifData);
//            [gifData setValue:@1 forKey:@"favorited"];
//            //NSLog(@"%@", gifData);
//            [self.gifs setValue:gifData forKey:[NSString stringWithFormat:@"%d", (int)self.sequence]];
//            
//            //            NSLog(@"Request Successful, response '%@'", responseStr);
//            [resultButton setTitle:@"Favorited" forState:UIControlStateNormal];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
//            [resultButton setTitle:@"Error" forState:UIControlStateNormal];
//        }];
//        
//    } else {
//        
//        NSString *protoPath = [NSString stringWithFormat:@"/pages/%@/%d/%d", self.userID, (int)self.sequence, 0];
//        
//        NSURL *afUrl = [NSURL URLWithString:SERVER_URI];
//        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:afUrl];
        
        //        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        //                                @"height", @"user[height]",
        //                                @"weight", @"user[weight]",
        //                                nil];
//        [httpClient postPath:protoPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//            
//            NSMutableDictionary *gifData = [NSMutableDictionary dictionaryWithDictionary:[self.gifs objectForKey:[NSString stringWithFormat:@"%d", (int)self.sequence]]];
//            //NSLog(@"%@", gifData);
//            [gifData setValue:@0 forKey:@"favorited"];
//            //NSLog(@"%@", gifData);
//            [self.gifs setValue:gifData forKey:[NSString stringWithFormat:@"%d", (int)self.sequence]];
//            
//            [resultButton setTitle:@"Favorite" forState:UIControlStateNormal];
//            
//            //            NSDictionary *gifData = [self.gifs objectForKey:self.currentSequence];
//            //            [gifData setValue:@0 forKey:@"favorited"];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
//            [resultButton setTitle:@"Error" forState:UIControlStateNormal];
//        }];
//    }
}

# pragma mark - Other Stuff

- (NSDictionary *)getGifOnPage:(NSNumber *)page
{
    return [self.gifs objectForKey:page];
}

- (void)setInfoForGifOnSequence:(NSNumber *)sequence
{
    NSDictionary *gifData = [self.gifs objectForKey:sequence];
    
    int favorited = [[gifData objectForKey:@"favorited"] intValue];
    
    if (favorited == 0) {
        self.favButtonOn = NO;
        [self.favButton setTitle:@"Favorite" forState:UIControlStateNormal];
    } else {
        self.favButtonOn = YES;
        [self.favButton setTitle:@"Favorited" forState:UIControlStateNormal];
    }
    
    if (self.sequence) {
        self.currentSequenceLabel.text = [@"Sequence: " stringByAppendingString:[NSString stringWithFormat:@"%d", (int)self.sequence]];
    }
}

# pragma mark - Property persistence

- (void)fetchAndSetCurrentSequence {
    
    // Fetch from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.sequence = [defaults integerForKey:@"sequence"];
    
    if (!self.sequence) {
        self.sequence = 0;
        [self storeCurrentSequence];
    }
    
    NSLog(@"%i", self.sequence);
}

- (void)storeCurrentSequence {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:self.sequence forKey:@"sequence"];
    [defaults synchronize];
    
    NSLog(@"%i", self.sequence);
}

- (void)fetchAndSetUuid {
    
    // Fetch from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.uuid = [defaults stringForKey:@"uuid"];
    
    if (!self.uuid) {
        self.uuid = [[NSUUID UUID] UUIDString];
        [defaults setObject:self.uuid forKey:@"uuid"];
        [defaults synchronize];
    }
    
    NSLog(@"%@", self.uuid);
}

# pragma mark - View Setup

- (void)setupGifNav
{
    self.infoHeight = 120;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    self.gifNav = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, screenHeight - (int)self.infoHeight)];
    [self.gifNav setContentSize:CGSizeMake(self.view.bounds.size.width*3, 410)]; // <- what is 410 and why is it hard coded?
    self.gifNav.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    self.gifNav.pagingEnabled = YES;
    self.gifNav.delegate = self;
    [self.gifNav setContentOffset:CGPointMake(self.view.bounds.size.width, 0)]; // Move to middle window
    [self.gifNav setShowsHorizontalScrollIndicator:NO];
    
    // Shadow
    self.gifNav.layer.masksToBounds = NO;
    self.gifNav.layer.shadowOffset = CGSizeMake(-15, -20);
    self.gifNav.layer.shadowRadius = 5;
    self.gifNav.layer.shadowOpacity = 0.5;
    
    [self.view addSubview:self.gifNav];
    
    // Initialize gifViews
    for (int i=0; i<=2; i++) {
        UIWebView *gifView = [[UIWebView alloc] initWithFrame:CGRectMake(self.gifNav.frame.size.width*i, 0, self.gifNav.frame.size.width, self.gifNav.frame.size.height)];
        gifView.scrollView.scrollEnabled = NO;
        gifView.scrollView.bounces = NO;
        [self.gifViews addObject:gifView];
        [self.gifNav addSubview:gifView];
    }
    
}

- (void)setupGifInfo
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    self.infoView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - (int)self.infoHeight, self.view.bounds.size.width, (int)self.infoHeight)];
    self.infoView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"darkdenim3.png"]];
    [self.view addSubview:self.infoView];
    
    // Setup Fav Button
    self.favButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 12, 100, 30)];
    UIImage *buttonImage = [[UIImage imageNamed:@"FavButtonStandard.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"FavButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self.favButton setTitle:@"Favorite" forState:UIControlStateNormal];
    self.favButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    // Set the background for any states you plan to use
    [self.favButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.favButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.favButton addTarget:self action:@selector(favButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.favButton];
    
    self.currentSequenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 6, self.view.bounds.size.width-12, 20)];
    self.currentSequenceLabel.font = [UIFont systemFontOfSize:12];
    self.currentSequenceLabel.backgroundColor = [UIColor clearColor];
    self.currentSequenceLabel.numberOfLines = 0; // Forces word wrap
    self.currentSequenceLabel.textColor = [UIColor whiteColor];
    [self.infoView addSubview:self.currentSequenceLabel];
}

# pragma mark - Hygene

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning!");
    // Dispose of any resources that can be recreated.
}

@end
