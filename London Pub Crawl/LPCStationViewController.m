#import "LPCStationViewController.h"

#import <UIColor-HexString/UIColor+HexString.h>
#import <UIImageView+WebCache.h>
#import "NSArray+AsCLLocationCoordinate2D.h"
#import "LPCMapAnnotation.h"
#import "Venue.h"
#import "LPCVenue.h"
#import <CMMapLauncher/CMMapLauncher.h>
#import "NSString+FontAwesome.h"
#import "UIColor+HexStringFromColor.h"
#import "LPCVenueRetrievalHandler.h"

@interface LPCStationViewController () <MKMapViewDelegate, UIActionSheetDelegate>

@end

@implementation LPCStationViewController

NSString *const kLPCMapBoxURLTemplate = @"http://api.tiles.mapbox.com/v3/basicallydan.map-ql3x67r6/pin-m-beer+%@(%.04f,%.04f),pin-m-rail+%@(%.04f,%.04f)/%.04f,%.04f,%d/%.0fx%.0f%@.png";
NSString *const kLPCGoogleMapsURLTemplate = @"http://maps.googleapis.com/maps/api/staticmap?markers=color:grey%%7C%.04f,%.04f&center=%.04f,%.04f&zoom=%d&size=%.0fx%.0f%@&sensor=false%@&visual_refresh=true";
BOOL isMapLoaded = NO;
int zoomLevel;
NSArray *venues;
LPCVenue *currentVenue;
int currentVenueIndex = 0;
LPCVenueRetrievalHandler *venueRetrievalHandler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        venueRetrievalHandler = [LPCVenueRetrievalHandler sharedHandler];
        currentVenueIndex = 0;
        venues = nil;
        currentVenue = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([venues count] > 0) {
        currentVenue = [venues objectAtIndex:currentVenueIndex];
        [self populateVenueDetailsWithVenue:currentVenue];
        [self loadMapImage];
    }
    
    self.stationNameLabel.text = self.stationName;
    
    if (self.station.firstStation) {
        self.rightLineView.backgroundColor = self.lineColour;
        [self.destinationLeftLabel removeFromSuperview];
    } else if (self.station.terminatingStation) {
        self.leftLineView.backgroundColor = self.lineColour;
        [self.destinationRightLabel removeFromSuperview];
    } else {
        self.fullWidthLineView.backgroundColor = self.lineColour;
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

- (void)loadVenues {
    NSArray *storedVenues = [venueRetrievalHandler venuesForStation:self.station completion:^(NSArray *remoteVenues) {
        if (!venues || [venues count] < 1) {
            [self updateVenuesAndRefresh:remoteVenues];
        }
    }];
    
    if (storedVenues) {
        [self updateVenuesAndRefresh:storedVenues];
    }
}

- (void)updateVenues:(NSArray *)coreDataVenues {
    NSMutableArray *v = [[NSMutableArray alloc] initWithCapacity:[coreDataVenues count]];
    for (Venue *coreDataVenue in coreDataVenues) {
        LPCVenue *venue = [[LPCVenue alloc] init];
        venue.name = coreDataVenue.name;
        venue.distance = coreDataVenue.distance;
        venue.latLng = [coreDataVenue arrayOfCoordinates];
        venue.tips = [coreDataVenue arrayOfTips];
        venue.address = coreDataVenue.formattedAddress;
        venue.priceMessage = coreDataVenue.priceMessage;
        venue.priceTier = coreDataVenue.priceTier;
        [v addObject:venue];
    }
    venues = v;
}

- (void)updateVenuesAndRefresh:(NSArray *)coreDataVenues {
    [self updateVenues:coreDataVenues];
    currentVenue = [venues objectAtIndex:currentVenueIndex];
    [self populateVenueDetailsWithVenue:currentVenue];
    [self loadMapImage];
}

# pragma mark - Private Methods

- (void)populateVenueDetailsWithVenue:(LPCVenue *)venue {
    self.nextPubButton.hidden = NO;
    
    self.pubNameLabel.text = venue.name;
    self.distanceLabel.text = [NSString stringWithFormat:@"%@m from the station", venue.distance];
    
    if ([venue.tips count] == 0) {
        self.tipAuthorLabel.hidden = YES;
        self.tipLabel.hidden = YES;
    } else {
        self.tipAuthorLabel.hidden = NO;
        self.tipLabel.hidden = NO;
        
        self.tipAuthorLabel.text = [venue.tips[0] valueForKeyPath:@"user.firstName"];
        self.tipLabel.text = [venue.tips[0] valueForKey:@"text"];
    }
    
    self.addressLabel.text = venue.formattedAddress;
    
    self.pubLocation = venue.latLng;
    
    currentVenue = venue;
}

- (void)loadMapImage {
    NSString *mapBoxImageRetina = nil;
    NSString *googleMapsImageRetina = nil;
    
    if ([UIScreen mainScreen].scale == 2.0) {
        mapBoxImageRetina = @"@2x";
        googleMapsImageRetina = @"&scale=2";
    }
    
    long distanceInteger = [currentVenue.distance integerValue];
    
//    if (currentVenue.mapZoomLevel != nil) {
//        zoomLevel = [currentVenue.mapZoomLevel intValue];
//    } else {
        zoomLevel = 13;
        
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
//    }
    
    NSString *lineColourHexCode = [self.lineColour hexStringValueWithHash:NO];
    NSString *mapImageUrl = [NSString stringWithFormat:kLPCMapBoxURLTemplate, lineColourHexCode, [self.pubLocation[1] floatValue], [self.pubLocation[0] floatValue], lineColourHexCode, [self.stationLocation[1] floatValue], [self.stationLocation[0] floatValue], [self.stationLocation[1] floatValue], [self.stationLocation[0] floatValue], zoomLevel, self.mapImageView.frame.size.width, self.mapImageView.frame.size.height, mapBoxImageRetina];
    
    NSLog(@"Map URL is %@", mapImageUrl);
    
    [self.mapImageView setImageWithURL:[NSURL URLWithString:mapImageUrl] placeholderImage:[UIImage imageNamed:@"map-placeholder.png"]];
    UILongPressGestureRecognizer *mapImageViewGestureRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToLongPressOfMapImage:)];
    self.mapImageView.userInteractionEnabled = YES;
    [self.mapImageView addGestureRecognizer:mapImageViewGestureRecogniser];
    
    [self.headerView setBackgroundColor:[UIColor colorWithHexString:@"#EEFFFFFF"]];
    [self.footerView setBackgroundColor:[UIColor colorWithHexString:@"#EEFFFFFF"]];
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
}

- (void)respondToLongPressOfMapImage:(UILongPressGestureRecognizer *)recognizer {
//    NSLog(@"Long pressed Image");
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self openActionSheet:nil];
        return;
    }
}

-(void)openActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Open in Maps" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:@"Apple Maps"];
    
    [actionSheet addButtonWithTitle:@"Google Maps"];
    
    if ([CMMapLauncher isMapAppInstalled:CMMapAppCitymapper]) {
        [actionSheet addButtonWithTitle:@"Citymapper"];
    }
    
    [actionSheet addButtonWithTitle:@"Never mind"];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
//    [actionSheet showInView:self.view];
}

# pragma mark - UIActionSheetDelegate methods


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //coordinates for the place we want to display
    CLLocationCoordinate2D venueLocation = CLLocationCoordinate2DMake([self.pubLocation[0] floatValue], [self.pubLocation[1] floatValue]);
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Apple Maps"]) {
        [CMMapLauncher launchMapApp:CMMapAppAppleMaps forDirectionsTo:[CMMapPoint mapPointWithName:self.pubNameLabel.text coordinate:venueLocation]];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Google Maps"]) {
        if ([CMMapLauncher isMapAppInstalled:CMMapAppGoogleMaps]) {
            [CMMapLauncher launchMapApp:CMMapAppGoogleMaps forDirectionsTo:[CMMapPoint mapPointWithName:self.pubNameLabel.text coordinate:venueLocation]];
        } else {
            // Open up web Google Maps instead
            NSString *stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@@%1.6f,%1.6f&z=%d", currentVenue.name, venueLocation.latitude, venueLocation.longitude, zoomLevel];
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
        }
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Citymapper"]) {
        [CMMapLauncher launchMapApp:CMMapAppCitymapper forDirectionsTo:[CMMapPoint mapPointWithName:self.pubNameLabel.text coordinate:venueLocation]];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Never mind"]) {
        [actionSheet dismissWithClickedButtonIndex:[actionSheet numberOfButtons] - 1 animated:YES];
    }
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

- (IBAction)changePub:(id)sender {
    currentVenueIndex++;
    
    if (currentVenueIndex >= [venues count]) {
        currentVenueIndex = 0;
    }
    currentVenue = [venues objectAtIndex:currentVenueIndex];
    
    [self populateVenueDetailsWithVenue:currentVenue];
    [self loadMapImage];
}

@end
