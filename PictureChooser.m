//
//  PictureChooser.m
//  PicSlide
//
//  Created by Mike Cohen on 8/23/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "PictureChooser.h"
#import "UserSettings.h"
#import "Picture.h"
#import "Panda.h"

@implementation PictureChooser

@synthesize picUrls;
@synthesize delegate;
@synthesize tvCell;
@synthesize cellBackground;
@synthesize tableBackground;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (UIImage *)getCachedImage: (id)url
{
    NSString *key = [url isKindOfClass:[NSURL class]] ? [url absoluteString] : url;
    UIImage* theImage = [imageCache objectForKey:key];
    if ((nil != theImage) && [theImage isKindOfClass:[UIImage class]]) {
        return theImage;
    }
    else {
        theImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:(key == url) ? [NSURL URLWithString: key] : url]];
        [imageCache setObject:theImage forKey:key];
        return theImage;
    }
}

- (void)PandaFinishedLoading: (id)notification
{
    [theTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // note that a retained object is returned, so we're not using the setter which will retain it
    picUrls = (NSArray*)CFBundleCopyResourceURLsOfType(CFBundleGetMainBundle(), CFSTR("jpg"), nil);

    self.cellBackground = [UIColor colorWithRed: 1.0 green: (204.0/256.0) blue:(102.0/256.0) alpha:1.0];;
    theTable.backgroundColor = [UIColor colorWithRed: 1.0
                                                     green:(204.0 / 256.0)
                                                      blue:(102.0 / 256.0)
                                                     alpha:1.0];
    theTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTable.separatorColor = [UIColor clearColor];
    if ([theTable respondsToSelector: @selector(setBackgroundView:)]) {
        theTable.backgroundView = [[UIImageView alloc] initWithImage: theBackground.image];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(PandaFinishedLoading:) 
                                                 name:@"PandaFinishedLoading" 
                                               object:nil];
    if (nil == panda) {
        panda = [[Panda alloc] init];
    }
    else {
        [panda load];
    }
    if (nil == imageCache) {
        imageCache = [[NSMutableDictionary alloc] init];
    }
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/* */
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/* */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.picUrls = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PandaFinishedLoading" object:nil];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return (section == 0) ? 1: [picUrls count];
    //return [picUrls count]+1;
    switch(section) {
        case 0: 
            return 1;
            break;
        case 1:
            // we don't want to show more than 5 pics from the panda
            return (panda && panda.done) ? MIN(10, [panda count]) : 1;
            break;
        default:
            return [picUrls count];
            break;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"tvCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [[NSBundle mainBundle] loadNibNamed:@"tvCell" owner:self options:nil];
        cell = tvCell;
        self.tvCell = nil;
    }
    
    // Set up the cell...
    cell.backgroundColor = self.cellBackground;
    //if (indexPath.row >= [picUrls count]) {
    if (indexPath.section == 0) {
        if ([cell respondsToSelector: @selector(textLabel)]) {
            cell.textLabel.text = nil;
        }
        else cell.text = nil;
        UILabel *label = (UILabel*)[cell viewWithTag: 1];
        UIImageView *img = (UIImageView*)[cell viewWithTag: 2];
        label.text = @"Choose your own...";
        img.image = nil;
    }
    else if (indexPath.section == 1) {
        if (panda.done) {
            Picture *pic = [panda objectAtIndex:indexPath.row];
            NSString *title = pic.title;
            UILabel *label = (UILabel*)[cell viewWithTag: 1];
            UIImageView *img = (UIImageView*)[cell viewWithTag: 2];
            label.text = title;
            //img.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString: pic.thumbnail]]];
            img.image = [self getCachedImage:pic.thumbnail];
            if ([cell respondsToSelector:@selector(textLabel)]) {
                cell.textLabel.text = nil;
            }
            else cell.text = nil;
        }
        else {
            if ([cell respondsToSelector: @selector(textLabel)]) {
                cell.textLabel.text = nil;
            }
            else cell.text = nil;
            UILabel *label = (UILabel*)[cell viewWithTag: 1];
            UIImageView *img = (UIImageView*)[cell viewWithTag: 2];
            label.text = @"The Magic Panda is busy…";
            img.image = nil;
        }
    }
    else {
        NSURL *url = (NSURL*)[picUrls objectAtIndex: indexPath.row];
        
        NSString *title = [[[url path] lastPathComponent] stringByDeletingPathExtension];
        UILabel *label = (UILabel*)[cell viewWithTag: 1];
        UIImageView *img = (UIImageView*)[cell viewWithTag: 2];
        label.text = title;
        //img.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        img.image = [self getCachedImage:url];
        if ([cell respondsToSelector:@selector(textLabel)]) {
            cell.textLabel.text = nil;
        }
        else cell.text = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
    //if (indexPath.row >= [picUrls count]) {
    if (indexPath.section == 0) {
        // Picker is displayed asynchronously.
        //s.allowSave = NO;
        [self.delegate performSelector:@selector(chooseCameraRoll) withObject:nil afterDelay:1.0];
        [self.delegate dismissModalViewControllerAnimated: YES];
        //[self.delegate chooseCameraRoll];
    }
    else if (indexPath.section == 1) {
        UserSettings *s = [UserSettings current];
        @try {
            s.picture = [[panda objectAtIndex: indexPath.row] fullsize];
            s.allowSave = YES;
        }
        @catch (NSException * e) {
            return;
        }
        s.boardState = nil;
        s.userImage = YES;
        [s saveSettings];
        [self done: tableView];
    }
    else {
        UserSettings *s = [UserSettings current];
        s.picture = [[picUrls objectAtIndex: indexPath.row] absoluteString];
        s.boardState = nil;
        s.userImage = NO;
        s.allowSave = NO;
        [s saveSettings];
        [self done: tableView];
    }
}

- (IBAction)done: (id)sender
{
    [self.delegate dismissModalViewControllerAnimated:YES];
    [self.delegate pictureChosen];
}

- (IBAction)close: (id)sender
{
    [self.delegate dismissModalViewControllerAnimated:YES];

}

- (void)dealloc {
    if (nil != imageCache) {
        [imageCache release];
        imageCache = nil;
    }
    [panda release];
    self.picUrls = nil;
    [super dealloc];
}

@end

