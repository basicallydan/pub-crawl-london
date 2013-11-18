#import "LPCLineViewController.h"

#import "LPCAppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCForkViewController.h"
#import "LPCLinePosition.h"
#import "LPCStationViewController.h"

@interface LPCLineViewController () <LPCForkViewControllerDelegate>

@end

@implementation LPCLineViewController

AFHTTPSessionManager *sessionManager;
NSMutableDictionary *stationVenues;
NSString *destinationBranch;
NSDictionary *forkStations;
LPCForkViewController *forkController;
int startingStationIndex;
LPCLinePosition *currentStationPointer;
LPCLine *currentLine;
LPCStation *currentStation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStationIndex:(int)stationIndex {
    self = [super init];
    if (self) {
        if (!stationIndex) {
            startingStationIndex = 0;
        } else {
            startingStationIndex = stationIndex;
        }
        stationVenues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithLine:(LPCLine *)line atStation:(LPCStation *)station {
    self = [super init];
    currentStation = station;
    currentLine = line;
    
    self.stations = line.allStations;
    
    stationVenues = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)addVenue:(NSDictionary *)venue forStationCode:(NSString *)stationCode {
    [stationVenues setValue:venue forKey:stationCode];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    if (startingStationIndex > [self.stations count]) {
        // If the requested index is bigger than the count, we'll start at the start. Why am I being protective here?
        // TODO: Remove this code when happy to do so.
        startingStationIndex = 0;
    }

//    UIViewController *initialViewController = [self viewControllerAtIndex:startingStationIndex];
//    UIViewController *initialViewController = [self viewControllerAtPositionPointer:currentStationPointer];
    UIViewController *initialViewController = [self viewControllerForStation:currentStation];

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
    // TODO: Before!
    return nil;
    
    NSUInteger index = [(LPCStationViewController *)viewController index];

    if (index == 0) {
        return nil;
    }

    index--;
    
    UIViewController *newViewController = [self viewControllerAtIndex:index];

    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    // TODO: After!
    LPCStationViewController *currentViewController = (LPCStationViewController *)viewController;
    
    LPCStation *nextStation = [currentLine stationAfterPosition:currentViewController.station.linePosition];
    
    UIViewController *nextViewController = [self viewControllerForStation:nextStation];
    
    return nextViewController;
    
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


- (UIViewController *)viewControllerForStation:(LPCStation *)st {
    LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
//        childViewController.index = index;
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    childViewController.station = st;
    
    childViewController.stationName = st.name;
    childViewController.lineColour = currentLine.lineColour;
    
//    if (index == 0) {
//        if (!self.parentForkController) {
//            childViewController.firstStop = YES;
//        }
//    } else if (index == self.stations.count - 1) {
//        childViewController.lastStop = NO;
//    }
    
    if (self.branchStation) {
        NSString *branchStationLongCode = [self.branchStation valueForKey:@"nestoria_code"];
        childViewController.branchName = [self.branchStation valueForKey:@"name"];
        
        int currentStationPosition = [self.stations indexOfObject:st.nestoriaCode];
        int branchStationPosition = [self.stations indexOfObject:branchStationLongCode];
        
        if(currentStationPosition < branchStationPosition) {
            // The current station before the "branch station"
            childViewController.branchStationIsAhead = YES;
        } else {
            childViewController.branchStationIsAhead = NO;
        }
    } else {
        childViewController.directionBackward = currentLine.topOfLineDirection;
        childViewController.directionForward = currentLine.bottomOfLineDirection;
    }
    
    NSDictionary *venue = [stationVenues objectForKey:st.code];
    
    if (venue) {
        childViewController.pubName = [venue valueForKeyPath:@"name"];
        childViewController.distance = [venue valueForKeyPath:@"location.distance"];
        NSNumber *pubLatitude = [venue valueForKeyPath:@"location.lat"];
        NSNumber *pubLongitude = [venue valueForKeyPath:@"location.lng"];
        childViewController.tips = [venue valueForKey:@"tips"];
        childViewController.pubLocation = @[pubLatitude, pubLongitude];
        childViewController.stationLocation = st.coordinate;
    }
    
    childViewController.topLevelDelegate = self.delegate;
    
    //    childViewController.lineImagePng = image;
    return childViewController;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    id stationAtIndexOnline = [self.stations objectAtIndex:index];
    
    if (self.parentForkController) { // We're on a branch
        
    }
    
    if ([stationAtIndexOnline isKindOfClass:[NSString class]]) { // it's just a station on the current line
        NSLog(@"At %d it's a station.", index);
        
        LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
        childViewController.index = index;
        LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *stationLongCode = [self.stations objectAtIndex:index];
        
        NSDictionary *station = [appDelegate.stations objectForKey:stationLongCode];
        
        NSNumber *lat = [NSNumber numberWithDouble:[[station valueForKey:@"lat"] doubleValue]];
        NSNumber *lng = [NSNumber numberWithDouble:[[station valueForKey:@"lng"] doubleValue]];
        NSArray *stationLatLng = @[lat, lng];
        
        childViewController.stationName = [station valueForKey:@"name"];
        childViewController.lineColour = self.lineColour;
        
        if (index == 0) {
            if (!self.parentForkController) {
                childViewController.firstStop = YES;
            }
        } else if (index == self.stations.count - 1) {
            childViewController.lastStop = NO;
        }
        
        if (self.branchStation) {
            NSString *branchStationLongCode = [self.branchStation valueForKey:@"nestoria_code"];
            childViewController.branchName = [self.branchStation valueForKey:@"name"];
            
            int currentStationPosition = [self.stations indexOfObject:stationLongCode];
            int branchStationPosition = [self.stations indexOfObject:branchStationLongCode];
            
            if(currentStationPosition < branchStationPosition) {
                // The current station before the "branch station"
                childViewController.branchStationIsAhead = YES;
            } else {
                childViewController.branchStationIsAhead = NO;
            }
        } else {
            childViewController.directionBackward = self.topOfLineDirection;
            childViewController.directionForward = self.bottomOfLineDirection;
        }
        
        NSDictionary *venue = [stationVenues objectForKey:[station valueForKey:@"code"]];
        
        if (venue) {
            childViewController.pubName = [venue valueForKeyPath:@"name"];
            childViewController.distance = [venue valueForKeyPath:@"location.distance"];
            NSNumber *pubLatitude = [venue valueForKeyPath:@"location.lat"];
            NSNumber *pubLongitude = [venue valueForKeyPath:@"location.lng"];
            childViewController.tips = [venue valueForKey:@"tips"];
            childViewController.pubLocation = @[pubLatitude, pubLongitude];
            childViewController.stationLocation = stationLatLng;
        }
        
        childViewController.topLevelDelegate = self.delegate;
        
        //    childViewController.lineImagePng = image;
        return childViewController;
    } else { // It's a fork!
        LPCForkViewController *childViewController = [[LPCForkViewController alloc] initWithNibName:@"LPCForkViewController" bundle:nil];
        childViewController.index = index;
        childViewController.forkDelegate = self;
        forkStations = (NSDictionary *)stationAtIndexOnline;
        NSArray *forkDestinations = [forkStations allKeys];
        
        childViewController.topForkStationCode = [forkDestinations objectAtIndex:0];
        childViewController.bottomForkStationCode = [forkDestinations objectAtIndex:1];
        
        childViewController.lineColour = self.lineColour;
        
        childViewController.topLevelDelegate = self.delegate;
        
        forkController = childViewController;
        
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
    forkController = nil;
}

- (void)didChooseBranchForDestination:(NSString *)destinationStationCode {
    NSLog(@"Going to branch with destination %@", destinationStationCode);
    destinationBranch = destinationStationCode;
    
    LPCLineViewController *branchLineViewController = [[LPCLineViewController alloc] initWithStationIndex:0];
    
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    branchLineViewController.branchStation = [appDelegate.stations valueForKey:destinationStationCode];
    branchLineViewController.stations = [forkStations objectForKey:destinationStationCode];
    branchLineViewController.lineColour = self.lineColour;
    branchLineViewController.parentForkController = forkController;
    branchLineViewController.delegate = self.delegate;
    
    for (NSString *s in branchLineViewController.stations) {
        NSDictionary *station = [appDelegate.stations objectForKey:s];
        NSArray *venues = [appDelegate.pubs valueForKey:[station valueForKey:@"code"]];
        NSDictionary *venue = venues[0];
        [branchLineViewController addVenue:venue forStationCode:[station valueForKey:@"code"]];
    }
    
    [self presentViewController:branchLineViewController animated:YES completion:nil];
}

@end
