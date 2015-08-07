#import "LPCStationViewController.h"

#import "LPCMapAnnotation.h"
#import "LPCVenue.h"
#import "LPCVenueRetrievalHandler.h"
#import "NSArray+AsCLLocationCoordinate2D.h"
#import "NSString+FontAwesome.h"
#import "UIColor+HexStringFromColor.h"
#import "Venue.h"
#import <CMMapLauncher/CMMapLauncher.h>
#import <Reachability/Reachability.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import <UIImageView+WebCache.h>
#import "LPCSettingsHelper.h"
#import <Analytics/Analytics.h>

@interface LPCStationViewController () <UIActionSheetDelegate>

@end

@interface LPCStationViewController (private)

-(void)reachabilityChanged:(NSNotification*)note;

@end

@implementation LPCStationViewController {
    int zoomLevel;
    NSArray *venues;
    LPCVenue *currentVenue;
    LPCLine *currentLine;
    int currentVenueIndex;
    int currentTipIndex;
    LPCVenueRetrievalHandler *venueRetrievalHandler;
    UIImageView *helpImageOverlay;
    BOOL reachable;
    BOOL refreshWhenReachable;
    BOOL isBlurredOver;
}

//[NSString stringWithFormat:kLPCMapBoxURLTemplate, mapKey, lineColourHexCode, [currentVenue.latLng[1] floatValue], [currentVenue.latLng[0] floatValue], lineColourHexCode, [self.station.coordinate[1] floatValue], [self.station.coordinate[0] floatValue], [self.station.coordinate[1] floatValue], [self.station.coordinate[0] floatValue], zoomLevel, self.mapImageView.frame.size.width, self.mapImageView.frame.size.height, mapBoxImageRetina], mapBoxAccessToken;
NSString *const kLPCMapBoxURLTemplate = @"https://api.mapbox.com/v4/%@/pin-m-beer+%@(%.04f,%.04f),pin-m-rail+%@(%.04f,%.04f)/%.04f,%.04f,%d/%.0fx%.0f%@.png?access_token=%@";
NSString *const kLPCGoogleMapsURLTemplate = @"http://maps.googleapis.com/maps/api/staticmap?markers=color:grey%%7C%.04f,%.04f&center=%.04f,%.04f&zoom=%d&size=%.0fx%.0f%@&sensor=false%@&visual_refresh=true";

- (void)reachabilityChanged:(NSNotification*)note {
    Reachability *reach = [note object];
    
    if([reach isReachable])
    {
        NSLog(@"Reachable");
        reachable = YES;
        if (refreshWhenReachable) {
            [self loadVenues];
            [self updateView];
        }
    }
    else
    {
        NSLog(@"Not reachable");
        reachable = NO;
    }
}

- (id)initWithStation:(LPCStation *)station andLine:(LPCLine *)line andBlurred:(BOOL)blurred {
    self = [super initWithNibName:@"LPCStationViewController" bundle:nil];
    
    if (self) {
        venueRetrievalHandler = [LPCVenueRetrievalHandler sharedHandler];
        currentVenueIndex = 0;
        currentTipIndex = 0;
        venues = nil;
        currentLine = nil;
        Reachability *reach = [Reachability reachabilityWithHostname:@"api.foursquare.com"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        reachable = [reach isReachable];
        refreshWhenReachable = NO;
        
        [reach startNotifier];
    }
    
    self.station = station;
    currentLine = line;
    
    isBlurredOver = blurred;
    
    if (blurred) {
        self.blurView.hidden = NO;
    }
    
    [self loadVenues];
    
    return self;
}

- (void)updateView {
    [self showStationInfo];
    if (!reachable) {
        if ([venues count] == 0) {
            // We're offline and there are no venues available. Should be the only time we show the offline image
            [self showOffline];
        } else {
            // We're offline and there are cached venues which have been loaded. Great stuff!
            [self showVenues];
        }
    } else {
        if ([venues count] == 0) {
            // We're online but we don't have any venues yet
            [self showLoading];
        } else {
            // We're online and we've loaded some venues
            [self showVenues];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.stationDelegate stationDidAppear];
    
    [[SEGAnalytics sharedAnalytics] screen:@"Station view"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.blurView setLine:currentLine];
    self.blurView.hidden = !isBlurredOver;
    [self updateView];
}

# pragma mark - Private Methods

/*!
 Returns the standard analytics properties for any station-related event
 */
- (id)analyticsProperties {
    return @{ @"Station" : self.station.name, @"Station views in line session" : [NSNumber numberWithInt:[self.stationDelegate numStationViewsThisLineSession]], @"Line" : currentLine.name };
}

/*!
 Configures the static visible elements of the view such as station
 name and lines
 */
- (void)showStationInfo {
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
    [self.pubNameLabel setText:@"Finding a pub..."];
    [self.offlineMessageLabel setHidden:YES];
}

- (void)showOffline {
    [[SEGAnalytics sharedAnalytics] track:@"Offline view shown"];
    [self.loadingImageView stopAnimating];
    self.loadingImageView.animationImages = nil;
    self.loadingImageView.animationDuration = 0;
    self.loadingImageView.animationRepeatCount = 0;
    
    [self.loadingImageView setImage:[UIImage imageNamed:@"Offline.png"]];
    
    [self.pubNameLabel setText:@"You're offline!"];
    
    [self.offlineMessageLabel setHidden:NO];
    
    [[SEGAnalytics sharedAnalytics] track:@"Showed offline message" properties:[self analyticsProperties]];
    
    refreshWhenReachable = YES;
}

- (void)loadVenues {
    NSLog(@"[%@]: Loading venues", self.station.name);
    NSArray *storedVenues = [venueRetrievalHandler venuesForStation:self.station completion:^(NSArray *remoteVenues) {
        refreshWhenReachable = NO;
        if ((!venues || [venues count] < 1) && [remoteVenues count] > 0) {
            [self updateInstanceVenues:remoteVenues];
            [self updateView];
        }
    }];
    
    if (storedVenues) {
        NSLog(@"[%@]: Cached venues are available", self.station.name);
        [self updateInstanceVenues:storedVenues];
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
        NSLog(@"[%@]: Showing the first of %i venues", self.station.name, (int)[venues count]);
        [self displayVenueAtIndex:currentVenueIndex];
        [self loadMapImage];
    } else {
        // This shouldn't happen, but if it does let's make sure we figure out what to show
        [self updateView];
    }
    
    if ([venues count] == 1) {
        self.nextPubButton.hidden = YES;
    } else if ([venues count] > 1) {
        self.nextPubButton.hidden = NO;
    }
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
    
    NSString *mapKey = [[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mapbox-map-key"];
    NSString *mapboxAccessToken = [[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mapbox-access-token"];
    
    NSString *lineColourHexCode = [self.lineColour hexStringValueWithHash:NO];
    NSString *mapImageUrl = [NSString stringWithFormat:kLPCMapBoxURLTemplate, mapKey, lineColourHexCode, [currentVenue.latLng[1] floatValue], [currentVenue.latLng[0] floatValue], lineColourHexCode, [self.station.coordinate[1] floatValue], [self.station.coordinate[0] floatValue], [self.station.coordinate[1] floatValue], [self.station.coordinate[0] floatValue], zoomLevel, self.mapImageView.frame.size.width, self.mapImageView.frame.size.height, mapBoxImageRetina, mapboxAccessToken];
    
    [self.mapImageView sd_setImageWithURL:[NSURL URLWithString:mapImageUrl] placeholderImage:[UIImage imageNamed:@"map-placeholder.png"]];
    [self.mapImageView setImage:[UIImage imageNamed:@"map-placeholder.png"]];
    
    UITapGestureRecognizer *mapImageViewTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToMapImageTap:)];
    mapImageViewTapGestureRecogniser.numberOfTapsRequired = 1;
    self.mapImageView.userInteractionEnabled = YES;
    [self.mapImageView addGestureRecognizer:mapImageViewTapGestureRecogniser];
    
    UISwipeGestureRecognizer *mapImageViewSwipeGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToMapImageSwipe:)];
    mapImageViewSwipeGestureRecogniser.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    self.mapImageView.userInteractionEnabled = YES;
    [self.mapImageView addGestureRecognizer:mapImageViewSwipeGestureRecogniser];
    
    [self.headerView setBackgroundColor:[UIColor colorWithHexString:@"#EEFFFFFF"]];
    [self.footerView setBackgroundColor:[UIColor colorWithHexString:@"#EEFFFFFF"]];
}

- (void)viewDidLayoutSubviews {
    [self.tipLabel sizeToFit];
}

- (void)respondToMapImageTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self openActionSheet:nil];
        return;
    }
}

- (void)respondToMapImageSwipe:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self openActionSheet:nil];
        return;
    }
}

- (void)openActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Open in Maps" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:@"Apple Maps"];
    
    [actionSheet addButtonWithTitle:@"Google Maps"];
    
//    if ([CMMapLauncher isMapAppInstalled:CMMapAppCitymapper]) {
        [actionSheet addButtonWithTitle:@"Citymapper"];
//    }
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [[SEGAnalytics sharedAnalytics] track:@"Opened map options" properties: [self analyticsProperties]];
}

# pragma mark - UIActionSheetDelegate methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //coordinates for the place we want to display
    CLLocationCoordinate2D venueLocation = CLLocationCoordinate2DMake([currentVenue.latLng[0] floatValue], [currentVenue.latLng[1] floatValue]);
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Apple Maps"]) {
        [CMMapLauncher launchMapApp:CMMapAppAppleMaps forDirectionsTo:[CMMapPoint mapPointWithName:self.pubNameLabel.text coordinate:venueLocation]];
        [[SEGAnalytics sharedAnalytics] track:@"Directions in Apple Maps" properties: [self analyticsProperties]];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Google Maps"]) {
        if ([CMMapLauncher isMapAppInstalled:CMMapAppGoogleMaps]) {
            [CMMapLauncher launchMapApp:CMMapAppGoogleMaps forDirectionsTo:[CMMapPoint mapPointWithName:self.pubNameLabel.text coordinate:venueLocation]];
            [[SEGAnalytics sharedAnalytics] track:@"Directions in Google Maps App" properties: [self analyticsProperties]];
        } else {
            // Open up web Google Maps instead
            NSString *stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@@%1.6f,%1.6f&z=%d", currentVenue.name, venueLocation.latitude, venueLocation.longitude, zoomLevel];
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
            [[SEGAnalytics sharedAnalytics] track:@"Directions in Google Maps Website" properties: [self analyticsProperties]];
        }
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Citymapper"]) {
        [CMMapLauncher launchMapApp:CMMapAppCitymapper forDirectionsTo:[CMMapPoint mapPointWithName:self.pubNameLabel.text coordinate:venueLocation]];
        [[SEGAnalytics sharedAnalytics] track:@"Directions in CityMapper" properties: [self analyticsProperties]];
    }
}

# pragma mark - IBActions

- (IBAction)changeLine:(id)sender {
    // Dismiss this controller first
    [[SEGAnalytics sharedAnalytics] track:@"Changed line" properties: [self analyticsProperties]];
    
    if (self.lineDelegate) {
        [self.lineDelegate didClickChangeLine];
    }
}

- (IBAction)changePub:(id)sender {
    currentVenueIndex++;
    
    [[SEGAnalytics sharedAnalytics] track:@"Changed to a different pub" properties: [self analyticsProperties]];
    
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
    [[SEGAnalytics sharedAnalytics] track:@"Clicked station help button" properties: [self analyticsProperties]];
    
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
