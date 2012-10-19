//
//  BoardView.m
//  PicSlide
//
//  Created by Mike Cohen on 8/20/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "BoardView.h"
#import "UserSettings.h"

@implementation BoardView

@synthesize image = _image;
@synthesize delegate = _delegate;

- (id)initWithCoder: (NSCoder*)coder
{
    if (self = [super initWithCoder: coder]) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void) makeImageFromURL: (NSURL*)url
{
    CGDataProviderRef source;
    source = CGDataProviderCreateWithURL((CFURLRef)url);
    self.image = CGImageCreateWithJPEGDataProvider(source, NULL, YES, kCGRenderingIntentDefault);
    [self setupImage: self.image bounds:[self bounds]];
    [self reset];
    [self shuffle];
    showHints = YES;
}

- (void) makeImage: (NSString*)name
{
    [self makeImageFromURL: (NSURL*)CFBundleCopyResourceURL(CFBundleGetMainBundle(), 
                                                            (CFStringRef)name,
                                                            CFSTR("jpg"),
                                                            NULL)];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self draw: UIGraphicsGetCurrentContext()];
}

- (void)dealloc {
    self.image = nil;
    [self clearImageParts];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pt = [touch locationInView: self];
    NSInteger loc = [self FindPiece: pt];
    if (loc >= 0) {
        lastRow = ROW(loc);
        lastCol = COL(loc);
        printf("Drag begin at %d,%d\n",lastRow,lastCol);
    }
    else {
        lastRow = lastCol = -1;
    }
    LockH = LockV = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pt = [touch locationInView: self];
    NSInteger loc = [self FindPiece: pt];
    if ((loc >= 0) && (lastRow >= 0) && (lastCol >= 0))  {
        NSInteger thisRow = ROW(loc);
        NSInteger thisCol = COL(loc);
        if ((thisRow == lastRow) && (thisCol == lastCol))
            return;
        printf("move to %d,%d\n",thisRow,thisCol);
        if (abs(thisRow - lastRow) > abs(thisCol - lastCol)) {
            if (!LockH && !LockV)
                LockV = YES;
            else if ((thisCol == lastCol) &&!LockH) {
                [self slideColumn: thisCol count: thisRow - lastRow];
                lastRow = thisRow;
            }
        }
        else {
            if (!LockH && !LockV) 
                LockH = YES;
            else if ((thisRow == lastRow) && !LockV) {
                [self slideRow: thisRow count: thisCol - lastCol];
                lastCol = thisCol;
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch * touch = [touches anyObject];
//    CGPoint pt = [touch locationInView: self];
//    NSInteger loc = [self FindPiece: pt];
//    if ((loc >= 0) && (lastRow >= 0) && (lastCol >= 0))  {
//        NSInteger endRow = ROW(loc);
//        NSInteger endCol = COL(loc);
//        if (abs(endRow - lastRow) > abs(endCol - lastCol)) {
//            [self slideColumn: endCol count: endRow - lastRow];
//        }
//        else {
//            [self slideRow: endRow count: endCol - lastCol];
//        }
//    }
//    [self setNeedsDisplay];
    if ([self isDone]) {
        printf("Finished!\n");
    }
}

- (NSInteger)FindPiece: (CGPoint)pt
{
    for (int i=0;i<NUM_ROWS;++i)
    {
        for (int j=0;j<NUM_COLS;++j) {
            if (CGRectContainsPoint(_boxes[i][j], pt))
                return INDEX(i,j);
        }
    }
    return -1;
}

- (void) clearImageParts
{
    for (int i=0;i<NUM_PIECES;++i) {
        CGLayerRelease(_parts[i]);
        _parts[i] = NULL;
    }
}

- (void)readSettings
{
    _rows = [UserSettings current].boardSize;
    _difficulty = [UserSettings current].shuffleCount;
}

- (void) setupImage: (CGImageRef)inImage bounds:(CGRect)inBounds
{
    [self readSettings];
    [self calcBoxes: inBounds];
    [self splitImage: inImage];
    [self reset];
    //[self shuffle];
}

- (void) calcBoxes: (CGRect)bounds
{
    _height = bounds.size.height / NUM_ROWS;
    _width = bounds.size.width / NUM_COLS;

    for (int i = 0; i<NUM_ROWS;++i) {
        for (int j=0; j<NUM_COLS;++j) {
            _boxes[i][j] = CGRectMake((_width*j), (_height*i), _width, _height);
        }
    }
}

- (void) splitImage: (CGImageRef)inImage
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();	
    CGRect r = CGRectMake(0, 0, _width, _height);

    for (int i=0;i<NUM_ROWS;++i) {
        for (int j=0;j<NUM_COLS;++j) {
        //_parts[INDEX(i,j)] = CGImageCreateWithImageInRect(inImage, _boxes[i][j]);
            CGContextRef bits = CGBitmapContextCreate (nil, 
                                                        _width,
                                                        _height, 
                                                        8,
                                                        0,
                                                        colorSpace, 
                                                        kCGImageAlphaPremultipliedLast);
            CGImageRef img =  CGImageCreateWithImageInRect(inImage, _boxes[i][j]);
            CGLayerRef layer = CGLayerCreateWithContext(bits, r.size, NULL);
            CGContextRef lc = CGLayerGetContext(layer);
            CGContextTranslateCTM(lc, 0.0, _height);
            CGContextScaleCTM(lc, 1.0, -1.0);
            CGContextDrawImage(lc, r, img);
            CGImageRelease(img);
            CGContextRelease(bits);
            _parts[INDEX(i,j)] = layer;
            
        }
    }
    CGColorSpaceRelease(colorSpace);	
}

- (void)draw: (CGContextRef)context
{
    for (int i=0;i<NUM_ROWS;++i) {
        for (int j=0;j<NUM_COLS;++j) {
            NSInteger piece = _board[i][j];
            CGContextDrawLayerInRect(context, _boxes[i][j], _parts[piece]);
            CGContextStrokeRect(context, _boxes[i][j]);
            if (showHints) {
                CGContextSaveGState(context);
                CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
                CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
                NSString *number = [NSString stringWithFormat: @"%d",piece+1];
                //[number drawInRect:_boxes[i][j] withFont:[UIFont boldSystemFontOfSize:18]];
                [number drawAtPoint:_boxes[i][j].origin withFont:[UIFont boldSystemFontOfSize:18]];
                CGContextRestoreGState(context);
            }
        }
    }

}


- (void) slideRow: (NSInteger)row count: (NSInteger)count
{
    int src,dest;
    NSInteger temp[NUM_COLS];
    
    if (count == 0)
        return;
    
    printf("\n--slideRow: %d count: %d\n",row,count);
    
    for (src=0;src<NUM_COLS;++src) {
        temp[src] = _board[row][src];
    }
    for (src=0;src<NUM_COLS;++src) {
        dest = src + count;
        if (dest < 0) dest += NUM_COLS;
        else if (dest >= NUM_COLS) dest-=NUM_COLS;
        //printf("move from %d to %d\n",src,dest);
        _board[row][dest] = temp[src];
    }
}

- (void) slideColumn: (NSInteger)col count: (NSInteger)count
{
    int src,dest;
    NSInteger temp[NUM_ROWS];

    if (count == 0)
        return;

    printf("\n--slideColumn: %d count: %d\n",col,count);

    for (src=0;src<NUM_ROWS;++src) {
        temp[src] = _board[src][col];
    }
    for (src=0;src<NUM_ROWS;++src) {
        dest = src + count;
        if (dest < 0) dest += NUM_ROWS;
        else if (dest >= NUM_ROWS) dest-=NUM_ROWS;
        //printf("move from %d to %d\n",src,dest);
        _board[dest][col] = temp[src];
    }
}

- (BOOL) isDone
{
    for (int i=0;i<NUM_ROWS;++i) {
        for (int j=0;j<NUM_COLS;++j) {
            if (_board[i][j] != INDEX(i,j))
                return NO;
        }
    }
    if ([_delegate respondsToSelector: @selector(gameOver)]) {
        [_delegate gameOver];
    }
    return YES;
}

- (void) reset
{
    for (int i=0;i<NUM_ROWS;++i) {
        for (int j=0;j<NUM_COLS;++j) {
            _board[i][j] = INDEX(i,j);
        }
    }
}

- (void) shuffle
{
    srandomdev();
    for (int count=0;count < _difficulty;++count) {
        if (random() & 1) {
            [self slideRow: random()&(_rows-1) count: random()&1 ? -((random()&3)+1) : (random()&3)+1];
        }
        else {
            [self slideColumn: random()&(_rows-1) count: random()&1 ? -((random()&3)+1) : (random()&3)+1];
        }
    }
}


@end
