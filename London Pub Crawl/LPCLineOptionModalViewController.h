#import <UIKit/UIKit.h>

@protocol LPCLineOptionModalViewControllerDelegate <NSObject>

- (void)didSelectStartingStation:(NSString *)station;

@end

@interface LPCLineOptionModalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *startingStationsTableView;

@property (strong, nonatomic) id<LPCLineOptionModalViewControllerDelegate> delegate;

- (id)initWithStartingStations:(NSArray *)stations;

@end
