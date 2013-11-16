#import <UIKit/UIKit.h>
#import "LPCLine.h"

@protocol LPCLineOptionModalViewControllerDelegate <NSObject>

- (void)didSelectStartingStation:(NSString *)station;

@end

@interface LPCLineOptionModalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *startingStationsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredStationArray;

@property (strong, nonatomic) id<LPCLineOptionModalViewControllerDelegate> delegate;

- (id)initWithLine:(LPCLine *)line;
- (IBAction)cancel:(id)sender;

@end
