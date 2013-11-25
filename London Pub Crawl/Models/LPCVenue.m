#import "LPCVenue.h"

@implementation LPCVenue

- (id)initWithPubData:(NSDictionary *)pubData {
    self.name = [pubData valueForKeyPath:@"name"];
    NSString *streetAddress = [pubData valueForKeyPath:@"location.address"];
    NSString *postcode = [pubData valueForKeyPath:@"location.postcode"];
    self.formattedAddress = [NSString stringWithFormat:@"%@, %@", streetAddress, postcode];
    self.distance =[pubData valueForKeyPath:@"location.distance"];
    NSNumber *pubLatitude = [pubData valueForKeyPath:@"location.lat"];
    NSNumber *pubLongitude = [pubData valueForKeyPath:@"location.lng"];
    self.tips = [pubData valueForKey:@"tips"];
    self.latLng = @[pubLatitude, pubLongitude];
    self.priceTier = [pubData valueForKeyPath:@"price.tier"];
    self.priceMessage = [pubData valueForKeyPath:@"price.message"];
    return self;
}

@end
