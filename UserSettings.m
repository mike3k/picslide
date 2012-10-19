//
//  UserSettings.m
//  PicSlide
//
//  Created by Mike Cohen on 8/22/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "UserSettings.h"

static UserSettings *theSettings = NULL;

@implementation UserSettings

@synthesize boardSize;
@synthesize shuffleCount;
@synthesize level;
@synthesize picture;
@synthesize hints;
@synthesize boardState;
@synthesize elapsedTime;
@synthesize sound;
@synthesize moves;
@synthesize userImage;
@synthesize allowSave;

static NSInteger _counts[] = { kEasyCount, kMediumCount, kHardCount, kImpossibleCount };
//static NSInteger _sizes[] = { 4, 8, 8, 8 };

+ (UserSettings*)current
{
    if (theSettings == NULL) {
        theSettings = [[UserSettings alloc] initDefault];
    }
    return theSettings;
}

- (void)setSizeAndCountFromLevel
{
    if (self.level < 1)
        self.level = 1;
    if (self.level > 4)
        self.level = 4;
    
    //self.boardSize = _sizes[self.level-1];
    self.shuffleCount = _counts[self.level-1];
}

- (id)initDefault
{
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.allowSave = NO;
        self.level = [defaults integerForKey: @"level"];
        if (self.level == 0) {
            self.level = 2;
            self.shuffleCount = 7;
            self.boardSize = 4;
            self.userImage = NO;
            self.sound = YES;
            self.hints = YES;
            self.picture = (NSString*)CFURLGetString(CFBundleCopyResourceURL(CFBundleGetMainBundle(),
                                                                             CFSTR("Garden"),
                                                                             CFSTR("jpg"),
                                                                             NULL));
            self.boardState = nil;
            self.elapsedTime = 0;
            self.moves = 0;
        }
        else {
            self.shuffleCount = [defaults integerForKey: @"shuffleCount"];
            self.boardSize = [defaults integerForKey: @"boardSize"];
            self.picture = [defaults stringForKey:@"picture"];
            self.hints = [defaults boolForKey: @"hints"];
            self.sound = [defaults boolForKey: @"sound"];
            self.boardState = [defaults dataForKey:@"state"];
            self.elapsedTime = [defaults integerForKey:@"elapsedTime"];
            self.moves = [defaults integerForKey: @"moves"];
            self.userImage = [defaults boolForKey: @"userImage"];
        }
    }
    return self;
}

- (void)saveSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger: self.level forKey: @"level"];
    [defaults setInteger: self.shuffleCount forKey:@"shuffleCount"];
    [defaults setInteger: self.boardSize forKey:@"boardSize"];
    [defaults setObject: self.picture forKey:@"picture"];
    [defaults setBool: self.hints forKey:@"hints"];
    [defaults setBool: self.sound forKey:@"sound"];
    [defaults setObject:self.boardState forKey:@"state"];
    [defaults setInteger: self.elapsedTime forKey:@"elapsedTime"];
    [defaults setInteger: self.moves forKey: @"moves"];
    [defaults setBool: self.userImage forKey:@"userImage"];
}

- (void)dealloc
{
    [self saveSettings];
    [super dealloc];
}

@end
