//
//  GameView.m
//  PicSlide
//
//  Created by Mike Cohen on 8/21/09.
//  Copyright 2009 MC Development. All rights reserved.
//


#import "GameViewController.h"
#import "BoardView.h"
#import "UserSettings.h"
#import "Scoreboard.h"
#import "ScoreTableController.h"

#import "FBConnect/FBConnect.h"

#ifdef iADS
#import <iAd/ADBannerView.h>
#endif

@implementation GameViewController

@synthesize delegate;
@synthesize boardView;
@synthesize url;
//@synthesize customImage;
@synthesize userImage;
@synthesize bannerIsVisible;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/* */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
#ifdef iADS
//    [self moveBannerViewOffscreen];
#endif
    [super viewDidLoad];
    imagePrepared = NO;
    boardView.delegate = self;
}
/* */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!imagePrepared) {
        [self makeImage];
        imagePrepared = YES;
    }
#ifndef iADS
    saveButton.enabled = [UserSettings current].allowSave;
#endif
}

/* */
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/* */

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    if (fromInterfaceOrientation != [[UIApplication sharedApplication] statusBarOrientation]) {
//        //boardView.center = self.view.center;
//        [boardView adjustBounds];
//    }
//}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopTimer];
    if (boardView.isReset) {
        [UserSettings current].elapsedTime = elapsedTime = 0;
    }
    else {
        [UserSettings current].elapsedTime = (time(0L) - starttime) + elapsedTime;
    }
    [boardView save];
}

#ifdef iADS

#pragma mark Banner Views

- (void) moveBannerViewOffscreen {
	
	//Make tableView take up entire screen
    CGRect newFrame = self.view.frame;
	
	//Move Banner Offscreen
	CGRect newBannerFrame = CGRectMake(0, -50, 320, 50);
	
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
	viewcontainer.frame = newFrame;
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
	viewcontainer.frame = newFrame;
	bannerview.frame = newBannerFrame;
    self.bannerIsVisible = YES;
	[UIView commitAnimations];
	
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"bannerview DidLoadAd, visible=%d",self.bannerIsVisible);
    if (!self.bannerIsVisible)
    {
//        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
//// assumes the banner view is offset 50 pixels so that it is not visible.
//        banner.frame = CGRectOffset(banner.frame, 0, 50);
//        viewcontainer.frame = CGRectMake(0, 50, viewcontainer.frame.size.width, viewcontainer.frame.size.height - 50);
//        [UIView commitAnimations];
//        self.bannerIsVisible = YES;
        [self moveBannerViewOnscreen];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"bannerview didFailToReceiveAdWithError, visible=%d",self.bannerIsVisible);
    if (self.bannerIsVisible)
    {
//        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
//// assumes the banner view is at the top of the screen.
//        banner.frame = CGRectOffset(banner.frame, 0, -50);
//        viewcontainer.frame = CGRectMake(0, 0, viewcontainer.frame.size.width, viewcontainer.frame.size.height + 50);
//        [UIView commitAnimations];
//        self.bannerIsVisible = NO;
        [self moveBannerViewOffscreen];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    elapsedTime = (time(0L) - starttime) + elapsedTime;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    if (!boardView.isReset) {
        [self startTimer];
    }
}

#endif

- (void)dealloc {
    [super dealloc];
}

- (void)makeImage
{
    [boardView makeImageFromURL: [NSURL URLWithString: url]];

    if (!boardView.isReset) {
        elapsedTime = [UserSettings current].elapsedTime;
        if (elapsedTime != 0) {
            [self startTimer];
        }
        else {
            [boardView reset];
        }
    }
    else {
        elapsedTime = 0;
    }
    if (elapsedTime == 0) {
        [self performSelector: @selector(shuffle) withObject:nil afterDelay:1.0];
    }
}

- (IBAction)shuffle
{
    elapsedTime = 0;
    [self updateMoves: 0];
    [boardView reset];
    [boardView shuffle];
    [boardView setNeedsDisplay];
    [self startTimer];
}

- (IBAction)reset
{
    [boardView reset];
    [boardView setNeedsDisplay];
}

- (IBAction)savePicture
{
    UIImage *img = [UIImage imageWithCGImage: boardView.image];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    [UserSettings current].allowSave = NO;
#ifndef iADS
    saveButton.enabled = NO;
#endif
}

- (IBAction)mainMenu
{
    if (boardView.isReset) {
        [UserSettings current].elapsedTime = elapsedTime = 0;
    }
    else {
        [UserSettings current].elapsedTime = (time(0L) - starttime) + elapsedTime;
    }
    [boardView save];
    [self.delegate dismissModalViewControllerAnimated:YES];

}

- (void)updateMoves: (NSInteger)moves
{
    theMoves.text = [NSString stringWithFormat: @"%d",moves];
}

- (IBAction)gameOver
{
    NSInteger gameTime = (time(0L) - starttime) + elapsedTime;
    NSInteger boardSize = [UserSettings current].boardSize;
    NSInteger difficulty = [UserSettings current].shuffleCount;
    [self stopTimer];
   
    if (starttime != 0) {
        Scoreboard *sb = [Scoreboard scoresForBoardSize:boardSize difficulty:difficulty];
        NSString *title = [[[url lastPathComponent] stringByDeletingPathExtension] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        Score *theScore = [Score score];
        
        theScore.moves = boardView.moves;
        theScore.time = gameTime;
        theScore.date = [NSDate date];
        theScore.title = title;
        theScore.boardsize = boardSize;
        theScore.difficulty = difficulty;
        
        [sb addScore:theScore];

        starttime = 0;
        elapsedTime = 0;

        ScoreTableController *stc = [[ScoreTableController alloc] initWithNibName:@"ScoreTableController" bundle:nil];
        stc.delegate = self;
        stc.scores = sb;
        stc.last = theScore;
        stc.level = difficulty;
        stc.size = boardSize;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            stc.modalPresentationStyle = UIModalPresentationFormSheet;
            stc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        }
#endif
        [self presentModalViewController:stc animated:YES];
        [stc release];
    }
}

#pragma mark Facebook

- (void)doShareDialog: (Score*)theScore
{
	FBStreamDialog* dialog = [[[FBStreamDialog alloc] init] autorelease];
    NSString *attachment;
	dialog.delegate = self;
	dialog.userMessagePrompt = @"Brag to your friends:";
    if (self.userImage) {
        attachment = [NSString stringWithFormat:
                         @"{\"name\":\"PicSlide\",\"href\":\"http://mcdevzone.com/software/picslide\",\"caption\":\"%@\",\"description\":\" \"\}",
                         [theScore description]];
    }
    else {
        NSString *picurl = [NSString stringWithFormat: @"http://files.mc-development.com/picslide/%@.jpg",theScore.title];
        NSString *media = [NSString stringWithFormat: @"{\"type\":\"image\",\"src\": \"%@\", \"href\": \"%@\"}",picurl,picurl];
        attachment = [NSString stringWithFormat:
                         @"{\"name\":\"PicSlide\",\"href\":\"http://mcdevzone.com/software/picslide\",\"caption\":\"%@\",\"description\":\" \", \"media\": [%@]}",
                         [theScore description], media];
    }
	dialog.attachment = attachment;
    
	[dialog show];
}

- (void)dialogDidSucceed:(FBDialog*)dialog
{
    if ([dialog isMemberOfClass:[FBLoginDialog class]]) {
        [self doShareDialog: _score];
    }
}

- (void)dialogDidCancel:(FBDialog*)dialog
{
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error
{
    NSLog(@"Dialog failed with error: %@",error);
}

- (void)shareOnFacebook: (Score*)theScore
{
    [self dismissModalViewControllerAnimated:YES];
    
    FBSession *_session = [FBSession session];
    if (![_session isConnected]) {
        _score = theScore;
        FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:_session] autorelease];
        dialog.delegate = self;
        [dialog show];
    }
    else {
        [self doShareDialog: theScore];
    }
}


#pragma mark timer

- (void)updateTime: (NSTimer*)tm
{
    if (timer == nil)
        [tm invalidate];
    else {
        time_t seconds = (time(0L) - starttime) + elapsedTime;
        NSString *tbuf = [NSString stringWithFormat: @"%02d:%02d:%02d", seconds / 3600, seconds / 60, seconds % 60 ];
        theTime.text = tbuf;
    }
}

- (void)startTimer
{
    starttime = time(0L);
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
    printf("stop timer\n");
}


@end
