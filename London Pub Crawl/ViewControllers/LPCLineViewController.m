#import "LPCLineViewController.h"

#import "LPCAppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <IAPHelper/IAPShare.h>
#import "LPCFork.h"
#import "LPCForkViewController.h"
#import "LPCLinePosition.h"
#import "LPCStationViewController.h"
#import "LPCVenue.h"
#import "LPCVenueRetrievalHandler.h"
#import <Analytics/Analytics.h>
#import <CGLMail/CGLMailHelper.h>

@interface LPCLineViewController () <LPCForkViewControllerDelegate, LPCStationViewControllerDelegate, UIAlertViewDelegate>

@end

@implementation LPCLineViewController {
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
    LPCStationViewController *previousStationViewController;
    LPCStationViewController *nextStationViewController;
    UIViewController *initialViewController;
    int maxStationViewsThisLineSession;
    int numStationViewsThisLineSession;
    int numForkViewsThisLineSession;
    NSMutableArray *stationsVisitedInSession;
}

- (id)initWithLine:(LPCLine *)line atStation:(LPCStation *)station withDelegate:(id<LPCLineViewControllerDelegate>)delegate completion:(void (^)())completion {
    self = [super init];
    currentStation = station;
    currentLine = line;
    self.delegate = delegate;
    
    stationsVisitedInSession = [[NSMutableArray alloc] init];
    
    if ([[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:line.iapProductIdentifier] == NO &&
        [[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:allTheLinesKey] == NO) {
        maxStationViewsThisLineSession = 2;
    } else {
        maxStationViewsThisLineSession = 0;
    }
    
    self.stations = line.allStations;
    
    // Initial capacity is number of stations
    stationVenues = [[NSMutableDictionary alloc] initWithCapacity:[line.allStations count]];
    
    venueRetrievalHandler = [LPCVenueRetrievalHandler sharedHandler];
    
    initialViewController = [self viewControllerForStation:station];
    
    numStationViewsThisLineSession = 0;
    numForkViewsThisLineSession = 0;
    
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

//    UIViewController *initialViewController = [self viewControllerForStation:currentStation];

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
            previousViewController.lineDelegate = self.delegate;
            
            return previousViewController;
        }
        
        LPCStation *previousStation = [currentLine stationBeforePosition:currentViewController.station.linePosition];
        
        if (!previousStation) {
            return nil;
        }
        
        previousStationViewController = (LPCStationViewController *)[self viewControllerForStation:previousStation];
        
        return previousStationViewController;
    } else {
        LPCForkViewController *currentViewController = (LPCForkViewController *)viewController;
        
        LPCStation *previousStation = [currentLine stationBeforePosition:currentViewController.linePosition];
        
        if (!previousStation) {
            return nil;
        }
        
        previousStationViewController = [self viewControllerForStation:previousStation];
        
        return previousStationViewController;
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
            nextViewController.lineDelegate = self.delegate;
            
            return nextViewController;
        }
        
        LPCStation *nextStation = [currentLine stationAfterPosition:currentViewController.station.linePosition];
        
        if (!nextStation) {
            return nil;
        }
        
        nextStationViewController = (LPCStationViewController *)[self viewControllerForStation:nextStation];
        
        return nextStationViewController;
    } else {
        LPCForkViewController *currentViewController = (LPCForkViewController *)viewController;
        
        LPCStation *nextStation = [currentLine stationAfterPosition:currentViewController.linePosition];
        
        if (!nextStation) {
            return nil;
        }
        
        nextStationViewController = [self viewControllerForStation:nextStation];
        
        return nextStationViewController;
    }
}

- (LPCStationViewController *)viewControllerForStation:(LPCStation *)st {
    BOOL lineAndAllLinesUnowned = [[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:currentLine.iapProductIdentifier] == NO && [[IAPShare sharedHelper].iap isPurchasedProductsIdentifier:allTheLinesKey] == NO;
    BOOL stationAlreadyVisited = [stationsVisitedInSession containsObject:st.nestoriaCode];
    BOOL stationWillBeBlurred = maxStationViewsThisLineSession > 0 && numStationViewsThisLineSession > maxStationViewsThisLineSession && !stationAlreadyVisited && lineAndAllLinesUnowned;
    
    if (!stationAlreadyVisited && !stationWillBeBlurred) {
        [stationsVisitedInSession addObject:st.nestoriaCode];
    }
    
    LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithStation:st andLine:currentLine andBlurred:stationWillBeBlurred];
    
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
    
    childViewController.stationDelegate = self;
    childViewController.lineDelegate = self.delegate;
    
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

- (void)incrementNumberOfStations {
    numStationViewsThisLineSession += 1;
    if (numStationViewsThisLineSession == [self.stations count]) {
        [[SEGAnalytics sharedAnalytics] track:@"Visited all stations" properties:@{ @"Line": currentLine.name }];
    }
}

# pragma mark - LPCStationViewControllerDelegate methods
- (int)numStationViewsThisLineSession {
    return numStationViewsThisLineSession;
}

- (void)didUnlockLine {
    [nextStationViewController hideBuyView];
    [previousStationViewController hideBuyView];
}

- (void)stationDidAppear {
    [self incrementNumberOfStations];
}

# pragma mark - LPCForkViewControllerDelegate methods
- (int)numForkViewsThisLineSession {
    return numForkViewsThisLineSession;
}

- (void)forkDidAppear {
    numForkViewsThisLineSession += 1;
}

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
