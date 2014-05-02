#import <UIKit/UIKit.h>

@interface LPCCreditsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *emailMessageLabel;
- (id)initWithCells:(NSArray *)lineCells andOffset:(float)offset;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)foursquareLogoPressed:(id)sender;
- (IBAction)mapboxLogoPressed:(id)sender;
- (IBAction)tflLogoPressed:(id)sender;
- (IBAction)happilyLinkPressed:(id)sender;
- (IBAction)happilyEmailPressed:(id)sender;

@end
