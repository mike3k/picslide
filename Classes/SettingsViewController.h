//
//  SettingsViewController.h
//  PicSlide
//
//  Created by Mike Cohen on 8/22/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {
    id delegate;
    
    CGRect screensize;

    NSInteger level;

    IBOutlet UIControl* bEasy;
    IBOutlet UIControl* bMedium;
    IBOutlet UIControl* bHard;
    IBOutlet UIControl* bImpossible;
    IBOutlet UISwitch* bSwitch;
    IBOutlet UISwitch* bSound;
    
    IBOutlet UISegmentedControl *bSize;

    NSURL* pic;
}

@property (nonatomic, assign) id delegate;
@property (assign,nonatomic) NSInteger level;
@property (assign,nonatomic) CGRect screensize;

- (IBAction) done;
- (IBAction) choosePicture;
- (IBAction) chooseLevel: (id)sender;
- (void) pictureChosen;

- (void) hilightButtonWithTag: (NSInteger)tag;

@end
