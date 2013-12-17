#import "Venue.h"


@implementation Venue

@synthesize address;
@synthesize formattedAddress;
@synthesize distance;
@synthesize priceMessage;
@synthesize priceTier;
@synthesize name;
@synthesize stationCode;
@synthesize tips;
@synthesize latLng;
@synthesize mapZoomLevel;

- (id)initWithPubData:(NSDictionary *)pubData {
    self.name = [pubData valueForKeyPath:@"name"];
    NSString *streetAddress = [pubData valueForKeyPath:@"location.address"];
    NSString *postcode = [pubData valueForKeyPath:@"location.postcode"];
    self.formattedAddress = streetAddress;
    if (streetAddress && postcode) {
        self.formattedAddress = [NSString stringWithFormat:@"%@, %@", streetAddress, postcode];
    } else if (streetAddress) {
        self.formattedAddress = streetAddress;
    } else if (postcode) {
        self.formattedAddress = postcode;
    } else {
        self.formattedAddress = @"No address given :(";
    }
    self.distance =[pubData valueForKeyPath:@"location.distance"];
    NSNumber *pubLatitude = [pubData valueForKeyPath:@"location.lat"];
    NSNumber *pubLongitude = [pubData valueForKeyPath:@"location.lng"];
    if ([pubData valueForKeyPath:@"location.mapZoomLevel"] != nil) {
        self.mapZoomLevel = [pubData valueForKeyPath:@"location.mapZoomLevel"];
    }
    self.tips = [pubData valueForKey:@"tips"];
    self.latLng = @[pubLatitude, pubLongitude];
    self.priceTier = [pubData valueForKeyPath:@"price.tier"];
    self.priceMessage = [pubData valueForKeyPath:@"price.message"];
    return self;
}

- (id)initWithFoursquarePubData:(NSDictionary *)pubData {
    self.name = [pubData valueForKeyPath:@"venue.name"];
    NSString *streetAddress = [pubData valueForKeyPath:@"venue.location.address"];
    NSString *postcode = [pubData valueForKeyPath:@"venue.location.postcode"];
    self.formattedAddress = streetAddress;
    if (streetAddress && postcode) {
        self.formattedAddress = [NSString stringWithFormat:@"%@, %@", streetAddress, postcode];
    } else if (streetAddress) {
        self.formattedAddress = streetAddress;
    } else if (postcode) {
        self.formattedAddress = postcode;
    } else {
        self.formattedAddress = @"No address given :(";
    }
    self.distance =[pubData valueForKeyPath:@"venue.location.distance"];
    NSNumber *pubLatitude = [pubData valueForKeyPath:@"venue.location.lat"];
    NSNumber *pubLongitude = [pubData valueForKeyPath:@"venue.location.lng"];
    if ([pubData valueForKeyPath:@"venue.location.mapZoomLevel"] != nil) {
        self.mapZoomLevel = [pubData valueForKeyPath:@"venue.location.mapZoomLevel"];
    }
    self.tips = [pubData valueForKey:@"tips"];
    self.latLng = @[pubLatitude, pubLongitude];
    self.priceTier = [pubData valueForKeyPath:@"venue.price.tier"];
    self.priceMessage = [pubData valueForKeyPath:@"venue.price.message"];
    return self;
}

@end
