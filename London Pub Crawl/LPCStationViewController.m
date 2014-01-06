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

@interface LPCStationViewController () <UIActionSheetDelegate>

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

- (id)initWithStation:(LPCStation *)station {
    self = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
    
    self.station = station;
    
    [self loadVenues];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stationNameLabel.text = self.station.name;
    
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
    
    [self refreshVenues];
}

# pragma mark - Private Methods

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
        venue.formattedAddress = coreDataVenue.formattedAddress;
        venue.priceMessage = coreDataVenue.priceMessage;
        venue.priceTier = coreDataVenue.priceTier;
        [v addObject:venue];
    }
    venues = v;
}

- (void)refreshVenues {
    if ([venues count] > 0) {
        currentVenue = [venues objectAtIndex:currentVenueIndex];
        [self populateVenueDetailsWithVenue:currentVenue];
        [self loadMapImage];
    }
    
    if ([venues count] == 1) {
        self.nextPubButton.hidden = YES;
    } else if ([venues count] > 1) {
        self.nextPubButton.hidden = NO;
    }
}

- (void)updateVenuesAndRefresh:(NSArray *)coreDataVenues {
    [self updateVenues:coreDataVenues];
    [self refreshVenues];
}

- (void)populateVenueDetailsWithVenue:(LPCVenue *)venue {
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
    
    currentVenue = venue;
    
    if (!venue.tips || ![venue.tips count] || [venue.tips count] == 0) {
        self.noTipsLabel.hidden = NO;
        self.tipView.hidden = YES;
        if ([venues count] > 1) {
            self.noTipsNextPubButton.hidden = NO;
        } else {
            self.noTipsNextPubButton.hidden = YES;
        }
    } else {
        self.noTipsLabel.hidden = YES;
        self.tipView.hidden = NO;
        self.noTipsNextPubButton.hidden = YES;
    }
}

- (void)loadMapImage {
    NSString *mapBoxImageRetina = nil;
    NSString *googleMapsImageRetina = nil;
    
    if ([UIScreen mainScreen].scale == 2.0) {
        mapBoxImageRetina = @"@2x";
        googleMapsImageRetina = @"&scale=2";
    }
    
    long distanceInteger = [currentVenue.distance integerValue];

//  TODO: Put something in to deal with custom zoom levels
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
    NSString *mapImageUrl = [NSString stringWithFormat:kLPCMapBoxURLTemplate, lineColourHexCode, [currentVenue.latLng[1] floatValue], [currentVenue.latLng[0] floatValue], lineColourHexCode, [self.station.coordinate[1] floatValue], [self.station.coordinate[0] floatValue], [self.station.coordinate[1] floatValue], [self.station.coordinate[0] floatValue], zoomLevel, self.mapImageView.frame.size.width, self.mapImageView.frame.size.height, mapBoxImageRetina];
    
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
}

# pragma mark - UIActionSheetDelegate methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //coordinates for the place we want to display
    CLLocationCoordinate2D venueLocation = CLLocationCoordinate2DMake([currentVenue.latLng[0] floatValue], [currentVenue.latLng[1] floatValue]);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
