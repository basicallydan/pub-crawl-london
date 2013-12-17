#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Venue : NSManagedObject

@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSString *formattedAddress;
@property (nonatomic, retain) NSData *latLng;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *priceMessage;
@property (nonatomic, retain) NSNumber *priceTier;
@property (nonatomic, retain) NSString *stationCode;
@property (nonatomic, retain) NSData *tips;

- (void)populateWithFoursquarePubData:(NSDictionary *)pubData;
- (void)setArrayOfTips:(NSArray *)tipsArray;
- (NSArray *)arrayOfTips;
- (void)setArrayOfCoordinates:(NSArray *)coordinates;
- (NSArray *)arrayOfCoordinates;

@end
