#import <UIKit/UIKit.h>

@protocol LPCCreditsViewDelegate <NSObject>

- (void)didClickEmail:(NSString *)emailAddress;
- (void)didSubmitEmailAddress:(NSString *)emailAddress;
- (void)didCloseCreditsView;

@end

@interface LPCCreditsView : UIView

@property (weak, nonatomic) id<LPCCreditsViewDelegate> delegate;
- (id)initFromTableView:(UITableView *)tableView andCells:(NSArray *)lineCells;

@end
