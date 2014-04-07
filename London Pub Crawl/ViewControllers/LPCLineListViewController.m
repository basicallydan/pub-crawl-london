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
#import "LPCCreditsCell.h"
#import "LPCCreditsTextLabel.h"

// In-App Purchases
//#import "LPCPurchaseHelper.h"
//#import <StoreKit/StoreKit.h>

@interface LPCLineListViewController () <LPCLineOptionModalViewControllerDelegate, LPCOptionsCellDelegate>

@end

@implementation LPCLineListViewController {
    NSMutableArray *lineCells;
    UIView *creditsView;
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
    if (!creditsView) {
        UIImage *foursquareLogo = [UIImage imageNamed:@"foursquare-logo.png"];
        UIImage *mapBoxLogo = [UIImage imageNamed:@"mapbox-logo.png"];
        UIImage *tflLogo = [UIImage imageNamed:@"tfl-logo.png"];
        
        CGRect creditsViewStartingFrame = self.tableView.frame;
        creditsViewStartingFrame.origin.x = creditsViewStartingFrame.size.width;
        creditsView = [[UIView alloc] initWithFrame:creditsViewStartingFrame];
        int cellNumber = 0;
        for (LPCLineTableViewCell *cell in lineCells) {
            
            UIView *creditsCell = [[LPCCreditsCell alloc] initBasedOnCell:cell];
            UILabel *creditsLabel = [[LPCCreditsTextLabel alloc] initForCell:cell];
            
            if (cellNumber == 0) {
                [creditsCell addSubview:creditsLabel];
                [creditsLabel setText:@"Pub Crawl: LDN is a Happily Project\nCreated in London, UK"];
            } else if (cellNumber == 1) {
                [creditsCell addSubview:creditsLabel];
                [creditsLabel setText:@"For more visit happilyltd.co\nWe're very grateful for data from"];
            } else if (cellNumber == 2) {
                UIImageView *foursquareImageView = [[UIImageView alloc] initWithImage:foursquareLogo];
                CGRect foursquareFrame = foursquareImageView.frame;
                foursquareFrame.origin = creditsLabel.frame.origin;
                foursquareFrame.origin.y = (creditsCell.frame.size.height - foursquareFrame.size.height) / 2;
                foursquareImageView.frame = foursquareFrame;
                
                UIImageView *mapBoxImageView = [[UIImageView alloc] initWithImage:mapBoxLogo];
                CGRect mapBoxFrame = mapBoxImageView.frame;
                mapBoxFrame.origin.y = (creditsCell.frame.size.height - mapBoxFrame.size.height) / 2;
                mapBoxFrame.origin.x = creditsCell.frame.size.width - mapBoxFrame.size.width - foursquareFrame.origin.x;
                mapBoxImageView.frame = mapBoxFrame;
                
                UIImageView *tflImageView = [[UIImageView alloc] initWithImage:tflLogo];
                CGRect tflFrame = tflImageView.frame;
                tflFrame.origin.y = (creditsCell.frame.size.height - tflFrame.size.height) / 2;
                CGFloat foursquareRightEdge = foursquareFrame.origin.x + foursquareFrame.size.width;
                CGFloat middleSpace = mapBoxFrame.origin.x - foursquareRightEdge;
                tflFrame.origin.x = foursquareRightEdge + ((middleSpace - tflFrame.size.width) / 2);
                tflImageView.frame = tflFrame;
                
                [creditsCell addSubview:foursquareImageView];
                [creditsCell addSubview:tflImageView];
                [creditsCell addSubview:mapBoxImageView];
            } else if (cellNumber == 9) {
                UIButton *doneButton = [[UIButton alloc] initWithFrame:creditsLabel.frame];
                [doneButton setTitle:@"Great!" forState:UIControlStateNormal];
                [doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [doneButton addTarget:self action:@selector(hideCredits) forControlEvents:UIControlEventTouchUpInside];
                doneButton.backgroundColor = [UIColor whiteColor];
                [creditsCell addSubview:doneButton];
            }
            
            [creditsView addSubview:creditsCell];
            
            cellNumber++;
        }
        
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
