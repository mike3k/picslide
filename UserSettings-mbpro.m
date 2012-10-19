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

static NSInteger _counts[] = { 4, 4, 8, 16 };
static NSInteger _sizes[] = { 4, 8, 8, 8 };

+ (UserSettings*)current
{
    if (theSettings == NULL) {
        theSettings = [[UserSettings alloc] initDefault];
    }
    return theSettings;
}

- (void)setSizeAndCountFromLevel
{
    if (self.level < 0)
        self.level = 1;
    if (self.level > 4)
        self.level = 4;
    
    self.boardSize = _sizes[self.level-1];
    self.shuffleCount = _counts[self.level-1];
}

- (id)initDefault
{
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.level = [defaults integerForKey: @"level"];
        if (self.level == 0) {
            self.level = 2;
            self.shuffleCount = 4;
            self.boardSize = 8;
            self.picture = (NSString*)CFURLGetString(CFBundleCopyResourceURL(CFBundleGetMainBundle(),
                                                                             CFSTR("Garden"),
                                                                             CFSTR("jpg"),
                                                                             NULL));
        }
        else {
            self.shuffleCount = [defaults integerForKey: @"shuffleCount"];
            self.boardSize = [defaults integerForKey: @"boardSize"];
            self.picture = [defaults stringForKey:@"picture"];
        }
        // todo: read user preferences
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
}

- (void)dealloc
{
    [self saveSettings];
    [super dealloc];
}

@end
