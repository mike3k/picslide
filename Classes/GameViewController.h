//
//  GameView.h
//  PicSlide
//
//  Created by Mike Cohen on 8/21/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

@class BoardView;

@class Score;

@interface GameViewController : UIViewController <FBDialogDelegate> {
    IBOutlet BoardView* boardView;
    id delegate;
    
//    UIImage *customImage;
    NSString *url;
    
    IBOutlet UILabel* theTime;
    IBOutlet UILabel* theMoves;
    IBOutlet UIButton* saveButton;
    
//    IBOutlet id banner;
    IBOutlet UIView* viewcontainer;
    IBOutlet UIView *bannerview;
    NSTimer *timer;

    time_t  elapsedTime;
    time_t  starttime;
    
    BOOL    userImage;
    
    BOOL    imagePrepared;
    
    BOOL    bannerIsVisible;
    
    Score *_score;
}

- (IBAction)shuffle;
- (IBAction)reset;
- (IBAction)mainMenu;
- (IBAction)gameOver;
- (IBAction)savePicture;

- (void)updateMoves: (NSInteger)moves;

- (void)makeImage;

- (void)startTimer;
- (void)stopTimer;

- (void)shareOnFacebook: (Score*)theScore;
- (void)doShareDialog: (Score*)theScore;

#ifdef iADS
- (void) moveBannerViewOffscreen;
- (void) moveBannerViewOnscreen;
#endif

@property (nonatomic, assign) id delegate;
@property (readonly) id boardView;

//@property (nonatomic, assign) UIImage *customImage;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, assign) BOOL userImage;
@property (nonatomic, assign) BOOL bannerIsVisible;

@end
