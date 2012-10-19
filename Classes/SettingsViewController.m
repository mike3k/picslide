//
//  SettingsViewController.m
//  PicSlide
//
//  Created by Mike Cohen on 8/22/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "SettingsViewController.h"
#import "PictureChooser.h"
#import "UserSettings.h"

@implementation SettingsViewController

@synthesize delegate;
@synthesize level;
@synthesize screensize;

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
    [super viewDidLoad];
    self.level = [UserSettings current].level;
    [self hilightButtonWithTag: self.level];
    self.screensize = [[UIScreen mainScreen] bounds];
    bSwitch.on = [UserSettings current].hints;
    bSound.on = [UserSettings current].sound;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [bSize insertSegmentWithTitle:@"10x10" atIndex:3 animated:NO];
        [bSize insertSegmentWithTitle:@"12x12" atIndex:4 animated:NO];
        [bSize insertSegmentWithTitle:@"16x16" atIndex:5 animated:NO];
    }
#endif
    switch ([UserSettings current].boardSize) {
        case 4:
            bSize.selectedSegmentIndex = 0;
            break;
        case 8:
            bSize.selectedSegmentIndex = 1;
            break;
        case 10:
            bSize.selectedSegmentIndex = 2;
            break;
        case 12:
            bSize.selectedSegmentIndex = 3;
            break;
        default:
            bSize.selectedSegmentIndex = 4;
            break;
    }

//    else {
//        bSize.selectedSegmentIndex = ([UserSettings current].boardSize == 4) ? 0 : 1;
//    }
}
/* */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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
    [super dealloc];
}

- (IBAction) useCameraRoll
{
    [self.delegate performSelector:@selector(chooseCameraRoll) withObject:nil afterDelay:1];
    [self done];
}

- (IBAction) choosePicture
{
	PictureChooser *controller = [[PictureChooser alloc] initWithNibName:@"PicChooser" bundle:nil];
	controller.delegate = self;
	if ([controller respondsToSelector: @selector(setModalTransitionStyle:)]) {
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
	[self presentModalViewController:controller animated:YES];

}

- (void) hilightButtonWithTag: (NSInteger)tag
{
    bEasy.selected = (tag == bEasy.tag);
    bMedium.selected = (tag == bMedium.tag);
    bHard.selected = (tag == bHard.tag);
    bImpossible.selected = (tag == bImpossible.tag);
}

- (IBAction) chooseLevel: (id)sender
{
    //NSLog(@"setLevel: %@ (%d)",sender,[sender tag]);
    self.level = [sender tag];
    [self hilightButtonWithTag: self.level];
}

- (void) pictureChosen
{
    [self.delegate performSelector:@selector(play) withObject:nil afterDelay:1];
    [self done];
}

- (IBAction) done
{
    UserSettings *s =[UserSettings current];
    NSInteger newBoardSize;
    switch (bSize.selectedSegmentIndex) {
        case 0:
            newBoardSize = 4;
            break;
        case 1:
            newBoardSize = 8;
            break;
        case 2:
            newBoardSize = 10;
            break;
        case 3:
            newBoardSize = 12;
            break;
        default:
            newBoardSize = 16;
            break;
    }
    if ((s.level != self.level) || (s.boardSize != newBoardSize)) {
        s.level = self.level;
        [s setSizeAndCountFromLevel];
        s.boardSize = newBoardSize;
        s.elapsedTime = 0;
    }
    s.hints = bSwitch.on;
    s.sound = bSound.on;

    [s saveSettings];
    [self.delegate dismissModalViewControllerAnimated:YES];
}


@end
