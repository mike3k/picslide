//
//  Panda.h
//  PicSlide
//
//  Created by Mike Cohen on 5/23/10.
//  Copyright 2010 MC Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Panda : NSObject {
    NSURLConnection *_connection;
    NSXMLParser *_parser;
    
    NSMutableArray *_results;
    NSMutableData *_data;

    BOOL _done;
    BOOL _loading;
    BOOL _parsing;
}

- (void)load;
- (int) count;
- (id) objectAtIndex: (NSUInteger)index;

@property (retain,nonatomic) NSMutableArray *results;
@property (assign,nonatomic) BOOL done;
@property (assign,nonatomic) BOOL loading;
@property (assign,nonatomic) BOOL parsing;

@end
