//
//  GameView.h
//  PicSlide
//
//  Created by Mike Cohen on 3/25/10.
//  Copyright 2010 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BoardView;

@interface GameView : UIView {
    IBOutlet BoardView *boardView;
    IBOutlet UIView *topPanel;
    IBOutlet UIView *bottomPanel;
}

@property (assign) BoardView* boardView;

@end
