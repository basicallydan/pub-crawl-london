#import "LPCLineViewController.h"

#import "LPCAppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "LPCFork.h"
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
            
            previousViewController.forkDelegate = self;
            previousViewController.topLevelDelegate = self.delegate;
            
            return previousViewController;
        }
        
        LPCStation *previousStation = [currentLine stationBeforePosition:currentViewController.station.linePosition];
        
        UIViewController *previousViewController = [self viewControllerForStation:previousStation];
        
        return previousViewController;
    } else {
        LPCForkViewController *currentViewController = (LPCForkViewController *)viewController;
        
        if ([currentLine isForkBeforePosition:currentViewController.linePosition]) {
            NSLog(@"It's a fork before!");
            LPCFork *fork = [currentLine forkBeforePosition:currentViewController.linePosition];
            LPCForkViewController *previousViewController = [[LPCForkViewController alloc] initWithFork:fork];
            
            previousViewController.lineColour = self.lineColour;
            
            previousViewController.forkDelegate = self;
            previousViewController.topLevelDelegate = self.delegate;
            
            return previousViewController;
        }
        
        LPCStation *previousStation = [currentLine stationBeforePosition:currentViewController.linePosition];
        
        UIViewController *previousViewController = [self viewControllerForStation:previousStation];
        
        return previousViewController;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    LPCStationViewController *currentViewController = (LPCStationViewController *)viewController;
    
    if ([currentViewController isKindOfClass:[LPCForkViewController class]] ) {
        return nil;
    }
    
    if ([currentLine isForkAfterPosition:currentViewController.station.linePosition]) {
        NSLog(@"It's a fork next!");
        LPCFork *fork = [currentLine forkAfterPosition:currentViewController.station.linePosition];
        LPCForkViewController *nextViewController = [[LPCForkViewController alloc] initWithFork:fork];
        
        nextViewController.lineColour = self.lineColour;
        
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
}


- (UIViewController *)viewControllerForStation:(LPCStation *)st {
    LPCStationViewController *childViewController = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
    childViewController.station = st;
    
    childViewController.stationName = st.name;
    childViewController.lineColour = currentLine.lineColour;
    
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
