#import <UIKit/UIKit.h>

#import "LPCStation.h"
#import "LPCBuyLineView.h"
#import "LPCLineViewController.h"

@protocol LPCStationViewControllerDelegate <NSObject>

- (int)numStationViewsThisLineSession;
- (void)didUnlockLine;
- (void)stationDidAppear;

@end

@interface LPCStationViewController : UIViewController

extern NSString *const kLPCMapBoxURLTemplate;
extern NSString *const kLPCGoogleMapsURLTemplate;

@property (weak, nonatomic) id<LPCStationViewControllerDelegate> stationDelegate;
@property (weak, nonatomic) id<LPCLineViewControllerDelegate> lineDelegate;

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *lineCode;
@property (strong, nonatomic) UIColor *lineColour;
@property (assign, nonatomic) BOOL firstStop;
@property (assign, nonatomic) BOOL lastStop;
@property (strong, nonatomic) NSString *branchName;
@property (assign, nonatomic) BOOL branchStationIsAhead;
@property (strong, nonatomic) NSString *directionForward;
@property (strong, nonatomic) NSString *directionBackward;
@property (strong, nonatomic) LPCStation *station;

- (id)initWithStation:(LPCStation *)station andLine:(LPCLine *)line andBlurred:(BOOL) blurred;

@property (weak, nonatomic) IBOutlet LPCBuyLineView *blurView;
@property (strong, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *leftLineView;
@property (weak, nonatomic) IBOutlet UIView *rightLineView;
@property (weak, nonatomic) IBOutlet UIView *fullWidthLineView;
@property (weak, nonatomic) IBOutlet UIView *circleRectView;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *noTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *noTipsNextPubButton;
@property (weak, nonatomic) IBOutlet UIScrollView *tipView;
@property (weak, nonatomic) IBOutlet UILabel *tipAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextTipButton;
@property (weak, nonatomic) IBOutlet UILabel *destinationRightLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextPubButton;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UILabel *offlineMessageLabel;

- (IBAction)changeLine:(id)sender;
- (IBAction)changePub:(id)sender;
- (IBAction)changeTip:(id)sender;
- (IBAction)showHelpOverlay:(id)sender;
- (void)hideBuyView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *wayOutButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showHelpButton;

@end
