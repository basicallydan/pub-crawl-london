#import <UIKit/UIKit.h>

@protocol LPCCreditsViewControllerDelegate <NSObject>

- (void)didPressBackButton;

@end

@interface LPCCreditsViewController : UIViewController

@property (weak, nonatomic) id<LPCCreditsViewControllerDelegate> delegate;

- (id)initWithCells:(NSArray *)lineCells andOffset:(float)offset;
- (IBAction)backButtonPressed:(id)sender;

@end
