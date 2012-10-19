//
//  FlipsideViewController.m
//  PicSlide
//
//  Created by Mike Cohen on 8/8/09.
//  Copyright MC Development 2009. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;


- (void)viewDidLoad {
    int numSizes = 2;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    NSString *msgText = infoText.text;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    numSizes =  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 5 : 2;
#endif
    infoText.text = [NSString stringWithFormat: msgText, numSizes];
}


- (IBAction)done {
	//[self.delegate flipsideViewControllerDidFinish:self];	
    [self.delegate dismissModalViewControllerAnimated:YES];
}

- (IBAction)gotoWeb
{
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://mcdevzone.com/"]];
}

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


@end
