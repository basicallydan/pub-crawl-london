#import "LPCStationViewController.h"

#import <UIColor-HexString/UIColor+HexString.h>
#import "NSArray+AsCLLocationCoordinate2D.h"

@interface LPCStationViewController ()

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
    [self.headerView setBackgroundColor:[UIColor colorWithHexString:@"#BBFFFFFF"]];
    [self.footerView setBackgroundColor:[UIColor colorWithHexString:@"#BBFFFFFF"]];
    [self.view insertSubview:self.mapView atIndex:0];
    self.stationNameLabel.text = self.stationName;
    self.pubNameLabel.text = self.pubName;
    self.distanceLabel.text = [NSString stringWithFormat:@"%@m from the station", self.distance];
    [self.lineImage setImage:self.lineImagePng];
    
    if (self.pubLocation && self.stationLocation) {
        MKCoordinateRegion reg = [self regionFromLocations:@[self.stationLocation, self.pubLocation]];
        [self.mapView setCenterCoordinate:[self.stationLocation asCLLocationCoordinate2D] zoomLevel:12 animated:NO];
        [self.mapView setRegion:reg];
        [self.mapView regionThatFits:reg];
        
//        [self.pubMapView addAnnotations:@[self.stationLocation, self.pubLocation]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKCoordinateRegion)regionFromLocations:(NSArray *)locations {
    NSArray *first = [locations objectAtIndex:0];
    CLLocationCoordinate2D upper = CLLocationCoordinate2DMake([(NSNumber *)first[0] doubleValue], [(NSNumber *)first[1] doubleValue]);
    CLLocationCoordinate2D lower = (CLLocationCoordinate2D){.latitude = [(NSNumber *)first[0] doubleValue], .longitude = [(NSNumber *)first[1] doubleValue]};
//    CLLocationCoordinate2D a = CLLocationCoordinate2DMake(51.0, -0.1);
    
    for (int i = 0; i < locations.count; i++) {
        NSArray *locationObj = [locations objectAtIndex:i];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([(NSNumber *)locationObj[0] doubleValue], [(NSNumber *)locationObj[1] doubleValue]);
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

@end
