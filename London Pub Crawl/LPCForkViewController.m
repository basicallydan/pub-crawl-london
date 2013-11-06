#import "LPCForkViewController.h"

#import "LPCAppDelegate.h"
#import "LPCStationViewController.h"
#import "LPCThemeManager.h"

@implementation LPCForkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *topStationDestination = [appDelegate.stations objectForKey:self.topForkStationCode];
    NSDictionary *bottomStationDestination = [appDelegate.stations objectForKey:self.bottomForkStationCode];
    
    // What are the titles of things?
    [self.topRightForkButton setTitle:[NSString stringWithFormat:@"Toward %@", [topStationDestination objectForKey:@"name"]] forState:UIControlStateNormal];
    [self.bottomRightForkButton setTitle:[NSString stringWithFormat:@"Toward %@", [bottomStationDestination objectForKey:@"name"]] forState:UIControlStateNormal];
    
    [self.changeLineButton setImage:[UIImage imageNamed:@"tube-line-button-normal"] forState:UIControlStateNormal];
    
    [self.changeLineButton setImage:[UIImage imageNamed:@"tube-line-button-pressed"] forState:UIControlStateHighlighted];
    
    [self.forkImageView setImage:[LPCThemeManager tubeLineForkWithColor:self.lineColour]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)topRightForkAction:(id)sender {
    NSLog(@"Going to the bottom-right fork toward %@.", self.topForkStationCode);
    [self.forkDelegate didChooseBranchForDestination:self.topForkStationCode];
}

- (IBAction)bottomRightFormAction:(id)sender {
    NSLog(@"Going to the top-right fork toward %@.", self.bottomForkStationCode);
    [self.forkDelegate didChooseBranchForDestination:self.bottomForkStationCode];
}

- (IBAction)changeLine:(id)sender {
    if (self.topLevelDelegate) {
        [self.topLevelDelegate didClickChangeLine];
    }
}
@end
