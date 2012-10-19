//
//  Scoreboard.h
//  PicSlide
//
//  Created by Mike Cohen on 11/8/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject <NSCoding> {
    NSInteger moves;
    NSInteger time;
    NSInteger difficulty;
    NSInteger boardsize;
    NSDate *date;
    NSString *title;
}

@property (assign) NSInteger moves;
@property (assign) NSInteger time;
@property (assign) NSInteger difficulty;
@property (assign) NSInteger boardsize;

@property (retain,nonatomic) NSString *title;
@property (retain,nonatomic) NSDate *date;


+ (Score*) score;

- (id) init;

- (BOOL) fewerMoves: (NSInteger)inMoves;
- (BOOL) betterTime: (NSInteger)inTime;

- (NSInteger) isBetterThan: (Score*)cmp;
- (NSString*)description;

- (NSString*)nameOfLevel;
- (NSString*)nameOfSize;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

+ (NSString*)nameOfSize: (int)sz;
+ (NSString*)nameOfLevel: (int)level;

+ (int)difficulty: (int)shuffleCount;
+ (int)shuffleCount: (int)level;

@end

@interface Scoreboard : NSObject <NSCoding> {
    NSInteger       boardsize;
    NSInteger       difficulty;
    Score           *latestScore;
    NSMutableArray  *best_scores;
}

#define BEST_SCORES     10

@property (assign) NSInteger boardsize;
@property (assign) NSInteger difficulty;

@property (retain,nonatomic) Score *latestScore;
@property (retain,nonatomic) NSMutableArray *best_scores;

+ (Scoreboard*) scoresForBoardSize: (NSInteger)inBoardSize difficulty: (NSInteger)inDifficulty;
- (id)initWithDifficulty: (NSInteger)inDifficulty boardSize: (NSInteger)inBoardSize;
- (void)addScore: (Score*)score;
- (Score*)fewestMoves;
- (Score*)bestTime;

- (Score*)bestScoreAtIndex: (NSInteger)index;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

+ (BOOL)saveScores;
+ (BOOL)loadScores;

@end
