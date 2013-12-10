#import <Foundation/Foundation.h>

#import "LPCStation.h"
#import "LPCVenue.h"

@interface LPCVenueRetrievalHandler : NSObject

+ (id)sharedHandler;

- (NSArray *)venuesForStation:(LPCStation *)station completion:(void (^)(NSArray *venues))completion;
- (void)addVenue:(NSDictionary *)venue forStationCode:(NSString *)stationCode;

@end
