//
//  Picture.h
//  PicSlide
//
//  Created by Mike Cohen on 5/30/10.
//  Copyright 2010 MC Development. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Picture : NSObject {
    NSString *_fullsize;
    NSString *_thumbnail;
    NSString *_title;
}

@property (retain,nonatomic) NSString *fullsize;
@property (retain,nonatomic) NSString *thumbnail;
@property (retain,nonatomic) NSString *title;

- (id)initWithFullSize: (NSString*)inFull thumbnail: (NSString*)inThumb title: (NSString*)inTitle;

+ (Picture*)PictureWithFullSize:(NSString*)inFull thumbnail: (NSString*)inThumb title: (NSString*)inTitle;

@end
