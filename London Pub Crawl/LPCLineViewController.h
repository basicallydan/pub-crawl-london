#import <UIKit/UIKit.h>

#import "LPCForkViewController.h"
#import "LPCStationViewController.h"
#import "LPCLine.h";

@interface LPCLineViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) id<LPCStationViewControllerDelegate> delegate;

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) UIColor *lineColour;
@property (strong, nonatomic) NSArray *stations;
@property (strong, nonatomic) LPCLineViewController *parentLineViewController;
@property (strong, nonatomic) LPCForkViewController *parentForkController;
@property (strong, nonatomic) LPCStation *branchStation;

@property (strong, nonatomic) NSString *topOfLineDirection;
@property (strong, nonatomic) NSString *bottomOfLineDirection;

- (id)initWithStationIndex:(int)stationIndex;
- (id)initWithLine:(LPCLine *)line atStation:(LPCStation *)stationNestoriaCode;
- (void)addVenue:(NSDictionary *)venue forStationCode:(NSString *)stationCode;

@end
