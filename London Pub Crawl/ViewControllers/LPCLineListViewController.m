#import "LPCLineListViewController.h"

#import "LPCAppDelegate.h"
#import "LPCCreditsCell.h"
#import "LPCCreditsTextLabel.h"
#import "LPCLine.h"
#import "LPCLineOptionModalViewController.h"
#import "LPCLineTableViewCell.h"
#import "LPCLineViewController.h"
#import "LPCOptionsCell.h"
#import "LPCThemeManager.h"
#import "LPCSettingsHelper.h"
#import "LPCVenue.h"
#import "LPCVenueRetrievalHandler.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <Analytics/Analytics.h>
#import <ChimpKit/ChimpKit.h>
#import <IAPHelper/IAPShare.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import "LPCCreditsView.h"
#import <CGLMail/CGLMailHelper.h>

// In-App Purchases
//#import "LPCPurchaseHelper.h"
//#import <StoreKit/StoreKit.h>

@interface LPCLineListViewController () <LPCLineOptionModalViewControllerDelegate, LPCOptionsCellDelegate, LPCCreditsViewDelegate>

@end

@implementation LPCLineListViewController {
    NSMutableArray *lineCells;
    LPCCreditsView *creditsView;
}

CGFloat const maxRowHeight = 101.45f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    lineCells = [[NSMutableArray alloc] initWithCapacity:10];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    [[Analytics sharedAnalytics] track:@"Opened credits"];
    if (!creditsView) {
        creditsView = [[LPCCreditsView alloc] initFromTableView:self.tableView andCells:lineCells];
        creditsView.delegate = self;
        
        UISwipeGestureRecognizer *closeCreditsSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideCredits)];
        closeCreditsSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [creditsView addGestureRecognizer:closeCreditsSwipe];
        
        [self.view addSubview:creditsView];
    }
    
    CGRect finalTableViewFrame = self.tableView.frame;
    finalTableViewFrame.origin.x = -finalTableViewFrame.size.width;
    CGRect finalCreditsViewFrame = self.tableView.frame;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.contentOffset = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4f animations:^{
            creditsView.frame = finalCreditsViewFrame;
            [creditsView setNeedsDisplay];
            self.tableView.frame = finalTableViewFrame;
        }];
    }];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = creditsView.frame;
        f.origin.y = -90.0f;
        creditsView.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = creditsView.frame;
        f.origin.y = self.tableView.frame.origin.y;
        creditsView.frame = f;
    }];
}

- (void)hideCredits {
    CGRect finalTableViewFrame = self.tableView.frame;
    finalTableViewFrame.origin.x = 0.0f;
    CGRect finalCreditsViewFrame = self.tableView.frame;
    finalCreditsViewFrame.origin.x = finalCreditsViewFrame.size.width;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.contentOffset = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4f animations:^{
            creditsView.frame = finalCreditsViewFrame;
            self.tableView.frame = finalTableViewFrame;
        }];
    }];
}

#pragma mark - LPCCreditsViewDelegate
- (void)didClickEmail:(NSString *)emailAddress {
    UIViewController *mailVC = [CGLMailHelper supportMailViewControllerWithRecipient:emailAddress subject:@"Pub Crawl: London" completion:nil];
    [self presentViewController:mailVC animated:YES completion:nil];
}

- (void)didCloseCreditsView {
    [self hideCredits];
}

- (void)didSubmitEmailAddress:(NSString *)emailAddress {
    [[ChimpKit sharedKit] setApiKey:[[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-key"]];
    
    NSDictionary *params = @{@"id": [[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-list-id"], @"email": @{@"email": emailAddress}, @"merge_vars": @{
                                     @"groupings":@[
                                             @{
                                                 @"name":[[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-grouping-name"],
                                                 @"groups":@[[[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-group-name"]]
                                                 }
                                             ]}
                             };
    [[ChimpKit sharedKit] callApiMethod:@"lists/subscribe" withParams:params andCompletionHandler:^(ChimpKitRequest *request, NSError *error) {
        NSLog(@"HTTP Status Code: %d", request.response.statusCode);
        NSLog(@"Response String: %@", request.responseString);
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
        
        [lineCells addObject:cell];

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
