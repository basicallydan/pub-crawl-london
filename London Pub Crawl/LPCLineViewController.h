#import <UIKit/UIKit.h>

@interface LPCLineViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) UIColor *lineColour;
@property (strong, nonatomic) NSArray *stations;

- (id)initWithLineCode:(int)lineIndex;
- (void)addVenue:(NSDictionary *)venue forStationCode:(NSString *)stationCode;

@end
