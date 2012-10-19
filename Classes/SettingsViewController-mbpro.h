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
    
    NSInteger level;

    IBOutlet UIControl* bEasy;
    IBOutlet UIControl* bMedium;
    IBOutlet UIControl* bHard;
    IBOutlet UIControl* bImpossible;

    NSURL* pic;
}

@property (nonatomic, assign) id delegate;
@property (assign,nonatomic) NSInteger level;

- (IBAction) done;
- (IBAction) choosePicture;
- (IBAction) chooseLevel: (id)sender;
- (void) pictureChosen;

- (void) hilightButtonWithTag: (NSInteger)tag;

@end
