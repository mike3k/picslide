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
}
/* */

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

- (IBAction) choosePicture
{
	PictureChooser *controller = [[PictureChooser alloc] initWithNibName:@"PicChooser" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
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
    NSLog(@"setLevel: %@ (%d)",sender,[sender tag]);
    self.level = [sender tag];
    [self hilightButtonWithTag: self.level];
}

- (void) pictureChosen
{
    [self.delegate performSelector:@selector(play) withObject:nil afterDelay:0.01];
    [self done];
    //[self.delegate play];
}

- (IBAction) done
{
    UserSettings *s =[UserSettings current];
    s.level = self.level;
    [s setSizeAndCountFromLevel];
    [s saveSettings];
    [self.delegate dismissModalViewControllerAnimated:YES];
}


@end
