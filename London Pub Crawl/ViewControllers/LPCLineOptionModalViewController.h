#import <UIKit/UIKit.h>
#import "LPCLine.h"
#import "LPCStation.h"

@protocol LPCLineOptionModalViewControllerDelegate <NSObject>

- (void)didSelectStartingStation:(LPCStation *)station forLine:(LPCLine *)line;

@end

@interface LPCLineOptionModalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *startingStationsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredStationArray;
@property (weak, nonatomic) IBOutlet UIView *buyView;

@property (strong, nonatomic) id<LPCLineOptionModalViewControllerDelegate> delegate;

- (id)initWithLine:(LPCLine *)line;
- (IBAction)cancel:(id)sender;

@end
