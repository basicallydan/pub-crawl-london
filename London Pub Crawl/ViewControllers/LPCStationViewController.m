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
#import <Reachability/Reachability.h>

@interface LPCStationViewController () <UIActionSheetDelegate>

@end

@interface LPCStationViewController (private)

-(void)reachabilityChanged:(NSNotification*)note;

@end

@implementation LPCStationViewController {
    int zoomLevel;
    NSArray *venues;
    LPCVenue *currentVenue;
    int currentVenueIndex;
    int currentTipIndex;
    LPCVenueRetrievalHandler *venueRetrievalHandler;
    UIImageView *helpImageOverlay;
    BOOL reachable;
    BOOL refreshWhenReachable;
}

NSString *const kLPCMapBoxURLTemplate = @"http://api.tiles.mapbox.com/v3/basicallydan.map-ql3x67r6/pin-m-beer+%@(%.04f,%.04f),pin-m-rail+%@(%.04f,%.04f)/%.04f,%.04f,%d/%.0fx%.0f%@.png";
NSString *const kLPCGoogleMapsURLTemplate = @"http://maps.googleapis.com/maps/api/staticmap?markers=color:grey%%7C%.04f,%.04f&center=%.04f,%.04f&zoom=%d&size=%.0fx%.0f%@&sensor=false%@&visual_refresh=true";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        venueRetrievalHandler = [LPCVenueRetrievalHandler sharedHandler];
        currentVenueIndex = 0;
        currentTipIndex = 0;
        venues = nil;
        currentVenue = nil;
        Reachability *reach = [Reachability reachabilityWithHostname:@"api.foursquare.com"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        reachable = NO;
        refreshWhenReachable = NO;
        
//        reach.reachableBlock = ^(Reachability * reachability)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                reachable = YES;
//            });
//        };
//        
//        reach.unreachableBlock = ^(Reachability * reachability)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                reachable = NO;
//            });
//        };
        
        [reach startNotifier];
    }
    
    return self;
}

- (void)reachabilityChanged:(NSNotification*)note {
    Reachability *reach = [note object];
    
    if([reach isReachable])
    {
        NSLog(@"Reachable");
        reachable = YES;
        if (refreshWhenReachable) {
            [self loadVenues];
        }
    }
    else
    {
        NSLog(@"Not reachable");
        reachable = NO;
    }
}

- (id)initWithStation:(LPCStation *)station {
    self = [[LPCStationViewController alloc] initWithNibName:@"LPCStationViewController" bundle:nil];
    
    self.station = station;
    
    [self loadVenues];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self showLoading];
    [self showVenues];
}

# pragma mark - Private Methods

/*!
 Configures the static visible elements of the view such as station
 name and lines
 */
- (void)configureView {
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
    
    UIFont *fontAwesomeFont = [UIFont fontWithName:kFontAwesomeFamilyName size:20.0];
    
    [self.showHelpButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#ffd204"], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17.0], NSFontAttributeName, fontAwesomeFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.showHelpButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#ffd204"], NSForegroundColorAttributeName, fontAwesomeFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.showHelpButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconQuestionSign]];
}

- (void)showLoading {
    NSMutableArray *animationImagesArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 23; i++) {
        [animationImagesArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Frame %d.png", i]]];
    }
    for (int i = 23; i >= 1; i--) {
        [animationImagesArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Frame %d.png", i]]];
    }
    self.loadingImageView.animationImages = [NSArray arrayWithArray:animationImagesArray];
    self.loadingImageView.animationDuration = 1.5f;
    self.loadingImageView.animationRepeatCount = 0;
    [self.loadingImageView startAnimating];
}

- (void)showOffline {
    [self.loadingImageView stopAnimating];
    self.loadingImageView.animationImages = nil;
    self.loadingImageView.animationDuration = 0;
    self.loadingImageView.animationRepeatCount = 0;
    
    [self.loadingImageView setImage:[UIImage imageNamed:@"Offline.png"]];
    
    [self.pubNameLabel setText:@"You're offline!"];
    
    [self.offlineMessageLabel setHidden:NO];
    
    refreshWhenReachable = YES;
}

- (void)loadVenues {
    NSLog(@"[%@]: Loading venues", self.station.name);
    NSArray *storedVenues = [venueRetrievalHandler venuesForStation:self.station completion:^(NSArray *remoteVenues) {
        refreshWhenReachable = NO;
        if (!venues || [venues count] < 1) {
            [self updateAndShowInstanceVenues:remoteVenues];
        }
    }];
    
    if (storedVenues) {
        NSLog(@"[%@]: Displaying cached venues", self.station.name);
        [self updateAndShowInstanceVenues:storedVenues];
    } else {
        if (!reachable) {
            // None cached and not online? Better report it!
            [self showOffline];
        }
    }
}

- (void)updateInstanceVenues:(NSArray *)coreDataVenues {
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

- (void)showVenues {
    if ([venues count] > 0) {
        NSLog(@"[%@]: Showing the first of %d venues", self.station.name, [venues count]);
        [self displayVenueAtIndex:currentVenueIndex];
        [self loadMapImage];
    } else {
        [self showOffline];
    }
    
    if ([venues count] == 1) {
        self.nextPubButton.hidden = YES;
    } else if ([venues count] > 1) {
        self.nextPubButton.hidden = NO;
    }
}

- (void)updateAndShowInstanceVenues:(NSArray *)coreDataVenues {
    [self updateInstanceVenues:coreDataVenues];
    [self showVenues];
}

- (void)displayVenue:(LPCVenue *)venue {
    NSLog(@"[%@]: Populating details for %@", self.station.name, venue.name);
    currentTipIndex = 0;
    
    // We need to set the current venue for the tip method to use below
    currentVenue = venue;
    
    // Populate text of labels
    [self.pubNameLabel setTextColor:[UIColor blackColor]];
    self.pubNameLabel.text = venue.name;
    self.distanceLabel.text = [NSString stringWithFormat:@"%@m from the station", venue.distance];
    self.addressLabel.text = venue.formattedAddress;
    
    // Hide the loading image
    [self.loadingImageView stopAnimating];
    self.loadingImageView.hidden = YES;
    
    // Show the labels in their populated form
    self.pubNameLabel.hidden = NO;
    self.distanceLabel.hidden = NO;
    self.addressLabel.hidden = NO;
    
    if (!venue.tips || ![venue.tips count] || [venue.tips count] == 0) {
        self.noTipsLabel.hidden = NO;
        self.nextTipButton.hidden = YES;
        self.tipView.hidden = YES;
        if ([venues count] > 1) {
            self.noTipsNextPubButton.hidden = NO;
        } else {
            self.noTipsNextPubButton.hidden = YES;
        }
    } else { // So, there are some tips
        [self populateTipViewWithCurrentTip];
    }
    
    [self.offlineMessageLabel setHidden:YES];
    
    NSLog(@"[%@]: Finished populating for %@", self.station.name, venue.name);
}

- (void)displayVenueAtIndex:(NSInteger)index {
    [self displayVenue:[venues objectAtIndex:index]];
}

- (void)populateTipViewWithCurrentTip {
    self.noTipsLabel.hidden = YES;
    self.nextTipButton.hidden = NO;
    self.tipView.hidden = NO;
    self.noTipsNextPubButton.hidden = YES;
    
    if ([[currentVenue tips] count] > 1) {
        self.nextTipButton.hidden = NO;
    } else {
        self.nextTipButton.hidden = YES;
    }
    
    NSDictionary *currentTip = currentVenue.tips[currentTipIndex];
    
    self.tipAuthorLabel.text = [currentTip valueForKeyPath:@"user.firstName"];
    self.tipLabel.text = [currentTip valueForKey:@"text"];
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
    
//    NSLog(@"Map URL is %@", mapImageUrl);
    
    [self.mapImageView setImageWithURL:[NSURL URLWithString:mapImageUrl] placeholderImage:[UIImage imageNamed:@"map-placeholder.png"]];
    [self.mapImageView setImage:[UIImage imageNamed:@"map-placeholder.png"]];
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
- (void)respondToLongPressOfMapImage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self openActionSheet:nil];
        return;
    }
}

-(void)openActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Open in Maps" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:@"Apple Maps"];
    
    [actionSheet addButtonWithTitle:@"Google Maps"];
    
    if ([CMMapLauncher isMapAppInstalled:CMMapAppCitymapper]) {
        [actionSheet addButtonWithTitle:@"Citymapper"];
    }
    
//    [actionSheet addButtonWithTitle:@"Never mind"];
    
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
    
    [self displayVenueAtIndex:currentVenueIndex];
    [self loadMapImage];
}

- (IBAction)changeTip:(id)sender {
    currentTipIndex++;
    
    if (currentTipIndex >= [currentVenue.tips count]) {
        currentTipIndex = 0;
    }
    
    [self populateTipViewWithCurrentTip];
}

- (IBAction)showHelpOverlay:(id)sender {
    if (isiPhone5) {
        helpImageOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station-help-iphone-5.png"]];
    } else {
        helpImageOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station-help-iphone-4.png"]];
    }
    helpImageOverlay.alpha = 0.0f;
    [self.view addSubview:helpImageOverlay];
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.4];
    helpImageOverlay.alpha = 1.0f;
    [UIView commitAnimations];
    
    helpImageOverlay.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *imageViewGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapOfHelpImage:)];
    imageViewGestureRecogniser.cancelsTouchesInView = NO;
    
    [helpImageOverlay addGestureRecognizer:imageViewGestureRecogniser];
}

- (void)respondToTapOfHelpImage:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (helpImageOverlay) {
            [UIView animateWithDuration:0.4 animations:^{
                helpImageOverlay.alpha = 1.0; helpImageOverlay.alpha = 0.0;
            } completion:^(BOOL success) {
                if (success) {
                    [helpImageOverlay removeFromSuperview];
                }
            }];
        }
    }
}


@end
