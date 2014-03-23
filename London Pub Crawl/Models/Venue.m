#import "Venue.h"


@implementation Venue

@synthesize formattedAddress;
@synthesize distance;
@synthesize priceMessage;
@synthesize priceTier;
@synthesize name;
@synthesize stationCode;
@synthesize tips;
@synthesize latLng;

- (void)populateWithFoursquarePubData:(NSDictionary *)pubData {
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
    self.distance = [pubData valueForKeyPath:@"venue.location.distance"];
//    self.distance = [NSNumber numberWithInteger:[pubData valueForKeyPath:@"venue.location.distance"]]
    NSNumber *pubLatitude = [pubData valueForKeyPath:@"venue.location.lat"];
    NSNumber *pubLongitude = [pubData valueForKeyPath:@"venue.location.lng"];
    if ([pubData valueForKeyPath:@"venue.location.mapZoomLevel"] != nil) {
        // self.mapZoomLevel = [pubData valueForKeyPath:@"venue.location.mapZoomLevel"];
    }
    self.tips = [pubData valueForKey:@"tips"];
    [self setArrayOfTips:[pubData valueForKey:@"tips"]];
    [self setArrayOfCoordinates:@[pubLatitude, pubLongitude]];
    self.priceTier = [pubData valueForKeyPath:@"venue.price.tier"];
    self.priceMessage = [NSString stringWithString:[pubData valueForKeyPath:@"venue.price.message"]];
}

- (void)setArrayOfCoordinates:(NSArray *)coordinates {
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
    self.latLng = arrayData;
}

- (NSArray *)arrayOfCoordinates {
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:self.latLng];
    return [NSArray arrayWithArray:array];
}

- (void)setArrayOfTips:(NSArray *)tipsArray {
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:tipsArray];
    self.tips = arrayData;
}


- (NSArray *)arrayOfTips {
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:self.tips];
    return [NSArray arrayWithArray:array];
}

@end
