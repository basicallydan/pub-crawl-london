#import "LPCVenueRetrievalHandler.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "Venue.h"

@implementation LPCVenueRetrievalHandler

NSMutableDictionary *venues;
NSManagedObjectContext *managedObjectContext;
NSPersistentStoreCoordinator *persistentStoreCoordinator;
NSManagedObjectModel *managedObjectModel;

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

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *managedObjectContext = nil;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [managedObjectContext setUndoManager:nil];
    }
    return managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataExample.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSArray *)findStoredVenuesForStation:(LPCStation *)station {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationCode=%@", station.nestoriaCode];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    
    return fetchedObjects;
}

- (NSArray *)venuesForStation:(LPCStation *)station completion:(void (^)(NSArray *))completion {
//    NSArray *matchingVenues = [venues objectForKey:station.code];
    NSArray *matchingVenues = [self findStoredVenuesForStation:station];
    if (matchingVenues && [matchingVenues count] > 0) {
//        [[self managedObjectContext] ]
        return matchingVenues;
    }
    
    NSURL *URL = [NSURL URLWithString:@"https://api.foursquare.com"];
    
    NSString *urlPathTemplate = @"/v2/venues/search?client_id=%@&client_secret=%@&v=20131216&ll=%@,%@&section=drinks";
    NSString *urlPath = [NSString stringWithFormat:urlPathTemplate, @"SNE54YCOV1IR5JP14ZOLOZU0Z43FQWLTTYDE0YDKYO03XMMH", @"44AI50PSJMHMXVBO1STMAUV0IZYQQEFZCSO1YXXKVTVM32OM&limit=6", station.coordinate[0], station.coordinate[1]];
    
    NSMutableArray *resources = [[NSMutableArray alloc] init];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:URL];
    [manager GET:urlPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *response = [responseObject valueForKeyPath:@"response.venues"];
        
//        [[Venue alloc] enti]
        
        for (NSDictionary *venue in response) {
            Venue *v = [[Venue alloc] initWithPubData:venue];
            [resources addObject:v];
        }
        
        completion([NSArray arrayWithArray:resources]);
        
//        NSLog(response);
//
//        [manager SUBSCRIBE:@"/resources" usingBlock:^(NSArray *operations, NSError *error) {
//            for (AFJSONPatchOperation *operation in operations) {
//                switch (operation.type) {
//                    case AFJSONAddOperationType:
//                        [resources addObject:operation.value];
//                        break;
//                    default:
//                        break;
//                }
//            }
//        } error:nil];
    } failure:nil];
    
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
