#import "LPCLineViewController.h"

#import "LPCAppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCFork.h"
#import "LPCForkViewController.h"
#import "LPCLinePosition.h"
#import "LPCStationViewController.h"
#import "LPCVenue.h"
#import "LPCVenueRetrievalHandler.h"

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
LPCVenueRetrievalHandler *venueRetrievalHandler;
UIViewController *initialViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithLine:(LPCLine *)line atStation:(LPCStation *)station completion:(void (^)())completion {
    self = [super init];
    currentStation = station;
    currentLine = line;
    
    self.stations = line.allStations;
    
    // Initial capacity is number of stations
    stationVenues = [[NSMutableDictionary alloc] initWithCapacity:[line.allStations count]];
    
    venueRetrievalHandler = [LPCVenueRetrievalHandler sharedHandler];
    
    initialViewController = [self viewControllerForStation:station];
    
    return self;
}

- (void)addVenues:(NSArray *)venues forStationCode:(NSString *)stationCode {
    [stationVenues setValue:venues forKey:stationCode];
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
    if ([viewController isKindOfClass:[LPCStationViewController class]]) {
        LPCStationViewController *currentViewController = (LPCStationViewController *)viewController;
        
        if ([currentLine isForkBeforePosition:currentViewController.station.linePosition]) {
            NSLog(@"It's a fork behind us!");
            LPCFork *fork = [currentLine forkBeforePosition:currentViewController.station.linePosition];
            LPCForkViewController *previousViewController = [[LPCForkViewController alloc] initWithFork:fork];
            
            previousViewController.lineColour = self.lineColour;
            
            previousViewController.directionBackward = currentLine.topOfLineDirection;
            previousViewController.directionForward = currentLine.bottomOfLineDirection;
            
            previousViewController.forkDelegate = self;
            previousViewController.topLevelDelegate = self.delegate;
            
            return previousViewController;
        }
        
        LPCStation *previousStation = [currentLine stationBeforePosition:currentViewController.station.linePosition];
        
        if (!previousStation) {
            return nil;
        }
        
        UIViewController *previousViewController = [self viewControllerForStation:previousStation];
        
        return previousViewController;
    } else {
        LPCForkViewController *currentViewController = (LPCForkViewController *)viewController;
        
        LPCStation *previousStation = [currentLine stationBeforePosition:currentViewController.linePosition];
        
        if (!previousStation) {
            return nil;
        }
        
        UIViewController *previousViewController = [self viewControllerForStation:previousStation];
        
        return previousViewController;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[LPCStationViewController class]]) {
        LPCStationViewController *currentViewController = (LPCStationViewController *)viewController;
        
        if ([currentLine isForkAfterPosition:currentViewController.station.linePosition]) {
            NSLog(@"It's a fork next!");
            LPCFork *fork = [currentLine forkAfterPosition:currentViewController.station.linePosition];
            LPCForkViewController *nextViewController = [[LPCForkViewController alloc] initWithFork:fork];
            
            nextViewController.lineColour = self.lineColour;
            
            nextViewController.directionBackward = currentLine.topOfLineDirection;
            nextViewController.directionForward = currentLine.bottomOfLineDirection;
            
            nextViewController.forkDelegate = self;
            nextViewController.topLevelDelegate = self.delegate;
            
            return nextViewController;
        }
        
        LPCStation *nextStation = [currentLine stationAfterPosition:currentViewController.station.linePosition];
        
        if (!nextStation) {
            return nil;
        }
        
        UIViewController *nextViewController = [self viewControllerForStation:nextStation];
        
        return nextViewController;
    } else {
        LPCForkViewController *currentViewController = (LPCForkViewController *)viewController;
        
        LPCStation *nextStation = [currentLine stationAfterPosition:currentViewController.linePosition];
        
        if (!nextStation) {
            return nil;
        }
        
        UIViewController *nextViewController = [self viewControllerForStation:nextStation];
        
        return nextViewController;
    }
}


- (UIViewController *)viewControllerForStation:(LPCStation *)st {
    LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
    childViewController.station = st;
    
    [childViewController loadVenues];
    
    childViewController.stationName = st.name;
    childViewController.lineColour = currentLine.lineColour;
    
    if (st.linePosition.branchCode) {
        LPCStation *branchStation = [currentLine stationWithCode:st.linePosition.branchCode];
        childViewController.branchName = branchStation.name;
        
        if([st.linePosition beforePosition:branchStation.linePosition]) {
            // The current station before the "branch station"
            childViewController.branchStationIsAhead = YES;
        } else {
            childViewController.branchStationIsAhead = NO;
        }
    } else {
        childViewController.directionBackward = currentLine.topOfLineDirection;
        childViewController.directionForward = currentLine.bottomOfLineDirection;
    }
    
    childViewController.stationLocation = st.coordinate;
    
    childViewController.topLevelDelegate = self.delegate;
    
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

# pragma mark - Private Methods

- (void)retrieveVenuesForStation:(LPCStation *)station completion:(void (^)(NSArray *))completion {
    NSArray *venues = [venueRetrievalHandler venuesForStation:station completion:^(NSArray *venues) {
        [self addVenues:[NSArray arrayWithArray:venues] forStationCode:station.code];
        completion(venues);
    }];
    
    if (venues) {
        [self addVenues:[NSArray arrayWithArray:venues] forStationCode:station.code];
        completion(venues);
    }
}

# pragma mark - LPCForkViewControllerDelegate methods

- (void)didLeaveBranch {
    destinationBranch = nil;
    forkStations = nil;
    forkController = nil;
}

- (void)didChooseStationRight:(LPCStation *)firstStationTowardDestination {
    UIViewController *nextViewController = [self viewControllerForStation:firstStationTowardDestination];
    [self.pageController setViewControllers:@[nextViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)didChooseStationLeft:(LPCStation *)firstStationTowardDestination {
    UIViewController *nextViewController = [self viewControllerForStation:firstStationTowardDestination];
    [self.pageController setViewControllers:@[nextViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

@end
