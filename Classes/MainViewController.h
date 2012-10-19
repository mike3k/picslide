//
//  MainViewController.h
//  PicSlide
//
//  Created by Mike Cohen on 8/8/09.
//  Copyright MC Development 2009. All rights reserved.
//

//#import "FlipsideViewController.h"
#import "GameViewController.h"
#import "FBConnect/FBConnect.h"

@interface MainViewController : UIViewController <  UINavigationControllerDelegate, 
                                                    UIImagePickerControllerDelegate,
                                                    FBDialogDelegate,
                                                    FBSessionDelegate,
                                                    FBRequestDelegate   > 
{
    FBSession   *_session;
    NSString    *fb_user_name;
    
    id popover;     // use with picture chooser on iPad
    
    IBOutlet UIView* bannerview;
    IBOutlet UIView* container;

    BOOL bannerIsVisible;
}

@property (retain,nonatomic) NSString *fb_user_name;

@property (assign,nonatomic) BOOL bannerIsVisible;

- (void)askPermission;
- (void)setStatus:(NSString*)statusString;

- (IBAction)showInfo;
- (IBAction)play;
- (IBAction)settings;
- (IBAction)chooseCameraRoll;
- (IBAction)showScores;
- (IBAction)choosePicture;

#ifdef iADS
- (void) moveBannerViewOffscreen;
- (void) moveBannerViewOnscreen;
#endif

- (void) pictureChosen;

//- (void)playWithImage: (UIImage*)image;

@end
