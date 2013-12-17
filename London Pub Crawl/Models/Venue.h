#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Venue : NSManagedObject

@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSString *formattedAddress;
@property (nonatomic, retain) NSArray *latLng;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *priceMessage;
@property (nonatomic, retain) NSNumber *priceTier;
@property (nonatomic, retain) NSString *stationCode;
@property (nonatomic, retain) NSArray *tips;

- (id)initWithPubData:(NSDictionary *)pubData;
- (void)populateWithFoursquarePubData:(NSDictionary *)pubData;

@end
