#import <UIKit/UIKit.h>

#import "LPCLineViewController.h"

@interface LPCLineListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LPCLineViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
