#import <UIKit/UIKit.h>

#import "LPCForkViewController.h"
#import "LPCStationViewController.h"

@interface LPCLineViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) id<LPCStationViewControllerDelegate> delegate;

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) UIColor *lineColour;
@property (strong, nonatomic) NSArray *stations;
@property (strong, nonatomic) LPCLineViewController *parentLineViewController;
@property (strong, nonatomic) LPCForkViewController *parentForkController;

- (id)initWithLineCode:(int)lineIndex;
- (void)addVenue:(NSDictionary *)venue forStationCode:(NSString *)stationCode;

@end
