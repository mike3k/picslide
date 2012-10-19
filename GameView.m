//
//  GameView.m
//  PicSlide
//
//  Created by Mike Cohen on 3/25/10.
//  Copyright 2010 MC Development. All rights reserved.
//

#import "GameView.h"
#import "BoardView.h"

@implementation GameView

@synthesize boardView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect myRect = self.frame;
    CGRect bvRect;
    double width, height, nheight, nwidth;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        if (UIInterfaceOrientationIsLandscape(orientation)) {
            height = myRect.size.width;
            width = myRect.size.height;
        }
        else {
            width = myRect.size.width;
            height = myRect.size.height;
        }
        
        nheight = height - topPanel.frame.size.height;
        nheight -= bottomPanel.frame.size.height;
        
        nwidth = nheight = MIN(nheight,width);
        
        bvRect = CGRectMake((width - nwidth) / 2, (height-nheight) / 2, nwidth, nheight);
        [self setNeedsDisplayInRect: boardView.frame];
        [boardView setHidden: YES];
        boardView.frame = bvRect;
    }
#endif
    [boardView adjustBounds];
    [boardView setHidden: NO];
    [super layoutSubviews];
}

- (void)dealloc {
    [super dealloc];
}


@end
