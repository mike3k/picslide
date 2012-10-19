//
//  BoardPiece.h
//  PicSlide
//
//  Created by Mike Cohen on 9/18/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface BoardPiece : CALayer {
    NSInteger   _index;
    CGImageRef  _image;
}

@property (assign,nonatomic) NSInteger index;
@property (assign,nonatomic) CGImageRef image;

@end
