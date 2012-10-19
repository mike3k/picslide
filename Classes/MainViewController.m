//
//  MainViewController.m
//  PicSlide
//
//  Created by Mike Cohen on 8/8/09.
//  Copyright MC Development 2009. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "BoardView.h"
#import "SettingsViewController.h"
#import "FlipsideViewController.h"
#import "PictureChooser.h"
#import "UserSettings.h"

#import "Scoreboard.h"
#import "ScoreTableController.h"

#ifdef iADS
#import <iAd/ADBannerView.h>
#endif

@implementation MainViewController

@synthesize bannerIsVisible;
@synthesize fb_user_name;

#pragma mark - INSERT YOUR FACEBOOK API KEY & SECRET HERE
static NSString* kApiKey = @"YOUR_FACEBOOK_API_KEY";
static NSString* kApiSecret = @"YOUR_FACEBOOK_API_SECRET";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        _session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
    }
    return self;
}

#pragma mark FaceBook Connect

- (void)sessionDidNotLogin:(FBSession*)session
{
}

- (void)session:(FBSession*)session didLogin:(FBUID)uid 
{
    NSString* fql = [NSString stringWithFormat:
                     @"select uid,name from user where uid == %lld", session.uid];

    NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
    [[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
    
    
    NSLog(@"logged in successfully");

}

- (void)sessionDidLogout:(FBSession*)session
{
    NSLog(@"logged out");
}

- (void)request:(FBRequest*)request didLoad:(id)result 
{
    if ([request.method isEqualToString:@"facebook.fql.query"]) {
        NSArray* users = result;
        NSDictionary* user = [users objectAtIndex:0];
        NSString* name = [user objectForKey:@"name"];
        // we now have the user name
        NSLog(@"logged in as %@",name);
        self.fb_user_name = name;
    }
    else if ([request.method isEqualToString:@"facebook.users.setStatus"]) {
        NSString* success = result;
        if ([success isEqualToString:@"1"]) {
            // success
            NSLog(@"setStatus succeeded");
        }
        else {
           // fail 
            NSLog(@"setStatus failed");
        }
    }
//    else if ([request.method isEqualToString:@"facebook.photos.upload"]) {
//        NSDictionary* photoInfo = result;
//        NSString* pid = [photoInfo objectForKey:@"pid"];
//        NSLog(@"photo upload successful");
//    }
}

- (void)dialogDidSucceed:(FBDialog*)dialog
{
}

- (void)dialogDidCancel:(FBDialog*)dialog
{
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
    NSLog(@"Request %@ failed with error: %@",request.method,error);
}

#pragma mark Facebook actions

- (void)setStatus:(NSString*)statusString {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							statusString, @"status",
							@"true", @"status_includes_verb",
							nil];
	[[FBRequest requestWithDelegate:self] call:@"facebook.users.setStatus" params:params];
}

- (void)askPermission {
  FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
  dialog.delegate = self;
  dialog.permission = @"status_update";
  [dialog show];
}

/* */
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
#ifdef iADS
//     [self moveBannerViewOffscreen];
#endif
    [super viewDidLoad];
     [_session resume];
 }
 /* */


/* */
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
/* */


//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
//    
//	[self dismissModalViewControllerAnimated:YES];
//}
#pragma mark Info Screen

- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.contentSizeForViewInPopover = CGSizeMake(320, 480);
    }
#endif

    if ([controller respondsToSelector: @selector(setModalTransitionStyle:)]) {
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

#pragma mark game play
//- (void)playWithImage: (UIImage*)image
//{
//    GameViewController *controller = [[GameViewController alloc] initWithNibName:@"GameView" bundle:nil];
//    [UserSettings current].boardState = nil;
//    controller.customImage = image;
//	controller.delegate = self;
//	if ([controller respondsToSelector: @selector(setModalTransitionStyle:)]) {
//        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    }
//	[self presentModalViewController:controller animated:YES];
//	
//	[controller release];
//}

- (IBAction)choosePicture
{
	PictureChooser *controller = [[PictureChooser alloc] initWithNibName:@"PicChooser" bundle:nil];
	controller.delegate = self;
	if ([controller respondsToSelector: @selector(setModalTransitionStyle:)]) {
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
#endif
	[self presentModalViewController:controller animated:YES];
    [controller release];
}

#ifdef iADS
#pragma mark Banner Views

- (void) moveBannerViewOffscreen {
	
	//Make tableView take up entire screen
    CGRect newFrame = self.view.frame;
	
	//Move Banner Offscreen
	CGRect newBannerFrame = CGRectMake(0, -50, 320, 50);
	
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
	container.frame = newFrame;
	bannerview.frame = newBannerFrame;
    self.bannerIsVisible = NO;
    [UIView commitAnimations];
	
}

- (void) moveBannerViewOnscreen {
	CGRect newBannerFrame = CGRectMake(0, 0, 320, 50);
	
	CGRect newFrame = self.view.frame;
	newFrame.size.height -= 50;
    newFrame.origin.y += 50;
	
	[UIView beginAnimations:@"BannerViewIntro"	context:NULL];
	container.frame = newFrame;
	bannerview.frame = newBannerFrame;
    self.bannerIsVisible = YES;
	[UIView commitAnimations];
	
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"bannerview didFailToReceiveAdWithError, visible=%d",self.bannerIsVisible);
    if (self.bannerIsVisible)
    {
//        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
//// assumes the banner view is at the top of the screen.
//        banner.frame = CGRectOffset(banner.frame, 0, -50);
//        container.frame = CGRectMake(0, 50, container.frame.size.width, container.frame.size.height - 50);
//        [UIView commitAnimations];
//        self.bannerIsVisible = NO;
        [self moveBannerViewOffscreen];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"bannerview DidLoadAd, visible=%d",self.bannerIsVisible);
    if (!self.bannerIsVisible)
    {
//        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
//// assumes the banner view is offset 50 pixels so that it is not visible.
//        banner.frame = CGRectOffset(banner.frame, 0, 50);
//        container.frame = CGRectMake(0, 0, container.frame.size.width, container.frame.size.height + 50);
//        [UIView commitAnimations];
//        self.bannerIsVisible = YES;
        [self moveBannerViewOnscreen];
    }
}

#endif

- (IBAction)play
{
	GameViewController *controller;
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        controller = [[GameViewController alloc] initWithNibName:@"GameView-iPad" bundle:nil];
//    }
//    else
//#endif
#ifdef iADS
        controller = [[GameViewController alloc] initWithNibName:@"GameView-iAds" bundle:nil];
#else
        controller = [[GameViewController alloc] initWithNibName:@"GameView" bundle:nil];
#endif
    
	controller.url = [UserSettings current].picture;
    controller.userImage = [UserSettings current].userImage;
	controller.delegate = self;
	if ([controller respondsToSelector: @selector(setModalTransitionStyle:)]) {
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }

	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (IBAction)showScores
{
    NSInteger boardSize = [UserSettings current].boardSize;
    NSInteger difficulty = [UserSettings current].shuffleCount;
    Scoreboard *sb = [Scoreboard scoresForBoardSize:boardSize difficulty:difficulty];
    ScoreTableController *stc = [[ScoreTableController alloc] initWithNibName:@"ScoreTableController" bundle:nil];
    stc.delegate = self;
    stc.scores = sb;
    stc.last = nil;
    stc.size = boardSize;
    stc.level = difficulty;

	if ([stc respondsToSelector: @selector(setModalTransitionStyle:)]) {
        stc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        stc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
#endif
    [self presentModalViewController:stc animated:YES];
    [stc release];
}

#pragma mark settings screen
- (IBAction)settings
{
	SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	controller.delegate = self;
	
	if ([controller respondsToSelector: @selector(setModalTransitionStyle:)]) {
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
#endif
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (IBAction) chooseCameraRoll
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsImageEditing = YES;
    //NSLog(@"picker: %@",picker);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        Class popoverClass = (NSClassFromString(@"UIPopoverController"));
        if (nil != popoverClass) {
            popover = [[popoverClass alloc] initWithContentViewController: picker];
            [popover presentPopoverFromRect:self.view.frame 
                                     inView:self.view 
                   permittedArrowDirections:UIPopoverArrowDirectionAny 
                                   animated:YES];
        }
        else {
            [self presentModalViewController:picker animated:YES];
            popover = nil;
       }
    }
    else {
        [self presentModalViewController:picker animated:YES];
    }
#else
    [self presentModalViewController:picker animated:YES];
#endif
    [picker release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (nil != popover) {
            [popover dismissPopoverAnimated:YES];
            [popover release];
            popover = nil;
        }
    }
#endif
}


- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image 
                  editingInfo:(NSDictionary *)editingInfo
{
    printf("picture chosen\n");
    //[self performSelector:@selector(playWithImage:) withObject:image afterDelay:1];
    @try {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([dirs count] > 0) {
            NSURL *url = [NSURL fileURLWithPath: [[dirs objectAtIndex:0] stringByAppendingPathComponent: @"My Own Picture.jpg"]];
            NSData *imageData = UIImageJPEGRepresentation(image,0.8);
            if ([imageData writeToURL:url atomically:NO]) {
                UserSettings *s = [UserSettings current];
                s.picture = [url absoluteString];
                s.userImage = YES;
                s.allowSave = NO;
                s.boardState = nil;
                [s saveSettings];
            }
        }
    }
    @catch (NSException* e) {
    }
    @finally {
    }
    [self performSelector:@selector(play) withObject:nil afterDelay:1];
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (nil != popover) {
            [popover dismissPopoverAnimated:YES];
            [popover release];
            popover = nil;
        }
    }
#endif
}

#pragma mark picture chooser

- (void) pictureChosen
{
    [self performSelector:@selector(play) withObject:nil afterDelay:1];
    [self dismissModalViewControllerAnimated:YES];
    //[self play];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [_session release];
    [super dealloc];
}


@end
