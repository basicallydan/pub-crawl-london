#import "LPCForkViewController.h"

#import "LPCAppDelegate.h"
#import "LPCStationViewController.h"
#import "LPCThemeManager.h"
#import "LPCFork.h"
#import <UIColor-HexString/UIColor+HexString.h>

@implementation LPCForkViewController

LPCStation *topForkDestinationStation;
LPCStation *bottomForkDestinationStation;
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
    
    topForkDestinationStation = (LPCStation *)fork.destinationStations[0];
    bottomForkDestinationStation = (LPCStation *)fork.destinationStations[1];
    
    currentFork = fork;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // What are the titles of things?
    [self.topRightForkButton setTitle:[NSString stringWithFormat:@"Toward %@", topForkDestinationStation.name] forState:UIControlStateNormal];
    [self.bottomRightForkButton setTitle:[NSString stringWithFormat:@"Toward %@", bottomForkDestinationStation.name] forState:UIControlStateNormal];
    
    [self.toolbar setBackgroundColor:[UIColor colorWithHexString:@"#221e1f"]];
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.wayOutButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithHexString:@"#ffd204"], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [self.forkImageView setImage:[LPCThemeManager tubeLineForkWithColor:self.lineColour]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)topRightForkAction:(id)sender {
    NSLog(@"Going to the bottom-right fork toward %@.", topForkDestinationStation.name);
    [self.forkDelegate didChooseStation:[currentFork firstStationForDestination:0]];
}

- (IBAction)bottomRightFormAction:(id)sender {
    NSLog(@"Going to the top-right fork toward %@.", bottomForkDestinationStation.name);
    [self.forkDelegate didChooseStation:[currentFork firstStationForDestination:1]];
}

- (IBAction)changeLine:(id)sender {
    if (self.topLevelDelegate) {
        [self.topLevelDelegate didClickChangeLine];
    }
}
@end
