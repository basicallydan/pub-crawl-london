#import "LPCLineOptionModalViewController.h"

#import "LPCStation.h"
#import <IAPHelper/IAPShare.h>
#import <Analytics/Analytics.h>
#import <StoreKit/StoreKit.h>
#import "LPCAppDelegate.h"

@interface LPCLineOptionModalViewController () <UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, LPCBuyLineViewDelegate>

@end

@implementation LPCLineOptionModalViewController {
    NSArray *startingStations;
    NSArray *allStations;
    LPCLine *selectedLine;
    BOOL ownershipChanged;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ownershipChanged = NO;
    }
    
    return self;
}

- (id)initWithLine:(LPCLine *)line {
    self = [self initWithNibName:@"LPCLineOptionModalViewController" bundle:nil];
    
    allStations = line.allStations;
    self.filteredStationArray = [[NSMutableArray alloc] initWithCapacity:[line.allStations count]];
    
    NSPredicate *inclusionOfStartersPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF.nestoriaCode in %@)", line.leafStations];
    NSPredicate *exclusionOfStartersPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF.nestoriaCode in %@)", line.leafStations];
    
    NSArray *justStartingStations = [NSMutableArray arrayWithArray:[allStations filteredArrayUsingPredicate:inclusionOfStartersPredicate]];
    NSArray *stationsWithoutStartingStations = [NSMutableArray arrayWithArray:[allStations filteredArrayUsingPredicate:exclusionOfStartersPredicate]];
    
    [self.filteredStationArray addObjectsFromArray:justStartingStations];
    [self.filteredStationArray addObjectsFromArray:stationsWithoutStartingStations];
    
    selectedLine = line;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (selectedLine.iapProductIdentifier) {
        if ([[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:selectedLine.iapProductIdentifier]) {
            NSLog(@"The user already owns this line");
            self.buyView.hidden = YES;
        } else if ([[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:allTheLinesKey]) {
            NSLog(@"The user already owns all the lines");
            self.buyView.hidden = YES;
        } else {
            NSLog(@"The user does not own this line but not showing the thing");
            self.buyView.hidden = YES;
//            self.buyView.hidden = NO;
//            self.buyView.delegate = self;
//            [self.buyView setLine:selectedLine];
//            [[SEGAnalytics sharedAnalytics] track:@"Presented buy modal" properties: @{ @"line" : selectedLine.name }];
//            NSLog(@"The user does not own this line. Will show the buy modal now");
        }
    } else {
        NSLog(@"This line is not buyable");
        self.buyView.hidden = YES;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [[SEGAnalytics sharedAnalytics] screen:@"Station select modal"];
}

- (IBAction)cancel:(id)sender {
    [self.delegate didCancelStationSelection:ownershipChanged];
    if (self.buyView.hidden == NO) {
        [[SEGAnalytics sharedAnalytics] track:@"Canceled buy modal" properties: @{ @"line" : selectedLine.name }];
    } else {
        [[SEGAnalytics sharedAnalytics] track:@"Canceled station select select modal" properties: @{ @"line" : selectedLine.name }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)filterContentForSearchText:(NSString *)searchText {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredStationArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[allStations filteredArrayUsingPredicate:predicate]];
//    [filteredArray removeObjectsInArray:startingStations];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    [filteredArray sortUsingDescriptors:sortDescriptors];
    
//    [self.filteredStationArray addObjectsFromArray:startingStations];
    [self.filteredStationArray addObjectsFromArray:filteredArray];
    
    self.filteredStationArray = [NSMutableArray arrayWithArray:[allStations filteredArrayUsingPredicate:predicate]];
}

- (void)hideBuyView {
    CGRect finalBuyFrame = self.buyView.frame;
    finalBuyFrame.origin.y = -finalBuyFrame.size.height;
    [UIView animateWithDuration:0.72f
        delay:0.0f
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
            self.buyView.frame = finalBuyFrame;
            self.buyView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.buyView.hidden = YES;
            NSLog(@"Animation over");
        }];
}

#pragma mark - UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    long number = [self.filteredStationArray count];
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    LPCStation *station = (LPCStation *)[self.filteredStationArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = station.name;
    
    if ([startingStations containsObject:station.nestoriaCode]) {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LPCStation *selectedStation = [self.filteredStationArray objectAtIndex:indexPath.row];
    [[SEGAnalytics sharedAnalytics] track:@"Selected station" properties:@{ @"Station" : selectedStation.name }];
    [self.delegate didSelectStartingStation:selectedStation forLine:selectedLine];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Searching for %@", searchText);
    [self filterContentForSearchText:searchText];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // TODO: Store something to reflect changes to improve the experience and performance here
    return YES;
}

@end
