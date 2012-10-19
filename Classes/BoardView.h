//
//  BoardView.h
//  PicSlide
//
//  Created by Mike Cohen on 8/20/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BoardPiece.h"

#define MAX_ROWS    16
#define MAX_PIECES  (MAX_ROWS * MAX_ROWS)

#define NUM_ROWS    _rows
#define NUM_COLS    _rows

#define NUM_PIECES  (NUM_ROWS*NUM_COLS)
#define INDEX(X,Y)  ((X*NUM_COLS)+Y)
#define ROW(Z)      (Z/NUM_COLS)
#define COL(Z)      (Z%NUM_COLS)

@interface BoardView : UIView {
    id          _delegate;

    CGImageRef  _image;

    NSInteger   _width;
    NSInteger   _height;

    NSInteger   _rows;
    NSInteger   _difficulty;

#ifdef _USE_CGLAYER
    CGLayerRef  _parts[MAX_PIECES];
#else
    BoardPiece * _parts[MAX_PIECES];
#endif

    CGRect      _boxes[MAX_ROWS][MAX_ROWS];
    NSInteger   _board[MAX_ROWS][MAX_ROWS];
    
    NSInteger   lastRow;
    NSInteger   lastCol;
    
    BOOL        LockH;
    BOOL        LockV;
    
    BOOL        showHints;
    
    BOOL        _isReset;

    BOOL        _scaled;

    NSInteger   curPiece;
    
    UInt32          sound1;
    UInt32          sound2;
    UInt32          sound3;
    
    BOOL            initMove;
    BOOL            soundEnabled;
    
    NSInteger       _moves;

}


@property (assign,nonatomic) CGImageRef image;
@property (assign,nonatomic) id         delegate;

@property (assign,nonatomic) NSData* boardState;
@property (assign,nonatomic) BOOL isReset;
@property (assign,nonatomic) BOOL scaled;

@property (assign,nonatomic) NSInteger moves;

- (NSInteger)FindPiece: (CGPoint)pt;

- (void)readSettings;

- (void) makeImageFromURL: (NSURL*)url;
- (void) makeImage: (NSString*)name;

- (void)adjustBounds;

- (void)scaleImageToBounds;

-(void) prepareImage;

- (void) clearImageParts;

- (void)useImage: (UIImage*)uiimage;

- (void) setupImage;
- (void) calcBoxes;
- (void) splitImage;
//- (void)draw: (CGContextRef)context;

- (void) slideRow: (NSInteger)row count: (NSInteger)count isAnimated:(BOOL)animated;
- (void) slideColumn: (NSInteger)col count: (NSInteger)count isAnimated:(BOOL)animated;
- (BOOL) isDone;
- (void) reset;
- (void) shuffle;

- (NSData*)boardState;
- (void)setBoardState: (NSData*)state;

- (void) save;
- (void) resume;


@end
