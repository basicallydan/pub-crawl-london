#import "LPCStationViewController.h"

#import <UIColor-HexString/UIColor+HexString.h>
#import "NSArray+AsCLLocationCoordinate2D.h"
#import "LPCMapAnnotation.h"

@interface LPCStationViewController () <MKMapViewDelegate>

@end

@implementation LPCStationViewController

BOOL isMapLoaded = NO;

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
    self.mapView = [[MBXMapView alloc] initWithFrame:self.mapViewportView.frame mapID:@"basicallydan.map-ql3x67r6"];
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
    
    if ([self.tips count] == 0) {
        self.tipAuthorLabel.hidden = YES;
        self.tipLabel.hidden = YES;
    } else {
        self.tipAuthorLabel.hidden = NO;
        self.tipLabel.hidden = NO;
        
        self.tipAuthorLabel.text = [self.tips[0] valueForKey:@"user"];
        self.tipLabel.text = [self.tips[0] valueForKey:@"text"];
    }
    
    if (self.branchName) {
        if (self.branchStationIsAhead) {
            [self.branchNameRightLabel setText:[NSString stringWithFormat:@"%@ branch", self.branchName]];
            [self.branchNameRightLabel setTextColor:self.lineColour];
            [self.branchNameLeftLabel removeFromSuperview];
        } else {
            [self.branchNameLeftLabel setText:[NSString stringWithFormat:@"%@ branch", self.branchName]];
            [self.branchNameLeftLabel setTextColor:self.lineColour];
            [self.branchNameRightLabel removeFromSuperview];
        }
    } else {
        [self.branchNameLeftLabel removeFromSuperview];
        [self.branchNameRightLabel removeFromSuperview];
    }
    
    [self.changeLineButton setImage:[UIImage imageNamed:@"tube-line-button-normal"] forState:UIControlStateNormal];
    
    [self.changeLineButton setImage:[UIImage imageNamed:@"tube-line-button-pressed"] forState:UIControlStateHighlighted];
    
    isMapLoaded = NO;
}

- (void)viewDidLayoutSubviews {
    [self.tipLabel sizeToFit];
}

# pragma mark - Private Methods

- (void)zoomToRelevantLocation {
    if (isMapLoaded) {
        return;
    }
    isMapLoaded = YES;
    
    if (self.pubLocation && self.stationLocation) {
        MKCoordinateRegion reg = [self regionFromLocations:@[self.stationLocation, self.pubLocation]];
        [self.mapView setCenterCoordinate:[self.stationLocation asCLLocationCoordinate2D] zoomLevel:12 animated:NO];
        [self.mapView setRegion:reg];
        [self.mapView regionThatFits:reg];
    }
    
    LPCMapAnnotation *pubAnnotation = [[LPCMapAnnotation alloc] initWithCoordinate:[self.pubLocation asCLLocationCoordinate2D] andType:0];
    pubAnnotation.coordinate = [self.pubLocation asCLLocationCoordinate2D];
    [self.mapView addAnnotation:pubAnnotation];
    // Do we need the station annotation?
//    LPCMapAnnotation *stationAnnotation = [[LPCMapAnnotation alloc] initWithCoordinate:[self.pubLocation asCLLocationCoordinate2D] andType:1];
//    stationAnnotation.coordinate = [self.stationLocation asCLLocationCoordinate2D];
//    [self.mapView addAnnotation:stationAnnotation];
    [UIView animateWithDuration:0.4
         animations:^{
             self.loadingView.alpha = 0;
         }
         completion:nil];
}

# pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *identifier = @"Location";
    LPCMapAnnotation *mapAnnotation = (LPCMapAnnotation *)annotation;
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    if (mapAnnotation.type == 0) { // Pub
        annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pub-icon.png"]];
    } else { // Station
        annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"station-icon.png"]];
    }
    annotationView.enabled = YES;
    annotationView.canShowCallout = NO;
    
    return annotationView;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    [self zoomToRelevantLocation];
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
    locationSpan.latitudeDelta = (upper.latitude - lower.latitude) * 1.9f;
    locationSpan.longitudeDelta = (upper.longitude - lower.longitude) * 1.9f;
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    
    return region;
}

- (IBAction)changeLine:(id)sender {
    // Dismiss this controller first
    
    if (self.topLevelDelegate) {
        [self.topLevelDelegate didClickChangeLine];
    }
}

@end
