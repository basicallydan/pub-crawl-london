#import "LPCLineListViewController.h"

#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCAppDelegate.h"
#import "LPCLine.h"
#import "LPCLineTableViewCell.h"
#import "LPCLineViewController.h"
#import "LPCLineOptionModalViewController.h"
#import "LPCThemeManager.h"
#import <UIColor-HexString/UIColor+HexString.h>

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
    int startingStationIndex = 27;
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *lineDictionary = [appDelegate.lines objectAtIndex:lineCell.lineIndex];
    
    LPCLine *line = [[LPCLine alloc] initWithLine:lineDictionary];
    
    NSArray *lineStations = [lineDictionary valueForKey:@"stations"];
    
    if ([lineStations[0] isKindOfClass:[NSString class]]) {
        // This means we have a standard main-line start
        [self showLineViewWithStations:lineStations onLine:lineDictionary atStation:startingStationIndex];
    } else {
        // This means we will have to start on one of the branches
        
        LPCLineOptionModalViewController *lineOptionController = [[LPCLineOptionModalViewController alloc] initWithStartingStations:line.leafStations];
        lineOptionController.delegate = self;
        
        [self presentViewController:lineOptionController animated:YES completion:nil];
        
        NSDictionary *startBranches = lineStations[0];
        NSArray *branchStartChoices = [startBranches allKeys];
        // TODO: Don't always just go with the first one you dummy
        lineStations = [startBranches valueForKey:branchStartChoices[0]];
    }
}

- (void)showLineViewWithStations:(NSArray *)lineStations onLine:(NSDictionary *)lineDictionary atStation:(int)startingStationIndex {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LPCLineViewController *lineViewController = [[LPCLineViewController alloc] initWithStationIndex:startingStationIndex];
    
    lineViewController.stations = lineStations;
    lineViewController.lineColour = [UIColor colorWithHexString:[lineDictionary valueForKey:@"background-color"]];
    lineViewController.bottomOfLineDirection = [lineDictionary valueForKey:@"bottom-direction"]; // This is the direction we're heading in if we're going toward the end of the array of stations
    lineViewController.topOfLineDirection = [lineDictionary valueForKey:@"top-direction"]; // This is the direction we're heading in fi we're going toward the start of the array of stations
    
    for (NSString *s in lineViewController.stations) {
        if ([s isKindOfClass:[NSString class]]) {
            NSDictionary *station = [appDelegate.stations objectForKey:s];
            NSArray *venues = [appDelegate.pubs valueForKey:[station valueForKey:@"code"]];
            
            NSDictionary *venue = venues[0];
            [lineViewController addVenue:venue forStationCode:[station valueForKey:@"code"]];
        }
    }
    
    lineViewController.delegate = self;
    
    [self presentViewController:lineViewController animated:YES completion:nil];
}

#pragma mark - UILineOptionModalViewControllerDelegate 

- (void)didSelectStartingStation:(NSString *)station {
    NSLog(@"Selected %@ as the first station", station);
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
