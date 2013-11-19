#import <UIKit/UIKit.h>

#import "LPCStationViewController.h"
#import "LPCLinePosition.h"
#import "LPCFork.h"

@protocol LPCForkViewControllerDelegate <NSObject>

- (void)didLeaveBranch;
- (void)didChooseStation:(LPCStation *)firstStationTowardDestination;

@end

@interface LPCForkViewController : UIViewController

@property (weak, nonatomic) id<LPCForkViewControllerDelegate> forkDelegate;
@property (weak, nonatomic) id<LPCStationViewControllerDelegate> topLevelDelegate;

- (id)initWithFork:(LPCFork *)fork;

@property (assign, nonatomic) NSInteger index;
//@property (strong, nonatomic) NSString *topForkStationCode;
//@property (strong, nonatomic) NSString *bottomForkStationCode;
@property (strong, nonatomic) NSString *lineCode;
@property (strong, nonatomic) UIColor *lineColour;

@property (weak, nonatomic) IBOutlet UIView *leftLineView;
@property (weak, nonatomic) IBOutlet UIView *topRightLineView;
@property (weak, nonatomic) IBOutlet UIView *bottomRightLineView;
@property (weak, nonatomic) IBOutlet UIImageView *forkImageView;
@property (weak, nonatomic) IBOutlet UIButton *topRightForkButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomRightForkButton;
- (IBAction)topRightForkAction:(id)sender;
- (IBAction)bottomRightFormAction:(id)sender;
- (IBAction)changeLine:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *wayOutButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
