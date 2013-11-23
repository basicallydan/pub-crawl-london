#import "LPCStationViewController.h"

#import <UIColor-HexString/UIColor+HexString.h>
#import <UIImageView+WebCache.h>
#import "NSArray+AsCLLocationCoordinate2D.h"
#import "LPCMapAnnotation.h"

@interface LPCStationViewController () <MKMapViewDelegate>

@end

@implementation LPCStationViewController

NSString *const kLPCMapBoxURLTemplate = @"http://api.tiles.mapbox.com/v3/basicallydan.map-ql3x67r6/pin-m-beer(%.04f,%.04f),pin-m-rail(%.04f,%.04f)/%.04f,%.04f,%d/%.0fx%.0f%@.png";
NSString *const kLPCGoogleMapsURLTemplate = @"http://maps.googleapis.com/maps/api/staticmap?markers=color:grey%%7C%.04f,%.04f&center=%.04f,%.04f&zoom=%d&size=%.0fx%.0f%@&sensor=false%@&visual_refresh=true";
BOOL isMapLoaded = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.mapView = [[MBXMapView alloc] initWithFrame:self.mapViewportView.frame mapID:@"basicallydan.map-ql3x67r6"];
//    self.mapView.delegate = self;
    
    NSString *mapBoxImageRetina = nil;
    NSString *googleMapsImageRetina = nil;
    
    if ([UIScreen mainScreen].scale == 2.0) {
        mapBoxImageRetina = @"@2x";
        googleMapsImageRetina = @"&scale=2";
    }
    
    int distanceInteger = [self.distance integerValue];
    int zoomLevel = 13;
    
    if (distanceInteger < 50) {
        zoomLevel = 17;
    } else if (distanceInteger < 200) {
        zoomLevel = 16;
    } else if (distanceInteger < 400) {
        zoomLevel = 15;
    } else if (distanceInteger < 500) {
        zoomLevel = 14;
    } else if (distanceInteger > 700) {
        zoomLevel = 12;
    }
    
//    NSString *mapImageUrl = [NSString stringWithFormat:kLPCMapBoxURLTemplate, [self.pubLocation[1] floatValue], [self.pubLocation[0] floatValue], [self.stationLocation[1] floatValue], [self.stationLocation[0] floatValue], [self.stationLocation[1] floatValue], [self.stationLocation[0] floatValue], zoomLevel, self.mapViewportView.frame.size.width, self.mapViewportView.frame.size.height, imageRetina];
    NSString *mapImageUrl = [NSString stringWithFormat:kLPCGoogleMapsURLTemplate, [self.pubLocation[0] floatValue], [self.pubLocation[1] floatValue], [self.stationLocation[0] floatValue], [self.stationLocation[1] floatValue], zoomLevel, self.mapViewportView.frame.size.width, self.mapViewportView.frame.size.height, googleMapsImageRetina, @""];
    // TODO: When deploying, put in the API key
    NSLog(@"Map URL is %@", mapImageUrl);
    
    UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:self.mapViewportView.frame];
    [mapImageView setImageWithURL:[NSURL URLWithString:mapImageUrl] placeholderImage:[UIImage imageNamed:@"map-placeholder.png"]];
//    mapImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mapImageUrl]]];
    
    [UIView animateWithDuration:0.4
         animations:^{
             self.loadingView.alpha = 0;
         }
         completion:nil];
    
    [self.headerView setBackgroundColor:[UIColor colorWithHexString:@"#EEFFFFFF"]];
    [self.footerView setBackgroundColor:[UIColor colorWithHexString:@"#EEFFFFFF"]];
    
//    [self.view insertSubview:self.mapView atIndex:0];
    [self.view insertSubview:mapImageView atIndex:0];
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
            [self.destinationRightLabel setText:[NSString stringWithFormat:@"%@ branch", self.branchName]];
            [self.destinationRightLabel setTextColor:self.lineColour];
            [self.destinationLeftLabel removeFromSuperview];
        } else {
            [self.destinationLeftLabel setText:[NSString stringWithFormat:@"%@ branch", self.branchName]];
            [self.destinationLeftLabel setTextColor:self.lineColour];
            [self.destinationRightLabel removeFromSuperview];
        }
    } else if (self.directionBackward && self.directionForward) {
        [self.destinationLeftLabel setText:self.directionBackward];
        [self.destinationLeftLabel setTextColor:self.lineColour];
        
        [self.destinationRightLabel setText:self.directionForward];
        [self.destinationRightLabel setTextColor:self.lineColour];
    }
    
    [self.toolbar setBackgroundColor:[UIColor colorWithHexString:@"#221e1f"]];
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.wayOutButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithHexString:@"#ffd204"], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
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
    
//    if (self.pubLocation && self.stationLocation) {
//        MKCoordinateRegion reg = [self regionFromLocations:@[self.stationLocation, self.pubLocation]];
//        [self.mapView setCenterCoordinate:[self.stationLocation asCLLocationCoordinate2D] zoomLevel:12 animated:NO];
//        [self.mapView setRegion:reg];
//        [self.mapView regionThatFits:reg];
//    }
//    
//    LPCMapAnnotation *pubAnnotation = [[LPCMapAnnotation alloc] initWithCoordinate:[self.pubLocation asCLLocationCoordinate2D] andType:0];
//    pubAnnotation.coordinate = [self.pubLocation asCLLocationCoordinate2D];
//    [self.mapView addAnnotation:pubAnnotation];
    [UIView animateWithDuration:0.4
         animations:^{
             self.loadingView.alpha = 0;
         }
         completion:nil];
}

# pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return nil;
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
