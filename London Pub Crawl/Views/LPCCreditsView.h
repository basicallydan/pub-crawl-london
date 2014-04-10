#import <UIKit/UIKit.h>

@protocol LPCCreditsViewDelegate <NSObject>

- (void)didSubmitEmailAddress:(NSString *)emailAddress;

@end

@interface LPCCreditsView : UIView

@property (weak, nonatomic) id<LPCCreditsViewDelegate> delegate;
- (id)initFromTableView:(UITableView *)tableView andCells:(NSArray *)lineCells;

@end
