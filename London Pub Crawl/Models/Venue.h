#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Venue : NSManagedObject

@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *formattedAddress;
@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSString *priceMessage;
@property (nonatomic, retain) NSNumber *priceTier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *stationCode;
@property (nonatomic, retain) NSArray *tips;
@property (nonatomic, retain) NSArray *latLng;
@property (nonatomic, retain) NSNumber *mapZoomLevel;

- (id)initWithPubData:(NSDictionary *)pubData;
- (id)initWithFoursquarePubData:(NSDictionary *)pubData;

@end
