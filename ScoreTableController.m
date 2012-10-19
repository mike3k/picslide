//
//  ScoreTableController.m
//  PicSlide
//
//  Created by Mike Cohen on 11/9/09.
//  Copyright 2009 MC Development. All rights reserved.
//

#import "ScoreTableController.h"
#import "ScoreTableCell.h"

#import "Scoreboard.h"

@implementation ScoreTableController

@synthesize scores;
@synthesize delegate;
@synthesize last;
@synthesize aMsg;
@synthesize aCell;

@synthesize level;
@synthesize size;


/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/* */
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (nil != last) {
        aMsg.text = [last description];
    }
    else {
        aMsg.text = nil;
        [fButton setHidden: YES];
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [sizeSelector insertSegmentWithTitle:@"10x10" atIndex:3 animated:NO];
        [sizeSelector insertSegmentWithTitle:@"12x12" atIndex:4 animated:NO];
        [sizeSelector insertSegmentWithTitle:@"16x16" atIndex:5 animated:NO];
    }
#endif
    [self updateTabs];
}
/* */

/* */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
/* */
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/* */
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
/* */
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark IBActions

- (IBAction) close: (id)sender
{
    [self.delegate dismissModalViewControllerAnimated:YES];
}

- (IBAction) share: (id)sender
{
    [self.delegate shareOnFacebook: last];
}

- (IBAction) changeLevel: (id) sender
{
    if (sender == levelSelector) {
        //NSLog(@"changeLevel: %d",[sender selectedSegmentIndex]);
        self.level = [Score shuffleCount: [sender selectedSegmentIndex]]; 
    }
    else if (sender == sizeSelector) {
        //NSLog(@"changeSize: %d",[sender selectedSegmentIndex]);
        //self.size = ([sender selectedSegmentIndex] == 0) ? 4 : 8;
        switch ([sender selectedSegmentIndex]) {
            case 0:
                self.size = 4;
                break;
            case 1:
                self.size = 8;
                break;
            case 2:
                self.size = 10;
                break;
            case 3:
                self.size = 12;
                break;
            default:
                self.size = 16;
        }
    }
    [self updateLevel];
}

- (void) updateTabs
{
    //NSLog(@"updateTabs: level=%d, size=%d",self.level,self.size);
    levelSelector.selectedSegmentIndex = [Score difficulty: self.level];
    //sizeSelector.selectedSegmentIndex = (self.size == 4) ? 0 : 1;
    switch (self.size) {
        case 4:
            sizeSelector.selectedSegmentIndex = 0;
            break;
        case 8:
            sizeSelector.selectedSegmentIndex = 1;
            break;
        case 10:
            sizeSelector.selectedSegmentIndex = 2;
            break;
        case 12:
            sizeSelector.selectedSegmentIndex = 3;
            break;
        default:
            sizeSelector.selectedSegmentIndex = 4;
            break;
    }
}

- (void) updateLevel
{
    self.scores = [Scoreboard scoresForBoardSize:self.size difficulty:self.level];
    [theTable reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [scores.best_scores count] + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"aCell";
    
    ScoreTableCell *cell = (ScoreTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [[NSBundle mainBundle] loadNibNamed:@"ScoreCell" owner:self options:nil];
        cell = aCell;
        self.aCell = nil;
    }
    
    // Set up the cell...
    if (indexPath.row == 0) {
        cell.name.text = @"Picture";
        cell.name.font = [UIFont boldSystemFontOfSize: 16.0];
        cell.moves.text = @"Moves";
        cell.moves.font = [UIFont boldSystemFontOfSize: 16.0];
        cell.time.text = @"Time";
        cell.time.font = [UIFont boldSystemFontOfSize: 16.0];
    }
    else if (indexPath.row <= [scores.best_scores count]) {
        Score *sc = [scores bestScoreAtIndex: indexPath.row - 1];
        cell.name.text = sc.title;
        cell.moves.text = [NSString stringWithFormat: @"%d",sc.moves];
        cell.time.text = [NSString stringWithFormat: @"%02d:%02d:%02d",sc.time / 3600, sc.time / 60, sc.time % 60];
    }
    else {
        //cell.textLabel.text = nil;
    }
	
    return (UITableViewCell*)cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
    //[self.delegate dismissModalViewControllerAnimated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

