#import "LPCVenueRetrievalHandler.h"

@implementation LPCVenueRetrievalHandler

NSMutableDictionary *venues;

+ (id)sharedHandler {
    static LPCVenueRetrievalHandler *theHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theHandler = [[self alloc] init];
    });
    return theHandler;
}

- (id)init {
    self = [super init];
    venues = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSArray *)venuesForStation:(LPCStation *)station completion:(void (^)(NSArray *))completion {
    NSArray *matchingVenues = [venues objectForKey:station.code];
    if (matchingVenues) {
        return matchingVenues;
    }
    
    return nil;
}

- (void)addVenue:(NSDictionary *)venue forStationCode:(NSString *)stationCode {
    NSArray *venueArray = [venues objectForKey:stationCode];
    LPCVenue *newVenue = [[LPCVenue alloc] initWithPubData:venue];
    if (!venueArray) {
        [venues setObject:[[NSArray alloc] initWithObjects:newVenue, nil] forKey:stationCode];
    } else {
        [venues setObject:[venueArray arrayByAddingObject:newVenue] forKey:stationCode];
    }
}

@end
