//
//  ScoreTableCell.h
//  PicSlide
//
//  Created by Mike Cohen on 11/9/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScoreTableCell : UITableViewCell {
    IBOutlet    UILabel* name;
    IBOutlet    UILabel* moves;
    IBOutlet    UILabel* time;
}

@property (assign,nonatomic) UILabel* name;
@property (assign,nonatomic) UILabel* moves;
@property (assign,nonatomic) UILabel* time;

@end
