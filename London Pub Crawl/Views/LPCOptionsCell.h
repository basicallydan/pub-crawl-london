#import <UIKit/UIKit.h>

@protocol LPCOptionsCellDelegate <NSObject>

- (void)happilyButtonClicked;
- (void)aboutButtonClicked;
- (void)helpButtonClicked;

@end

@interface LPCOptionsCell : UITableViewCell

@property (weak, nonatomic) id<LPCOptionsCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *optionsImageView;
- (IBAction)happilyButtonClicked:(id)sender;
- (IBAction)aboutButtonClicked:(id)sender;
- (IBAction)helpButtonClicked:(id)sender;

@end
