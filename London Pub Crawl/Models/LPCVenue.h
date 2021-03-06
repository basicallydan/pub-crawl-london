#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LPCVenue : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *formattedAddress;
@property (strong, nonatomic) NSArray *latLng;
@property (strong, nonatomic) NSArray *tips;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSNumber *priceTier;
@property (strong, nonatomic) NSString *priceMessage;
@property (strong, nonatomic) NSNumber *mapZoomLevel;

- (id)initWithPubData:(NSDictionary *)pubData;

@end
