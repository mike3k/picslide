//
//  FlipsideViewController.h
//  PicSlide
//
//  Created by Mike Cohen on 8/8/09.
//  Copyright MC Development 2009. All rights reserved.
//

//@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id /*<FlipsideViewControllerDelegate>*/ delegate;
    
    IBOutlet UILabel *infoText;
}

@property (nonatomic, assign) id /*<FlipsideViewControllerDelegate>*/ delegate;
- (IBAction)done;
- (IBAction)gotoWeb;

@end


//@protocol FlipsideViewControllerDelegate
//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
//@end

