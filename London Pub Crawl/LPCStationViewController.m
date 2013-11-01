#import "LPCStationViewController.h"

#import <UIColor-HexString/UIColor+HexString.h>
#import "NSArray+AsCLLocationCoordinate2D.h"
#import "LPCAppDelegate.h"

@interface LPCStationViewController () <MKMapViewDelegate>

@end

@implementation LPCStationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView = [[MBXMapView alloc] initWithFrame:self.view.frame mapID:@"basicallydan.map-ql3x67r6"];
//    [self.mapView ]
    self.mapView.delegate = self;
    [self.headerView setBackgroundColor:[UIColor colorWithHexString:@"#BBFFFFFF"]];
    [self.footerView setBackgroundColor:[UIColor colorWithHexString:@"#BBFFFFFF"]];
    [self.view insertSubview:self.mapView atIndex:0];
    self.stationNameLabel.text = self.stationName;
    self.pubNameLabel.text = self.pubName;
    self.distanceLabel.text = [NSString stringWithFormat:@"%@m from the station", self.distance];
    if (self.firstStop) {
        self.rightLineView.backgroundColor = self.lineColour;
    } else if (self.lastStop) {
        self.leftLineView.backgroundColor = self.lineColour;
    } else {
        self.fullWidthLineView.backgroundColor = self.lineColour;
    }
    [self zoomToRelevantLocation];
}

# pragma mark - Private Methods

- (void)zoomToRelevantLocation {
    if (self.pubLocation && self.stationLocation) {
        MKCoordinateRegion reg = [self regionFromLocations:@[self.stationLocation, self.pubLocation]];
//        [self.mapView setCenterCoordinate:[self.stationLocation asCLLocationCoordinate2D] zoomLevel:12 animated:NO];
        [self.mapView setRegion:reg];
        [self.mapView regionThatFits:reg];
    }
}

# pragma mark - MKMapViewDelegate methods

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    [self zoomToRelevantLocation];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    [self zoomToRelevantLocation];
    [UIView animateWithDuration:0.4
     animations:^{
         //                 self.loadingView.center = midCenter;
         self.loadingView.alpha = 0;
     }
     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKCoordinateRegion)regionFromLocations:(NSArray *)locations {
    NSArray *first = [locations objectAtIndex:0];
    CLLocationCoordinate2D upper = [first asCLLocationCoordinate2D];
    CLLocationCoordinate2D lower = [first asCLLocationCoordinate2D];
//    CLLocationCoordinate2D a = CLLocationCoordinate2DMake(51.0, -0.1);
    
    for (int i = 0; i < locations.count; i++) {
        NSArray *locationObj = [locations objectAtIndex:i];
        CLLocationCoordinate2D location = [locationObj asCLLocationCoordinate2D];
        if(location.latitude > upper.latitude) upper.latitude = location.latitude;
        if(location.latitude < lower.latitude) lower.latitude = location.latitude;
        if(location.longitude > upper.longitude) upper.longitude = location.longitude;
        if(location.longitude < lower.longitude) lower.longitude = location.longitude;
    }
    
    // FIND REGION
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = upper.latitude - lower.latitude;
    locationSpan.longitudeDelta = upper.longitude - lower.longitude;
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    return region;
}

- (IBAction)changeLine:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
