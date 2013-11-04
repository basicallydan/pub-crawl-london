#import "LPCLineViewController.h"

#import "LPCAppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCForkViewController.h"
#import "LPCStationViewController.h"

@interface LPCLineViewController () <LPCForkViewControllerDelegate>

@end

@implementation LPCLineViewController

AFHTTPSessionManager *sessionManager;
NSMutableDictionary *stationResult;
NSString *destinationBranch;
NSDictionary *forkStations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithLineCode:(int)lineIndex {
    self = [super init];
    if (self) {
        stationResult = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addVenue:(NSDictionary *)venue forStationCode:(NSString *)stationCode {
    [stationResult setValue:venue forKey:stationCode];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    NSInteger startingInteger = 0;
    
    if ([self.stations count] >= 28) {
        startingInteger = 27;
    }

    UIViewController *initialViewController = [self viewControllerAtIndex:startingInteger];

    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = [(LPCStationViewController *)viewController index];

    if (index == 0) {
        return nil;
    }

    index--;
    
    UIViewController *newViewController = [self viewControllerAtIndex:index];

    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    // We're about to go on a branch, but we're not on one at the moment
    if (!destinationBranch && forkStations && [forkStations count] > 0) {
        return nil;
    }

    NSUInteger index = [(LPCStationViewController *)viewController index];

    index++;

    if (index == self.stations.count) {
        return nil;
    }
    
    UIViewController *newViewController = [self viewControllerAtIndex:index];

    return newViewController;

}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    id stationAtIndexOnline = [self.stations objectAtIndex:index];
    
    if (destinationBranch) { // We're on a branch
        
    }
    
    if ([stationAtIndexOnline isKindOfClass:[NSString class]]) { // it's just a station on the current line
        NSLog(@"At %d it's a station.", index);
        
        LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
        childViewController.index = index;
        LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSDictionary *station = [appDelegate.stations objectForKey:[self.stations objectAtIndex:index]];
        
        NSNumber *lat = [NSNumber numberWithDouble:[[station valueForKey:@"lat"] doubleValue]];
        NSNumber *lng = [NSNumber numberWithDouble:[[station valueForKey:@"lng"] doubleValue]];
        NSArray *stationLatLng = @[lat, lng];
        
        childViewController.stationName = [station valueForKey:@"name"];
        childViewController.lineColour = self.lineColour;
        
        if (index == 0) {
            childViewController.firstStop = YES;
        } else if (index == self.stations.count - 1) {
            childViewController.lastStop = NO;
        }
        
        NSDictionary *venue = [stationResult objectForKey:[station valueForKey:@"code"]];
        
        if (venue) {
            childViewController.pubName = [venue valueForKeyPath:@"venue.name"];
            childViewController.distance = [venue valueForKeyPath:@"venue.location.distance"];
            NSNumber *pubLatitude = [venue valueForKeyPath:@"venue.location.lat"];
            NSNumber *pubLongitude = [venue valueForKeyPath:@"venue.location.lng"];
            childViewController.pubLocation = @[pubLatitude, pubLongitude];
            childViewController.stationLocation = stationLatLng;
        }
        
        //    childViewController.lineImagePng = image;
        return childViewController;
    } else { // It's a fork!
        LPCForkViewController *childViewController = [[LPCForkViewController alloc] initWithNibName:@"LPCForkViewController" bundle:nil];
        childViewController.index = index;
        childViewController.delegate = self;
        forkStations = (NSDictionary *)stationAtIndexOnline;
        NSArray *forkDestinations = [forkStations allKeys];
        
        childViewController.topForkStationCode = [forkDestinations objectAtIndex:0];
        childViewController.bottomForkStationCode = [forkDestinations objectAtIndex:1];
        
        childViewController.lineColour = self.lineColour;
        
        NSLog(@"At %d it's a fork.", index);
        return childViewController;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

# pragma mark - LPCForkViewControllerDelegate methods

- (void)didLeaveBranch {
    destinationBranch = nil;
    forkStations = nil;
}

- (void)didChooseBranchForDestination:(NSString *)destinationStationCode {
    NSLog(@"Going to branch with destination %@", destinationStationCode);
    destinationBranch = destinationStationCode;
    
    LPCLineViewController *crawlViewController = [[LPCLineViewController alloc] initWithLineCode:0];
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com"]];
    
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    crawlViewController.stations = [forkStations objectForKey:destinationStationCode];
    crawlViewController.lineColour = self.lineColour;
    
    for (NSString *s in crawlViewController.stations) {
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
                [crawlViewController addVenue:venue forStationCode:[station valueForKey:@"code"]];
            } else {
                NSLog(@"What?!");
            }
            
            if ([s isEqualToString:crawlViewController.stations[0]]) {
                // We push once we have the first stop's venue
                [self presentViewController:crawlViewController animated:YES completion:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            // Details!
        }];
    }
}

@end
