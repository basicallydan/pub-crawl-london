#import "LPCLineListViewController.h"

#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCAppDelegate.h"
#import "LPCLine.h"
#import "LPCLineTableViewCell.h"
#import "LPCOptionsCell.h"
#import "LPCLineViewController.h"
#import "LPCLineOptionModalViewController.h"
#import "LPCThemeManager.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import "LPCVenue.h"
#import "LPCVenueRetrievalHandler.h"
#import <IAPHelper/IAPShare.h>

// In-App Purchases
//#import "LPCPurchaseHelper.h"
//#import <StoreKit/StoreKit.h>

@interface LPCLineListViewController () <LPCLineOptionModalViewControllerDelegate, LPCOptionsCellDelegate>

@end

@implementation LPCLineListViewController

CGFloat const maxRowHeight = 101.45f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view, typically from a nib.
//    [[LPCPurchaseHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
//        if (success) {
////            [self.tableView reloadData];
//        }
////        [self.refreshControl endRefreshing];
//    }];
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
    
    LPCLineOptionModalViewController *lineOptionController = [[LPCLineOptionModalViewController alloc] initWithLine:line];
    lineOptionController.delegate = self;
    
    [self presentViewController:lineOptionController animated:YES completion:nil];
}

- (void)showLineViewStartingWith:(LPCLine *)line startingWith:(LPCStation *)station {
    LPCLineViewController *lineViewController = [[LPCLineViewController alloc] initWithLine:line atStation:station completion:nil];
    lineViewController.delegate = self;
    lineViewController.lineColour = line.lineColour;
    [self presentViewController:lineViewController animated:YES completion:nil];
}

- (void)showCredits {
    CGRect creditsFrame = CGRectMake(0, 0, 0, 0);
    creditsFrame.origin.y = 0.0f;
    creditsFrame.origin.x = self.tableView.frame.size.width;
    creditsFrame.size.height = (self.tableView.frame.size.height / ([self tableView:self.tableView numberOfRowsInSection:0] - 1));
    creditsFrame.size.width = self.tableView.frame.size.width;
    UIView *creditsView = [[UIView alloc] initWithFrame:creditsFrame];
    creditsView.backgroundColor = [UIColor purpleColor];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.contentOffset = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        [self.tableView addSubview:creditsView];
        [UIView animateWithDuration:0.3f animations:^{
            CGRect postAnimationFrame = creditsView.frame;
            postAnimationFrame.origin.x = 0.0f;
            creditsView.frame = postAnimationFrame;
        }];
    }];
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
    // One final bit for the options cell
    return appDelegate.lines.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // The following will hide the options cell just below the fold
    return self.tableView.frame.size.height / ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1);
//    return [indexPath row] * 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)) {
        NSString *cellIdentifier = @"OptionsCell";
        
        LPCOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[LPCOptionsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.delegate = self;
        
        return cell;
    } else {
        NSString *cellIdentifier = @"LineCell";

        LPCLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[LPCLineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:(250/255.0) green:(250/255.0) blue:(250/255.0) alpha:0.3f];
        cell.selectedBackgroundView = selectionColor;

        [self configureCell:cell forRowAtIndexPath:indexPath];

        return cell;
    }
}

- (void)configureCell:(LPCLineTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *line = [appDelegate.lines objectAtIndex:indexPath.row];
    cell.lineIndex = indexPath.row;
    cell.lineName = [line valueForKey:@"name"];
    cell.textLabel.text = cell.lineName;
    
    UIColor *cellColor = [UIColor colorWithHexString:[line valueForKey:@"background-color"]];
    UIColor *textColor = [UIColor colorWithHexString:[line valueForKey:@"text-color"]];
    
    NSString *iapProductIdentifier = [line valueForKey:@"iap-product-identifier"];
    
    if (iapProductIdentifier && ![[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:iapProductIdentifier]) {
        NSLog(@"The user does not own the %@ line", cell.lineName);
    }
    
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

#pragma mark - LPCOptionsCellDelegate

- (void)helpButtonClicked {
    [self showCredits];
}

- (void)happilyButtonClicked {
    NSLog(@"Opening the Happily Website");
}
@end
