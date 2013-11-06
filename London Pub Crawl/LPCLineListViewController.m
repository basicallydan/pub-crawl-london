#import "LPCLineListViewController.h"

#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCAppDelegate.h"
#import "LPCLineTableViewCell.h"
#import "LPCLineViewController.h"
#import "LPCThemeManager.h"
#import <UIColor-HexString/UIColor+HexString.h>

@implementation LPCLineListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)loadCrawlForLine:(LPCLineTableViewCell *)lineCell {
    int startingStationIndex = 27;
    LPCLineViewController *lineViewController = [[LPCLineViewController alloc] initWithStationIndex:startingStationIndex];
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com"]];
    
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *line = [appDelegate.lines objectAtIndex:lineCell.lineIndex];
    lineViewController.stations = [line valueForKey:@"stations"];
    lineViewController.lineColour = [UIColor colorWithHexString:[line valueForKey:@"background-color"]];
    
    for (NSString *s in lineViewController.stations) {
        NSDictionary *station = [appDelegate.stations objectForKey:s];
        NSNumber *lat = [NSNumber numberWithDouble:[[station valueForKey:@"lat"] doubleValue]];
        NSNumber *lng = [NSNumber numberWithDouble:[[station valueForKey:@"lng"] doubleValue]];
        NSArray *latLng = @[lat, lng];
        NSString *searchURI = [NSString stringWithFormat:@"/v2/venues/explore?ll=%@,%@&client_id=SNE54YCOV1IR5JP14ZOLOZU0Z43FQWLTTYDE0YDKYO03XMMH&client_secret=44AI50PSJMHMXVBO1STMAUV0IZYQQEFZCSO1YXXKVTVM32OM&v=20131015&limit=1&intent=match&radius=3000&section=drinks&sortByDistance=1", latLng[0], latLng[1]];
        [sessionManager GET:searchURI parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSArray *venues = [result valueForKeyPath:@"response.groups.items"];
            if (venues.count > 0 && ((NSArray *)venues[0]).count > 0) {
                NSDictionary *venue = venues[0][0];
                [lineViewController addVenue:venue forStationCode:[station valueForKey:@"code"]];
            } else {
                NSLog(@"What?!");
            }
            
            lineViewController.delegate = self;
            
            if ([s isEqualToString:lineViewController.stations[startingStationIndex]]) {
                // We push once we have the first stop's venue
                [self presentViewController:lineViewController animated:YES completion:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            // Details!
        }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.backgroundColor = cellColor;
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
