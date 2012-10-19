//
//  BoardView.m
//  PicSlide
//
//  Created by Mike Cohen on 8/20/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "BoardView.h"
#import "UserSettings.h"
#import "GameViewController.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation BoardView

@synthesize image = _image;
@synthesize delegate = _delegate;
@synthesize isReset = _isReset;

@synthesize moves = _moves;

@synthesize scaled = _scaled;

- (void)initdata
{
    curPiece = -1;
    self.scaled = NO;

    [self readSettings];

    soundEnabled = [UserSettings current].sound;
    if (soundEnabled) {
        CFURLRef url;
        url = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)@"up", (CFStringRef)@"wav", nil);
        AudioServicesCreateSystemSoundID(url,&sound1);
        CFRelease(url);

        url = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)@"down", (CFStringRef)@"wav", nil);
        AudioServicesCreateSystemSoundID(url,&sound2);
        CFRelease(url);

        url = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)@"blip", (CFStringRef)@"wav", nil);
        AudioServicesCreateSystemSoundID(url,&sound3);
        CFRelease(url);
    }
}

- (void)dealloc {
    CGImageRelease(self.image);
    self.image = nil;
    [self clearImageParts];
    if (soundEnabled) {
        AudioServicesDisposeSystemSoundID(sound1);
        AudioServicesDisposeSystemSoundID(sound2);
        AudioServicesDisposeSystemSoundID(sound3);
    }
    [super dealloc];
}

- (void)adjustBounds
{

    NSData *state = self.boardState;
    [self calcBoxes];
    self.boardState = state;
}

- (id)initWithCoder: (NSCoder*)coder
{
    if (self = [super initWithCoder: coder]) {
        [self initdata];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initdata];
    }
    return self;
}

- (void) makeImageFromURL: (NSURL*)url
{
    CGDataProviderRef source;
    source = CGDataProviderCreateWithURL((CFURLRef)url);
    self.image = CGImageCreateWithJPEGDataProvider(source, NULL, YES, kCGRenderingIntentDefault);
    [self prepareImage];
}

- (void) makeImage: (NSString*)name
{
    [self makeImageFromURL: (NSURL*)CFBundleCopyResourceURL(CFBundleGetMainBundle(), 
                                                            (CFStringRef)name,
                                                            CFSTR("jpg"),
                                                            NULL)];
}

- (void)useImage: (UIImage*)uiimage
{
    self.image = CGImageRetain(uiimage.CGImage);
    [self prepareImage];
}

-(void) prepareImage
{
    showHints = [UserSettings current].hints;
    [self setupImage];
    [self resume];
}

- (void)scaleImageToBounds
{
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
#ifndef _UNIVERSAL
    double scale = [[UIScreen mainScreen] scale]; 
#endif
    CGRect scaledBounds = self.bounds;

    // Get image width, height. We'll use the entire image.
    int width = (int)(self.bounds.size.width);
    int height = (int)(self.bounds.size.height);

    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * height);

    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return;
    }

    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(self.image);
    context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorspace);

    if (context == NULL)
        return;

    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, scaledBounds, self.image);
    CGImageRelease(self.image);
    self.image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    self.scaled = YES;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect: rect];
//}

- (void)pickUp: (NSInteger)piece
{
    CALayer *layer = _parts[piece];
    //printf("Pick up %d",piece);
    curPiece = piece;
    layer.zPosition += 20;
    if ([layer respondsToSelector:@selector(setBorderWidth:)]) {
        layer.borderWidth = 2;
    }
}

- (void)putDown
{
    if (curPiece >= 0) {
        CALayer *layer = _parts[curPiece];
        layer.zPosition = 0;
        if ([layer respondsToSelector:@selector(setBorderWidth:)]) {
            layer.borderWidth = 1;
        }
        curPiece = -1;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pt = [touch locationInView: self];
    NSInteger loc = [self FindPiece: pt];
    if (loc >= 0) {
        lastRow = ROW(loc);
        lastCol = COL(loc);
        [self pickUp: _board[lastRow][lastCol]];
        initMove = YES;
        ++_moves;
        if ([_delegate respondsToSelector: @selector(updateMoves:)]) {
            [_delegate updateMoves: _moves];
        }
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
        //printf("move to %d,%d\n",thisRow,thisCol);
        if (abs(thisRow - lastRow) > abs(thisCol - lastCol)) {
            if (!LockH && !LockV)
                LockV = YES;
            else if ((thisCol == lastCol) &&!LockH) {
                [self slideColumn: thisCol count: thisRow - lastRow isAnimated: YES];
                lastRow = thisRow;
            }
        }
        else {
            if (!LockH && !LockV) 
                LockH = YES;
            else if ((thisRow == lastRow) && !LockV) {
                [self slideRow: thisRow count: thisCol - lastCol isAnimated: YES];
                lastCol = thisCol;
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self putDown];
    if ([self isDone]) {
        printf("Finished!\n");
        if ([_delegate respondsToSelector: @selector(gameOver)]) {
            [_delegate gameOver];
        }
    }
    initMove = NO;
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
        [_parts[i] release];
        _parts[i] = NULL;
    }
}

- (void)readSettings
{
    _rows = [UserSettings current].boardSize;
    _difficulty = [UserSettings current].shuffleCount;
}

- (void) setupImage
{
    [self calcBoxes];
    [self scaleImageToBounds];
    [self splitImage];
    [self reset];
}

- (void) calcBoxes
{
    CGRect theBounds = self.bounds;
    _height = (theBounds.size.height) / NUM_ROWS;
    _width = (theBounds.size.width) / NUM_COLS;
    
    _width = _height = MIN(_width,_height);
    theBounds.size.width = (_width * NUM_COLS);
    theBounds.size.height = (_height * NUM_ROWS);
    self.bounds = theBounds;

    for (int i = 0; i<NUM_ROWS;++i) {
        for (int j=0; j<NUM_COLS;++j) {
            _boxes[i][j] = CGRectMake((_width*j), (_height*i), _width, _height);
        }
    }
}

- (void) splitImage
{
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();	
    //CGRect r = CGRectMake(0, 0, _width, _height);

    for (int i=0;i<NUM_ROWS;++i) {
        for (int j=0;j<NUM_COLS;++j) {
            CGImageRef img =  CGImageCreateWithImageInRect(_image, _boxes[i][j]);

            //CALayer *layer = [CALayer layer];
            BoardPiece *layer = [[BoardPiece alloc] initWithIndex:INDEX(i,j)];
            layer.frame = _boxes[i][j];
            //layer.contents = (id)img;
#ifndef _UNIVERSAL
            if ([layer respondsToSelector:@selector(setContentsScale:)]) {
                layer.contentsScale = [[UIScreen mainScreen] scale];
            }
#endif
            layer.image = img;
            if ([layer respondsToSelector:@selector(setBorderWidth:)]) {
                layer.borderWidth = 1.0;
                layer.cornerRadius = 4.0;
            }
            [layer setNeedsDisplay];
            
            [self.layer addSublayer: layer];
    
            _parts[INDEX(i,j)] = layer;
            
        }
    }
    //CGColorSpaceRelease(colorSpace);	
}

//- (void)draw: (CGContextRef)context
//{
//    for (int i=0;i<NUM_ROWS;++i) {
//        for (int j=0;j<NUM_COLS;++j) {
//            NSInteger piece = _board[i][j];
//#ifdef _USE_CGLAYER
//            CGContextDrawLayerInRect(context, _boxes[i][j], _parts[piece]);
//            CGContextStrokeRect(context, _boxes[i][j]);
//#else
//           // [_parts[piece] display];
//#endif
//            if (showHints) {
//                CGContextSaveGState(context);
//                CGContextSetTextDrawingMode(context, kCGTextFillStroke);
//                CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
//                CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
//                NSString *number = [NSString stringWithFormat: @"%d",piece+1];
//                //[number drawInRect:_boxes[i][j] withFont:[UIFont boldSystemFontOfSize:18]];
//                [number drawAtPoint:_boxes[i][j].origin withFont:[UIFont boldSystemFontOfSize:18]];
//                CGContextRestoreGState(context);
//            }
//        }
//    }
//
//}

static void _move_piece(CGRect dest,BoardPiece *piece)
{
    //piece.position = dest.origin;
    piece.frame = dest;
}

- (void) slideRow: (NSInteger)row count: (NSInteger)count isAnimated:(BOOL)animated
{
    int src,dest;
    NSInteger temp[NUM_COLS];
    
    if (count == 0)
        return;
    
    //printf("\n--slideRow: %d count: %d\n",row,count);
    
    for (src=0;src<NUM_COLS;++src) {
        temp[src] = _board[row][src];
    }
    for (src=0;src<NUM_COLS;++src) {
        dest = src + count;
        if (dest < 0) dest += NUM_COLS;
        else if (dest >= NUM_COLS) dest-=NUM_COLS;
        //printf("move from %d to %d\n",src,dest);
        _board[row][dest] = temp[src];
        _move_piece(_boxes[row][dest],_parts[temp[src]]);
    }
    if (soundEnabled && initMove && animated) {
        initMove = NO;
        if (count > 0)
            AudioServicesPlaySystemSound(sound1);
        else
            AudioServicesPlaySystemSound(sound2);
    }
    _isReset = NO;
}

- (void) slideColumn: (NSInteger)col count: (NSInteger)count isAnimated:(BOOL)animated
{
    int src,dest;
    NSInteger temp[NUM_ROWS];

    if (count == 0)
        return;

    //printf("\n--slideColumn: %d count: %d\n",col,count);

    for (src=0;src<NUM_ROWS;++src) {
        temp[src] = _board[src][col];
    }
    for (src=0;src<NUM_ROWS;++src) {
        dest = src + count;
        if (dest < 0) dest += NUM_ROWS;
        else if (dest >= NUM_ROWS) dest-=NUM_ROWS;
        //printf("move from %d to %d\n",src,dest);
        _board[dest][col] = temp[src];
        _move_piece(_boxes[dest][col],_parts[temp[src]]);
    }
    if (soundEnabled && initMove && animated) {
        initMove = NO;
        if (count > 0)
            AudioServicesPlaySystemSound(sound1);
        else
            AudioServicesPlaySystemSound(sound2);
    }
    _isReset = NO;
}

- (BOOL) isDone
{
    for (int i=0;i<NUM_ROWS;++i) {
        for (int j=0;j<NUM_COLS;++j) {
            if (_board[i][j] != INDEX(i,j))
                return NO;
        }
    }
    _isReset = YES;
    return YES;
}

- (void) reset
{
    printf("reset\n");
    for (int i=0;i<NUM_ROWS;++i) {
        for (int j=0;j<NUM_COLS;++j) {
            _board[i][j] = INDEX(i,j);
            _move_piece(_boxes[i][j],_parts[INDEX(i,j)]);
        }
    }
    _isReset = YES;
    _moves = 0;
}

- (void) shuffle
{
    printf("shuffle\n");
    BOOL rowOrColumn = 0, lastrc = 1;
    BOOL direction = 0;
    int move = 0, lastmove = -1;
    int num = 0;

    srandomdev();
    for (int shuffles=0;shuffles <= _difficulty;++shuffles) {
        while (rowOrColumn == lastrc && move == lastmove) {
            rowOrColumn = (random() & 1);
            direction = (random() & 1);
            num = (random()%(_rows/2))+1;
            move = random()%_rows;
        }
        
        if (rowOrColumn) {
            [self slideRow: move count: direction ? -num : num isAnimated: NO];
        }
        else {
            [self slideColumn: move count: direction ? -num : num isAnimated: NO];
        }
        lastrc = rowOrColumn;
        lastmove = move;
    }
    _moves = 0;
}

#pragma mark saving & restoring state

- (NSData*)boardState
{
    return [NSData dataWithBytes:_board length:sizeof(_board)];
}

- (void)setBoardState: (NSData*)state
{
    if ((nil == state) || ([state length] != sizeof(_board)))
    {
        [self reset];
    }
    else {
        memcpy(_board, [state bytes], sizeof(_board));
        for (int i=0;i<NUM_ROWS;++i) {
            for (int j=0;j<NUM_COLS;++j) {
                _move_piece(_boxes[i][j],_parts[_board[i][j]]);
            }
        }
        _isReset = NO;
    }
}

- (void) save
{
    printf("saving board state\n");
    UserSettings *s = [UserSettings current];
    s.boardState = self.boardState;
    s.moves = self.moves;
    [s saveSettings];
}

- (void) resume
{
    self.boardState = [UserSettings current].boardState;
    self.moves = [UserSettings current].moves;
    if ([_delegate respondsToSelector: @selector(updateMoves:)]) {
        [_delegate updateMoves: _moves];
    }
}

@end
