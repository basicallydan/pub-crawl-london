#import <UIKit/UIKit.h>

@protocol LPCOptionsCellDelegate <NSObject>

- (void)happilyButtonClicked;
- (void)aboutButtonClicked;

@end

@interface LPCOptionsCell : UITableViewCell

@property (weak, nonatomic) id<LPCOptionsCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *optionsImageView;
- (IBAction)happilyButtonClicked:(id)sender;
- (IBAction)aboutButtonClicked:(id)sender;

@end
