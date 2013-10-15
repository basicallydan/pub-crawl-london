#import <UIKit/UIKit.h>

@interface LPCStationViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *stationName;
@property (strong, nonatomic) NSString *lineCode;
@property (strong, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) UIImage *lineImagePng;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;

@end
