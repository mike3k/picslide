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
    
    NSString *picture;
}

@property (assign,nonatomic) NSInteger boardSize;
@property (assign,nonatomic) NSInteger shuffleCount;
@property (assign,nonatomic) NSInteger level;
@property (retain,nonatomic) NSString* picture;

+ (UserSettings*)current;
- (id)initDefault;
- (void)saveSettings;
- (void)setSizeAndCountFromLevel;

@end
