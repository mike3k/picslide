//
//  UserSettings.h
//  PicSlide
//
//  Created by Mike Cohen on 8/22/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserSettings : NSObject {
    NSInteger boardSize;
    NSInteger shuffleCount;
    NSInteger level;
    NSInteger elapsedTime;
    NSInteger moves;

    BOOL hints;
    BOOL sound;
    BOOL userImage;
    BOOL allowSave;

    NSData *boardState;
    
    NSString *picture;
}

@property (assign,nonatomic) NSInteger boardSize;
@property (assign,nonatomic) NSInteger shuffleCount;
@property (assign,nonatomic) NSInteger level;
@property (assign,nonatomic) NSInteger elapsedTime;
@property (assign,nonatomic) NSInteger moves;
@property (assign,nonatomic) BOOL hints;
@property (assign,nonatomic) BOOL sound;
@property (assign,nonatomic) BOOL userImage;
@property (assign,nonatomic) BOOL allowSave;
@property (retain,nonatomic) NSString* picture;
@property (retain,nonatomic) NSData *boardState;

+ (UserSettings*)current;
- (id)initDefault;
- (void)saveSettings;
- (void)setSizeAndCountFromLevel;

@end
