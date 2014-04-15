#import <UIKit/UIKit.h>

#import "LPCLine.h"

@protocol LPCLineViewControllerDelegate <NSObject>

- (void)didClickChangeLine;

@end

@interface LPCLineViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) id<LPCLineViewControllerDelegate> delegate;

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) UIColor *lineColour;
@property (strong, nonatomic) NSArray *stations;
@property (strong, nonatomic) LPCStation *branchStation;

@property (strong, nonatomic) NSString *topOfLineDirection;
@property (strong, nonatomic) NSString *bottomOfLineDirection;

- (id)initWithLine:(LPCLine *)line atStation:(LPCStation *)stationNestoriaCode withDelegate:(id<LPCLineViewControllerDelegate>)delegate completion:(void (^)())completion;
- (void)addVenues:(NSArray *)venues forStationCode:(NSString *)stationCode;

@end
