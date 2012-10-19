//
//  ScoreTableCell.m
//  PicSlide
//
//  Created by Mike Cohen on 11/9/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "ScoreTableCell.h"


@implementation ScoreTableCell

@synthesize name;
@synthesize moves;
@synthesize time;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
