//
//  Scoreboard.m
//  PicSlide
//
//  Created by Mike Cohen on 11/8/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "Scoreboard.h"

@implementation Score

@synthesize time;
@synthesize moves;
@synthesize date;
@synthesize title;
@synthesize boardsize;
@synthesize difficulty;

+ (Score*) score
{
    return [[[Score alloc] init] autorelease];
}


- (id) init
{
    if (self = [super init]) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    //[super initWithCoder: aDecoder];
    [super init];
    moves = [aDecoder decodeIntegerForKey: @"moves"];
    time = [aDecoder decodeIntegerForKey: @"time"];
    difficulty = [aDecoder decodeIntegerForKey:@"level"];
    boardsize = [aDecoder decodeIntegerForKey:@"size"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //[super encodeWithCoder:aCoder];
    [aCoder encodeInteger:moves forKey:@"moves"];
    [aCoder encodeInteger:time forKey:@"time"];
    [aCoder encodeInteger:difficulty forKey:@"level"];
    [aCoder encodeInteger:boardsize forKey:@"size"];
    [aCoder encodeObject:date forKey:@"date"];
    [aCoder encodeObject:title forKey:@"title"];
}

- (void)dealloc
{
    self.title = nil;
    self.date = nil;
    [super dealloc];
}

- (BOOL) fewerMoves: (NSInteger)inMoves
{
    return (self.moves < inMoves);
}

- (BOOL) betterTime: (NSInteger)inTime
{
    return (self.time < inTime);
}

- (NSInteger) isBetterThan: (Score*)cmp
{
    if (self.moves < cmp.moves)
        return -1;
    if (self.moves == cmp.moves) {
        if (self.time < cmp.time)
            return -1;
        if (self.time == cmp.time)
            return 0;
    }
    return 1;
}

- (NSString*)nameOfLevel
{
    return [Score nameOfLevel: self.difficulty];
}

- (NSString*)nameOfSize
{
    return [Score nameOfSize: self.boardsize];
}

- (NSString*)description
{
    return [NSString stringWithFormat: @"Completed %@ on %@ with %d moves in %02d:%02d:%02d",
                                        self.title,
                                        [self nameOfLevel],
                                        self.moves,
                                        self.time / 3600, self.time / 60, self.time % 60
                                        ];
}


//static int _counts[] = { 4, 6, 8, 16 };
static int _counts[] = { kEasyCount, kMediumCount, kHardCount, kImpossibleCount };

+ (NSString*)nameOfSize: (int)sz
{
    switch (sz) {
        case 4:
            return @"4x4";
        case 8:
            return @"8x8";
        case 10:
            return @"10x10";
        case 12:
            return @"12x12";
        default:
            return @"16x16";
    }
}

+ (NSString*)nameOfLevel: (int)level
{
    switch (level) {
        case kEasyCount:            return @"easy";
        case kMediumCount:          return @"medium";
        case kOldMediumCount:       return @"medium*";
        case kHardCount:            return @"hard";
        case kImpossibleCount:      return @"impossible";
        case kOldImpossibleCount:   return @"impossible*";
    }

    return nil;
}

+ (int)difficulty: (int)shuffleCount
{
    switch (shuffleCount) {
        case kEasyCount:        return 0;
        case kMediumCount:
        case kOldMediumCount:
            return 1;
        case kHardCount:
            return 2;
        case kImpossibleCount:
        case kOldImpossibleCount:
            return 3;
    }
    return 1;
}

+ (int)shuffleCount: (int)level
{
    if (level < 0) level = 0;
    if (level > 3) level = 3;
    return _counts[level];
}

@end


@implementation Scoreboard

static NSMutableArray *boards = nil;

@synthesize best_scores;
@synthesize latestScore;
@synthesize difficulty;
@synthesize boardsize;

+ (BOOL)loadScores
{
    if (nil != boards) {
        [boards release];
        boards = nil;
    }
    NSData *sdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"scores"];
    if(nil != sdata) {
        boards = [[NSKeyedUnarchiver unarchiveObjectWithData:sdata] retain];
        return YES;
    }

    return NO;
}

+ (BOOL)saveScores
{   
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:[NSKeyedArchiver archivedDataWithRootObject:boards] forKey:@"scores"];
    [def synchronize];
    return YES;
}

+ (Scoreboard*) scoresForBoardSize: (NSInteger)inBoardSize difficulty: (NSInteger)inDifficulty
{
    if (nil == boards) {
        boards = [[NSMutableArray alloc] init];
    }
    for (Scoreboard *sb in boards) {
        if ((sb.boardsize == inBoardSize) && (sb.difficulty == inDifficulty))
            return sb;
    }
    Scoreboard *newsb = [[Scoreboard alloc] initWithDifficulty: inDifficulty boardSize:inBoardSize];
    [boards addObject: [newsb autorelease]];
    return newsb;
}

- (id)initWithDifficulty: (NSInteger)inDifficulty boardSize: (NSInteger)inBoardSize
{
    if (self = [super init]) {
        self.difficulty = inDifficulty;
        self.boardsize = inBoardSize;
        self.best_scores = [NSMutableArray arrayWithCapacity:BEST_SCORES];
    }
    return self;
}

- (void)dealloc
{
    //[self save];
    self.best_scores = nil;
    self.latestScore = nil;
    [super dealloc];
}

- (void)remove_highest_score
{
//    Score *cmp = nil;
//    for (Score *s in best_scores) {
//        if (nil == cmp) {
//            cmp = s;
//        }
//        else {
//            if ([s isBetterThan: cmp] >= 0) {
//                cmp = s;
//            }
//        }
//    }
//    if (nil != cmp) {
//        NSLog(@"removing score: %@",cmp);
//        [best_scores removeObject:cmp];
//    }
    [best_scores removeLastObject];
}

- (void)addScore: (Score*)score
{
    // add to latest scores, discarding earliest one
    
    NSLog(@"addScore: (difficulty %d, boardsize %d) %@",self.difficulty, self.boardsize, [score description] );
    // if better than best scores, add it to best scores
    
    self.latestScore = score;
    
    if ([best_scores count] == 0) {
        [best_scores addObject: score];
    }
    else {
        for (Score *s in best_scores) {
            if ([score isBetterThan:s] <= 0) {
                if ([best_scores count] >= BEST_SCORES) {
                    [self remove_highest_score];
                }
                NSUInteger ndx = [best_scores indexOfObject:s];
                if (ndx != NSNotFound) {
                    [best_scores insertObject:score atIndex:ndx];
                }
                else {
                    [best_scores addObject: score];
                }
                return;
            }
        }
        if ([best_scores count] < BEST_SCORES) {
            [best_scores addObject: score];
        }
    }
}

- (Score*)fewestMoves
{
    Score *best = nil;
    for (Score *s in best_scores) {
        if (nil == best)
            best = s;
        else {
            if (s.moves < best.moves) {
                best = s;
            }
        }
    }
    return best;
}

- (Score*)bestTime
{
    Score *best = nil;
    for (Score *s in best_scores) {
        if (nil == best)
            best = s;
        else {
            if (s.time < best.time) {
                best = s;
            }
        }
    }
    return best;
}

- (Score*)bestScoreAtIndex: (NSInteger)index
{
    if (index >= [best_scores count])
        return nil;
    
    return (Score*)[best_scores objectAtIndex: index];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    //[super initWithCoder: aDecoder];
    [super init];

    boardsize = [aDecoder decodeIntegerForKey:@"size"];
    difficulty = [aDecoder decodeIntegerForKey:@"level"];
    self.latestScore = [aDecoder decodeObjectForKey:@"latest"];
    self.best_scores = [aDecoder decodeObjectForKey:@"best"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //[super encodeWithCoder: aCoder];
    
    [aCoder encodeInteger:boardsize forKey:@"size"];
    [aCoder encodeInteger:difficulty forKey:@"level"];
    [aCoder encodeObject:latestScore forKey:@"latest"];
    [aCoder encodeObject:best_scores forKey:@"best"];
}

@end
