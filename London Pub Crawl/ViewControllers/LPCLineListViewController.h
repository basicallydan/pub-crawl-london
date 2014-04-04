#import <UIKit/UIKit.h>

#import "LPCStationViewController.h"

@interface LPCLineListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LPCStationViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
