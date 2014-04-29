#import "LPCLineListViewController.h"

#import "LPCAppDelegate.h"
#import "LPCCreditsCell.h"
#import "LPCCreditsTextLabel.h"
#import "LPCCreditsView.h"
#import "LPCLine.h"
#import "LPCLineOptionModalViewController.h"
#import "LPCCreditsViewController.h"
#import "LPCLineTableViewCell.h"
#import "LPCLineViewController.h"
#import "LPCOptionsCell.h"
#import "LPCSettingsHelper.h"
#import "LPCThemeManager.h"
#import "LPCVenue.h"
#import "LPCVenueRetrievalHandler.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <Analytics/Analytics.h>
#import <CGLMail/CGLMailHelper.h>
#import <ChimpKit/ChimpKit.h>
#import <IAPHelper/IAPShare.h>
#import <NSString+FontAwesome.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import <NSAttributedStringMarkdownParser/NSAttributedStringMarkdownParser.h>

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
NSInteger const statusBarHeight = 20;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    lineCells = [[NSMutableArray alloc] initWithCapacity:10];
    UIEdgeInsets inset = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    self.tableView.contentInset = inset;
    [self.tableView setBackgroundColor:[self backgroundColorForLine:0]];
    CGRect maskFrame = self.tableView.frame;
    maskFrame.size.height /= 2;
    maskFrame.origin.y = self.tableView.frame.size.height - [self standardRowHeight] - (statusBarHeight / 2);
    UIView *bottomWhiteMask = [[UIView alloc] initWithFrame:maskFrame];
    [bottomWhiteMask setBackgroundColor:[UIColor whiteColor]];
    [self.tableView addSubview:bottomWhiteMask];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
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

- (void)viewDidAppear:(BOOL)animated {
    if (!creditsView) {
        creditsView = [[LPCCreditsView alloc] initFromTableView:self.tableView andCells:lineCells];
        creditsView.delegate = self;
        
        UISwipeGestureRecognizer *closeCreditsSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideCredits)];
        closeCreditsSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [creditsView addGestureRecognizer:closeCreditsSwipe];
        
        [self.view addSubview:creditsView];
        
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
        [self.view setNeedsUpdateConstraints];
    }
}

#pragma mark - Private Methods

- (CGFloat)standardRowHeight {
    return (self.tableView.frame.size.height - statusBarHeight) / ([self tableView:self.tableView numberOfRowsInSection:0] - 1);
}

- (void)loadCrawlForLine:(LPCLineTableViewCell *)lineCell {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *lineDictionary = [appDelegate.lines objectAtIndex:lineCell.lineIndex];
    
    LPCLine *line = [[LPCLine alloc] initWithLine:lineDictionary andStations:appDelegate.stations];
    
    LPCLineOptionModalViewController *lineOptionController = [[LPCLineOptionModalViewController alloc] initWithLine:line];
    lineOptionController.delegate = self;
    
    [self presentViewController:lineOptionController animated:YES completion:nil];
}

- (void)showLineViewStartingWith:(LPCLine *)line startingWith:(LPCStation *)station {
    LPCLineViewController *lineViewController = [[LPCLineViewController alloc] initWithLine:line atStation:station withDelegate:self completion:nil];
    lineViewController.lineColour = line.lineColour;
    [self presentViewController:lineViewController animated:YES completion:nil];
}

- (void)showCredits {
    [[Analytics sharedAnalytics] track:@"Opened credits"];

    CGFloat width = self.view.bounds.size.width;
    LPCCreditsViewController *creditsViewController = [[LPCCreditsViewController alloc] initWithCells:lineCells andOffset:self.tableView.frame.origin.y - self.tableView.contentOffset.y];
    creditsViewController.view.frame = CGRectMake(self.view.frame.origin.x + width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.superview addSubview:creditsViewController.view];
    [UIView animateWithDuration:.5 animations:^{
        self.view.center = CGPointMake(self.view.center.x - width, self.view.center.y);
        creditsViewController.view.center = CGPointMake(creditsViewController.view.center.x - width, creditsViewController.view.center.y);
        
    } completion:^(BOOL finished) {
        [self.navigationController pushViewController:creditsViewController animated:NO];
    }];
}

- (UIColor *)backgroundColorForLine:(int)lineNumber {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *line = [appDelegate.lines objectAtIndex:lineNumber];
    
    UIColor *cellColor = [UIColor colorWithHexString:[line valueForKey:@"background-color"]];
    return cellColor;
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
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    creditsView.frame = finalCreditsViewFrame;
    self.tableView.frame = finalTableViewFrame;
    [UIView commitAnimations];
    
//    [UIView animateWithDuration:0.4f animations:^{
//        creditsView.frame = finalCreditsViewFrame;
//        self.tableView.frame = finalTableViewFrame;
//    }];
//    [UIView animateWithDuration:0.2f animations:^{
//        self.tableView.contentOffset = CGPointMake(0, 0);
//    } completion:^(BOOL finished) {
//    }];
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
- (void)didCancelStationSelection:(BOOL)ownershipChanged {
    if (ownershipChanged) {
        [self.tableView reloadData];
    }
}

- (void)didSelectStartingStation:(LPCStation *)station forLine:(LPCLine *)line {
    [self dismissViewControllerAnimated:NO completion:^{
        NSLog(@"Selected %@ as the first station", station.name);
        [self showLineViewStartingWith:line startingWith:station];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[LPCLineTableViewCell class]]) {
        // Must be the options cell
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }

    [self loadCrawlForLine:(LPCLineTableViewCell *)cell];
    [[Analytics sharedAnalytics] track:@"Selected a line" properties: @{ @"line" : ((LPCLineTableViewCell *)cell).lineName }];
    NSLog(@"Selected the %@ line", ((LPCLineTableViewCell *)cell).lineName);
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
    return (self.tableView.frame.size.height - statusBarHeight) / ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1);
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
    
    UIColor *cellColor = [self backgroundColorForLine:indexPath.row];
    UIColor *textColor = [UIColor colorWithHexString:[line valueForKey:@"text-color"]];
    
    NSString *iapProductIdentifier = [line valueForKey:@"iap-product-identifier"];
    
    if (iapProductIdentifier && ![[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:iapProductIdentifier] && ![[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:allTheLinesKey]) {
        NSLog(@"The user does not own the %@ line", cell.lineName);
        [cell.lockedLabel setText:[NSString fontAwesomeIconStringForEnum:FAIconLock]];
        UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
        [cell.lockedLabel setHidden:NO];
        [cell.lockedLabel setFont:font];
        [cell.lockedLabel setTextColor:[LPCThemeManager lightenOrDarkenColor:cellColor]];
    } else {
        [cell.lockedLabel setHidden:YES];
    }
    
    cell.backgroundColor = cellColor;
    cell.textLabel.textColor = textColor;
}

#pragma mark - LPCLineViewControllerDelegate

- (void)didClickChangeLine {
    if (self.presentedViewController.presentedViewController) {
        [self.tableView reloadData];
        [self.presentedViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.presentedViewController) {
        [self.tableView reloadData];
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - LPCOptionsCellDelegate

- (void)aboutButtonClicked {
    [self showCredits];
}

- (void)happilyButtonClicked {
    NSLog(@"Opening the Happily Website");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.happilyltd.co"]];
}

- (void)helpButtonClicked {
    NSAttributedStringMarkdownParser* parser = [[NSAttributedStringMarkdownParser alloc] init];
    UIView *helpView = [[UIView alloc] initWithFrame:self.tableView.frame];
    UIColor *transparentBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    helpView.backgroundColor = transparentBlack;
    UILabel *helpLabel = [[UILabel alloc] initWithFrame:((UITableViewCell *)lineCells[0]).frame];
    [helpLabel setAttributedText:[parser attributedStringFromMarkdownString:@"Select a line to get started"]];
    [self.view addSubview:helpView];
}
@end
