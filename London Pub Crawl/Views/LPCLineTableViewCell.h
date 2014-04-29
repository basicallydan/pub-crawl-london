#import <UIKit/UIKit.h>

@interface LPCLineTableViewCell : UITableViewCell

@property (nonatomic) int lineIndex;
@property (strong, nonatomic) NSString *lineName;
@property (weak, nonatomic) IBOutlet UILabel *lockedLabel;

@end
