#import "LPCLineCrawlViewController.h"

#import "LPCStationViewController.h"
#import "LPCAppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@implementation LPCLineCrawlViewController

AFHTTPSessionManager *sessionManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithLineCode:(NSString *)lineCode {
    self = [super init];
    if (self) {
        sessionManager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com"]];
        
        LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.stations = [appDelegate.stationOrdersForLines objectForKey:lineCode];

        for (NSString *station in self.stations) {
            NSArray *latLng = [appDelegate.stationCoordinates objectForKey:station];
            NSString *searchURI = [NSString stringWithFormat:@"/v2/venues/search?ll=%@,%@&client_id=SNE54YCOV1IR5JP14ZOLOZU0Z43FQWLTTYDE0YDKYO03XMMH&client_secret=44AI50PSJMHMXVBO1STMAUV0IZYQQEFZCSO1YXXKVTVM32OM&v=20131015", latLng[1], latLng[0]];
            [sessionManager GET:searchURI parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                // Check out the details
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

    return [self viewControllerAtIndex:index];

}

- (LPCStationViewController *)viewControllerAtIndex:(NSUInteger)index {
    LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
    childViewController.index = index;
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    childViewController.stationName = [appDelegate.stations objectForKey:[self.stations objectAtIndex:index]];
    UIImage *image = [UIImage imageNamed: @"Jubilee-Line"];
    if (index == 0) {
        image = [UIImage imageNamed:@"Jubilee-Line-Start"];
    } else if (index == self.stations.count - 1) {
        image = [UIImage imageNamed:@"Jubilee-Line-End"];
    }
    childViewController.lineImagePng = image;
    return childViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.stations.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

@end
