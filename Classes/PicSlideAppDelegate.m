//
//  PicSlideAppDelegate.m
//  PicSlide
//
//  Created by Mike Cohen on 8/8/09.
//  Copyright MC Development 2009. All rights reserved.
//

#import "PicSlideAppDelegate.h"
#import "MainViewController.h"

#import "Scoreboard.h"

// pinch analytics
//#ifdef USE_PINCH_ANALYTICS
//#import "Beacon.h"
//#endif

@implementation PicSlideAppDelegate


@synthesize window;
@synthesize mainViewController;

//- (void)AddBannerView
//{
//    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
//    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
//    [self.view addSubview:adView];
//
//}

- (void)applicationDidFinishLaunching:(UIApplication *)application {

    application.statusBarHidden = YES;
#ifdef iADS
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView-iAds" bundle:nil];
#else
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
#endif
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
    
    // load scores
    [Scoreboard loadScores];

    // pinch analytics
//#ifdef USE_PINCH_ANALYTICS
//    [Beacon initAndStartBeaconWithApplicationCode:@"YOUR_PINCH_ANALYTICS_KEY" useCoreLocation:NO useOnlyWiFi:NO];
//#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // save scores
    [Scoreboard saveScores];
//#ifdef USE_PINCH_ANALYTICS
//    [Beacon endBeacon];
//#endif
}

- (void)dealloc {
    
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
