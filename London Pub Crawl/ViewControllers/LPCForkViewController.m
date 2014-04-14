#import "LPCForkViewController.h"

#import "LPCAppDelegate.h"
#import "LPCThemeManager.h"
#import "LPCFork.h"
#import <UIColor-HexString/UIColor+HexString.h>

@implementation LPCForkViewController

LPCStation *topForkDestinationStation;
LPCStation *bottomForkDestinationStation;
NSString *topForkDirection;
NSString *bottomForkDirection;
LPCFork *currentFork;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFork:(LPCFork *)fork {
    self = [[LPCForkViewController alloc] initWithNibName:@"LPCForkViewController" bundle:nil];
    
    if (fork.destinationStations[0] && [fork.destinationStations[0] isKindOfClass:[LPCStation class]]) {
        topForkDestinationStation = (LPCStation *)fork.destinationStations[0];
    } else {
        topForkDirection = fork.destinationStations[0];
    }
    
    if ([fork.destinationStations count] > 1 && [fork.destinationStations[1] isKindOfClass:[LPCStation class]]) {
        bottomForkDestinationStation = (LPCStation *)fork.destinationStations[1];
    } else {
        bottomForkDirection = fork.destinationStations[1];
    }
    
    currentFork = fork;
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.forkDelegate forkDidAppear];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // What are the titles of things?
    if (topForkDestinationStation) {
        [self.topRightForkSelectorLabel setText:[NSString stringWithFormat:@"%@", topForkDestinationStation.name]];
        [self.topLeftForkSelectorLabel setText:[NSString stringWithFormat:@"%@", topForkDestinationStation.name]];
    } else {
        if ([topForkDirection isEqualToString:@"top"]) {
            [self.topRightForkSelectorLabel setText:self.directionBackward];
            [self.topLeftForkSelectorLabel setText:self.directionBackward];
        } else {
            [self.topRightForkSelectorLabel setText:self.directionForward];
            [self.topLeftForkSelectorLabel setText:self.directionForward];
        }
    }
    
    if (bottomForkDestinationStation) {
            [self.bottomRightForkSelectorLabel setText:[NSString stringWithFormat:@"%@", bottomForkDestinationStation.name]];
            [self.bottomLeftForkSelectorLabel setText:[NSString stringWithFormat:@"%@", bottomForkDestinationStation.name]];
    } else {
        if ([bottomForkDirection isEqualToString:@"top"]) {
            [self.bottomRightForkSelectorLabel setText:self.directionForward];
            [self.bottomLeftForkSelectorLabel setText:self.directionForward];
        } else {
            [self.bottomRightForkSelectorLabel setText:self.directionBackward];
            [self.bottomLeftForkSelectorLabel setText:self.directionBackward];
        }
    }
    
    [self.toolbar setBackgroundColor:[UIColor colorWithHexString:@"#221e1f"]];
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.wayOutButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithHexString:@"#ffd204"], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    UIImage *forkImage = [LPCThemeManager tubeLineForkWithColor:self.lineColour];
    
    [self.forkImageView setImage:forkImage];
    
    if (currentFork.direction == Left) {
        self.forkImageView.transform = CGAffineTransformMakeRotation(M_PI); // flip the image view
    }
    
    if (currentFork.direction == Right) {
        [self.branchNameLeftLabel setText:self.directionBackward];
        [self.branchNameLeftLabel setTextColor:self.lineColour];
        [self.mainLineStationLeftLabel setText:self.directionBackward];
        
        [self.mainLineStationRightLabel removeFromSuperview];
        [self.branchNameRightLabel removeFromSuperview];
        
        self.topLeftForkSelector.hidden = YES;
        self.topLeftForkSelector.userInteractionEnabled = NO;
        self.bottomLeftForkSelector.hidden = YES;
        self.bottomLeftForkSelector.userInteractionEnabled = NO;
    } else {
        [self.branchNameRightLabel setText:self.directionForward];
        [self.branchNameRightLabel setTextColor:self.lineColour];
        [self.mainLineStationRightLabel setText:self.directionForward];
        
        [self.mainLineStationLeftLabel removeFromSuperview];
        [self.branchNameLeftLabel removeFromSuperview];
        
        self.topRightForkSelector.hidden = YES;
        self.topRightForkSelector.userInteractionEnabled = NO;
        self.bottomRightForkSelector.hidden = YES;
        self.bottomRightForkSelector.userInteractionEnabled = NO;
    }
    
    [self assignActionsToButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeLine:(id)sender {
    if (self.lineDelegate) {
        [self.lineDelegate didClickChangeLine];
    }
}

# pragma mark - Private Methods

- (void)assignActionsToButtons {
    UIGestureRecognizer *topRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectTopFork)];
    if (currentFork.direction == Right) {
        [self.topRightForkSelector addGestureRecognizer:topRecogniser];
    } else {
        [self.topLeftForkSelector addGestureRecognizer:topRecogniser];
    }
    
    UIGestureRecognizer *bottomRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectBottomFork)];
    if (currentFork.direction == Right) {
        [self.bottomRightForkSelector addGestureRecognizer:bottomRecogniser];
    } else {
        [self.bottomLeftForkSelector addGestureRecognizer:bottomRecogniser];
    }
}

- (void)didSelectTopFork {
    NSLog(@"Going to the top fork toward %@.", topForkDestinationStation.name);
    if (currentFork.direction == Left) {
        [self.forkDelegate didChooseStationLeft:[currentFork firstStationForDestination:0]];
    } else {
        [self.forkDelegate didChooseStationRight:[currentFork firstStationForDestination:0]];
    }
}

- (void)didSelectBottomFork {
    NSLog(@"Going to the bottom fork toward %@.", bottomForkDestinationStation.name);
    if (currentFork.direction == Left) {
        [self.forkDelegate didChooseStationLeft:[currentFork firstStationForDestination:1]];
    } else {
        [self.forkDelegate didChooseStationRight:[currentFork firstStationForDestination:1]];
    }
}

#pragma mark - Getters
- (LPCLinePosition *)linePosition {
    return currentFork.linePosition;
}

@end
