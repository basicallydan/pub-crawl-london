#import "LPCLineListViewController.h"

#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCAppDelegate.h"
#import "LPCLine.h"
#import "LPCLineTableViewCell.h"
#import "LPCLineViewController.h"
#import "LPCLineOptionModalViewController.h"
#import "LPCThemeManager.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import "LPCVenue.h"
#import "LPCVenueRetrievalHandler.h"

@interface LPCLineListViewController () <LPCLineOptionModalViewControllerDelegate>

@end

@implementation LPCLineListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)loadCrawlForLine:(LPCLineTableViewCell *)lineCell {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *lineDictionary = [appDelegate.lines objectAtIndex:lineCell.lineIndex];
    
    LPCLine *line = [[LPCLine alloc] initWithLine:lineDictionary andStations:appDelegate.stations];
    
//    NSArray *lineStations = [lineDictionary valueForKey:@"stations"];
    
    LPCLineOptionModalViewController *lineOptionController = [[LPCLineOptionModalViewController alloc] initWithLine:line];
    lineOptionController.delegate = self;
    
    [self presentViewController:lineOptionController animated:YES completion:nil];
    
//    NSDictionary *startBranches = lineStations[0];
//    NSArray *branchStartChoices = [startBranches allKeys];
    // TODO: Don't always just go with the first one you dummy
//    lineStations = [startBranches valueForKey:branchStartChoices[0]];
}

- (void)showLineViewStartingWith:(LPCLine *)line startingWith:(LPCStation *)station {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LPCLineViewController *lineViewController = [[LPCLineViewController alloc] initWithLine:line atStation:station];
    lineViewController.delegate = self;
    lineViewController.lineColour = line.lineColour;
    
    LPCVenueRetrievalHandler *venueRetrievalHandler = [LPCVenueRetrievalHandler sharedHandler];
    
    NSArray *firstStationVenues = [venueRetrievalHandler venuesForStation:station completion:^(NSArray *firstStationVenues) {
        [lineViewController addVenues:[NSArray arrayWithArray:firstStationVenues] forStationCode:station.code];
        
        [self presentViewController:lineViewController animated:YES completion:nil];
    }];
    if (firstStationVenues) {
        [lineViewController addVenues:[NSArray arrayWithArray:firstStationVenues] forStationCode:station.code];
        
        // Now that the first station has it's stuff, load it
        [self presentViewController:lineViewController animated:YES completion:nil];
    }
    
    for (LPCStation *s in line.allStations) {
        if ([s.nestoriaCode isEqualToString:station.nestoriaCode]) {
            // Already started handling got the stuff for the first one, so skip it.
            break;
        }
        NSArray *venues = [venueRetrievalHandler venuesForStation:s completion:^(NSArray *venues) {
            [lineViewController addVenues:[NSArray arrayWithArray:venues] forStationCode:s.code];
        }];
        
        if (venues) {
            [lineViewController addVenues:[NSArray arrayWithArray:venues] forStationCode:s.code];
        }
    }
}

#pragma mark - UILineOptionModalViewControllerDelegate 

- (void)didSelectStartingStation:(LPCStation *)station forLine:(LPCLine *)line {
    [self dismissViewControllerAnimated:NO completion:^{
        NSLog(@"Selected %@ as the first station", station.name);
        [self showLineViewStartingWith:line startingWith:station];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LPCLineTableViewCell *cell = (LPCLineTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Selected the %@ line", cell.lineName);

    [self loadCrawlForLine:cell];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.lines.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.frame.size.height / [self tableView:tableView numberOfRowsInSection:indexPath.section];
//    return [indexPath row] * 20;
}

- (LPCLineTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const CellIdentifier = @"Cell";

    LPCLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[LPCLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(LPCLineTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *line = [appDelegate.lines objectAtIndex:indexPath.row];
    cell.lineIndex = indexPath.row;
    cell.lineName = [line valueForKey:@"name"];
    cell.textLabel.text = cell.lineName;
    
    UIColor *cellColor = [UIColor colorWithHexString:[line valueForKey:@"background-color"]];
    UIColor *textColor = [UIColor colorWithHexString:[line valueForKey:@"text-color"]];
    
    cell.backgroundColor = cellColor;
    cell.textLabel.textColor = textColor;
}

#pragma mark - LPCStationViewControllerDelegate

- (void)didClickChangeLine {
    if (self.presentedViewController.presentedViewController) {
        [self.presentedViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
