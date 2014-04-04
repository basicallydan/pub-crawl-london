#import <UIKit/UIKit.h>

@protocol LPCOptionsCellDelegate <NSObject>

- (void)happilyButtonClicked;
- (void)helpButtonClicked;

@end

@interface LPCOptionsCell : UITableViewCell

@property (weak, nonatomic) id<LPCOptionsCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *optionsImageView;
- (IBAction)happilyButtonClicked:(id)sender;
- (IBAction)helpButtonClicked:(id)sender;

@end
