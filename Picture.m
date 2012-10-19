//
//  Picture.m
//  PicSlide
//
//  Created by Mike Cohen on 5/30/10.
//  Copyright 2010 MC Development. All rights reserved.
//

#import "Picture.h"


@implementation Picture

@synthesize fullsize = _fullsize;
@synthesize thumbnail = _thumbnail;
@synthesize title = _title;

+ (Picture*)PictureWithFullSize:(NSString*)inFull thumbnail: (NSString*)inThumb title: (NSString*)inTitle
{
    return [[[Picture alloc] initWithFullSize:inFull thumbnail:inThumb title:inTitle] autorelease];
}

- (id)initWithFullSize: (NSString*)inFull thumbnail: (NSString*)inThumb title: (NSString*)inTitle
{
    if ((self = [super init])) {
        self.fullsize = inFull;
        self.thumbnail = inThumb;
        self.title = inTitle;
    }
    return self;
}

- (void)dealloc
{
    self.fullsize = nil;
    self.thumbnail = nil;
    self.title = nil;
    [super dealloc];
}

@end
