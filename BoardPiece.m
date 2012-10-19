//
//  BoardPiece.m
//  PicSlide
//
//  Created by Mike Cohen on 9/18/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "BoardPiece.h"
#import "UserSettings.h"


@implementation BoardPiece

@synthesize index=_index;
@synthesize image=_image;

- (id) initWithIndex: (NSInteger)idx
{
    if (self = [super init]) {
        self.index = idx;
    }
    return self;
}

- (void)dealloc
{
    CGImageRelease(_image);
    [super dealloc];
}

// delegate method
//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
//{
//    printf("drawLayer: %d\n",self.index);
//
//    char number[16];
//    CGContextSetTextDrawingMode(ctx, kCGTextFillStroke);
//    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
//    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
//    CGContextSelectFont (ctx, "Helvetica-Bold", layer.frame.size.height/10, kCGEncodingMacRoman);
//    sprintf(number,"%d",self.index+1);
//    CGContextShowTextAtPoint(ctx, layer.position.x, layer.position.y, number, strlen(number));
//
//}

- (void)drawInContext:(CGContextRef)theContext
{
    //printf("drawInContext: index=%d\n",self.index);

    CGContextSaveGState(theContext);
    CGContextTranslateCTM(theContext, 0.0, self.frame.size.height);
    CGContextScaleCTM(theContext, 1.0, -1.0);
    CGContextDrawImage(theContext, self.bounds, self.image);
    if ([UserSettings current].hints) {
        CGContextSetTextDrawingMode(theContext, kCGTextFillStroke);
        CGContextSetRGBFillColor(theContext, 1.0, 0.0, 0.0, 1.0);
        CGContextSetRGBStrokeColor(theContext, 0.0, 0.0, 0.0, 1.0);
        char number[16];
        sprintf(number,"%d",self.index+1);
        int ht = self.frame.size.height/4;
        CGContextSelectFont (theContext, "Helvetica-Bold", ht, kCGEncodingMacRoman);
        CGContextShowTextAtPoint(theContext, 4.0, self.frame.size.height - ht, number, strlen(number));
    }
    if (![self respondsToSelector: @selector(setBorderWidth:)]) {
        CGContextStrokeRect(theContext, self.bounds);
    }
    CGContextRestoreGState(theContext);
}

@end
