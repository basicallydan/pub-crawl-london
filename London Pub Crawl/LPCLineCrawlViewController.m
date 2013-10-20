#import "LPCLineCrawlViewController.h"

#import "LPCStationViewController.h"
#import "LPCAppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@implementation LPCLineCrawlViewController

AFHTTPSessionManager *sessionManager;
NSMutableDictionary *stationResult;

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
        sessionManager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com"]];
        
        LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.stations = [[appDelegate.lines objectAtIndex:lineIndex] valueForKey:@"stations"];
        stationResult = [[NSMutableDictionary alloc] init];

        for (NSString *s in self.stations) {
            NSDictionary *station = [appDelegate.stations objectForKey:s];
            NSNumber *lat = [NSNumber numberWithDouble:[[station valueForKey:@"lat"] doubleValue]];
            NSNumber *lng = [NSNumber numberWithDouble:[[station valueForKey:@"lng"] doubleValue]];
            NSArray *latLng = @[lat, lng];
//            NSArray *latLng = [appDelegate.stations objectForKey:station];
            NSString *searchURI = [NSString stringWithFormat:@"/v2/venues/explore?ll=%@,%@&client_id=SNE54YCOV1IR5JP14ZOLOZU0Z43FQWLTTYDE0YDKYO03XMMH&client_secret=44AI50PSJMHMXVBO1STMAUV0IZYQQEFZCSO1YXXKVTVM32OM&v=20131015&limit=1&intent=match&radius=3000&section=drinks&sortByDistance=1", latLng[0], latLng[1]];
            [sessionManager GET:searchURI parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *result = (NSDictionary *)responseObject;
                NSArray *venues = [result valueForKeyPath:@"response.groups.items"];
                if (venues.count > 0 && ((NSArray *)venues[0]).count > 0) {
                    NSDictionary *venue = venues[0][0];
                    [stationResult setValue:venue forKey:[station valueForKey:@"code"]];
                } else {
                    NSLog(@"What?!");
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                // Details!
            }];
        }

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];

    LPCStationViewController *initialViewController = [self viewControllerAtIndex:0];

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

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    NSUInteger index = [(LPCStationViewController *)viewController index];


    index++;

    if (index == self.stations.count - 1) {
        return nil;
    }
    
    LPCStationViewController *newViewController = [self viewControllerAtIndex:index];

    return newViewController;

}

- (LPCStationViewController *)viewControllerAtIndex:(NSUInteger)index {
    LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
    childViewController.index = index;
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *station = [appDelegate.stations objectForKey:[self.stations objectAtIndex:index]];
    
    NSNumber *lat = [NSNumber numberWithDouble:[[station valueForKey:@"lat"] doubleValue]];
    NSNumber *lng = [NSNumber numberWithDouble:[[station valueForKey:@"lng"] doubleValue]];
    NSArray *stationLatLng = @[lat, lng];
    
    childViewController.stationName = [station valueForKey:@"name"];
    UIImage *image = [UIImage imageNamed: @"Jubilee-Line"];
    if (index == 0) {
        image = [UIImage imageNamed:@"Jubilee-Line-Start"];
    } else if (index == self.stations.count - 1) {
        image = [UIImage imageNamed:@"Jubilee-Line-End"];
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
    
    childViewController.lineImagePng = image;
    return childViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

@end
