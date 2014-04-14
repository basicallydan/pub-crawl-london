#import <UIKit/UIKit.h>

#import "LPCLinePosition.h"
#import "LPCFork.h"
#import "LPCLineViewController.h"

@protocol LPCForkViewControllerDelegate <NSObject>

- (int)numForkViewsThisLineSession;
- (void)forkDidAppear;
- (void)didLeaveBranch;
- (void)didChooseStationLeft:(LPCStation *)firstStationTowardDestination;
- (void)didChooseStationRight:(LPCStation *)firstStationTowardDestination;

@end

@interface LPCForkViewController : UIViewController

@property (weak, nonatomic) id<LPCForkViewControllerDelegate> forkDelegate;
@property (weak, nonatomic) id<LPCLineViewControllerDelegate> lineDelegate;

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *lineCode;
@property (strong, nonatomic) UIColor *lineColour;
@property (readonly, nonatomic) LPCLinePosition *linePosition;
@property (strong, nonatomic) NSString *directionForward;
@property (strong, nonatomic) NSString *directionBackward;

@property (weak, nonatomic) IBOutlet UIImageView *forkImageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *wayOutButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIView *topRightForkSelector;
@property (weak, nonatomic) IBOutlet UILabel *topRightForkSelectorLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomRightForkSelector;
@property (weak, nonatomic) IBOutlet UILabel *bottomRightForkSelectorLabel;

@property (weak, nonatomic) IBOutlet UIView *topLeftForkSelector;
@property (weak, nonatomic) IBOutlet UILabel *topLeftForkSelectorLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLeftForkSelector;
@property (weak, nonatomic) IBOutlet UILabel *bottomLeftForkSelectorLabel;

@property (weak, nonatomic) IBOutlet UILabel *branchNameLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *branchNameRightLabel;

@property (weak, nonatomic) IBOutlet UILabel *mainLineStationLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainLineStationRightLabel;

- (id)initWithFork:(LPCFork *)fork;
- (IBAction)changeLine:(id)sender;

@end
