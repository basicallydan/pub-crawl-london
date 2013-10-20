#import <UIKit/UIKit.h>

@interface LPCLineCrawlViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSArray *stations;

- (id)initWithLineCode:(int)lineIndex;

@end
