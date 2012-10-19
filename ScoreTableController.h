//
//  ScoreTableController.h
//  PicSlide
//
//  Created by Mike Cohen on 11/9/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Scoreboard;
@class Score;

@interface ScoreTableController : UIViewController {
    Scoreboard  *scores;
    Score       *last;
    id delegate;
    
    IBOutlet id aCell;
    
    IBOutlet UILabel* aMsg;
    IBOutlet id theTable;
    
    IBOutlet id fButton;
    IBOutlet UISegmentedControl* levelSelector;
    IBOutlet UISegmentedControl* sizeSelector;
    
    NSInteger level;
    NSInteger size;
}

- (IBAction) close: (id)sender;
- (IBAction) share: (id)sender;

- (IBAction) changeLevel: (id) sender;

- (void) updateLevel;
- (void) updateTabs;

@property (retain,nonatomic) Scoreboard *scores;
@property (assign,nonatomic) id delegate;
@property (retain,nonatomic) Score *last;
@property (assign,nonatomic) id aCell;
@property (assign,nonatomic) UILabel *aMsg;

@property (assign,nonatomic) NSInteger level;
@property (assign,nonatomic) NSInteger size;

@end
