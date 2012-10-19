//
//  PictureChooser.h
//  PicSlide
//
//  Created by Mike Cohen on 8/23/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Panda;

@interface PictureChooser : UIViewController {

    UIColor *cellBackground;
    UIImage *tableBackground;
    UITableViewCell *tvCell;
    id delegate;

    IBOutlet UITableView* theTable;
    IBOutlet UIImageView* theBackground;
    
    NSArray *picUrls;
    Panda *panda;
    
    NSMutableDictionary *imageCache;
}

- (IBAction)done: (id)sender;
- (IBAction)close: (id)sender;

- (UIImage *)getCachedImage: (id)url;

- (void)PandaFinishedLoading: (id)notification;

@property (retain,nonatomic) NSArray* picUrls;
@property (assign,nonatomic) id delegate;
@property (assign,nonatomic) IBOutlet UITableViewCell *tvCell;
@property (retain,nonatomic) UIColor *cellBackground;
@property (retain,nonatomic) UIImage *tableBackground;

@end
