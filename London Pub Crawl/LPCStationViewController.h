#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LPCStationViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *stationName;
@property (strong, nonatomic) NSString *lineCode;
@property (strong, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) UIImage *lineImagePng;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (strong, nonatomic) NSString *pubName;
@property (weak, nonatomic) IBOutlet UILabel *pubNameLabel;
@property (strong, nonatomic) NSString *distance;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet MKMapView *pubMapView;
@property (strong, nonatomic) NSArray *pubLocation;
@property (strong, nonatomic) NSArray *stationLocation;

@end
