#import "LPCAppDelegate.h"

#import <UIColor-HexString/UIColor+HexString.h>
#import "LPCVenueRetrievalHandler.h"

@implementation LPCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *allTheData = [self.class dictionaryWithContentsOfJSONString:@"tfl-tube-data.json"];
    self.stations = [allTheData valueForKey:@"stations"];
    self.lines = [allTheData valueForKey:@"lines"];
    self.pubs = [self.class dictionaryWithContentsOfJSONString:@"station-pubs.json"];
    NSMutableArray *temporaryLinesArray = [[NSMutableArray alloc] init];
    
    LPCVenueRetrievalHandler *venueRetrievalHandler = [LPCVenueRetrievalHandler sharedHandler];

    for (NSString *line in self.lines) {
        [temporaryLinesArray addObject:line];
    }
    
    for (NSString *station in self.pubs) {
        NSArray *pubs = [self.pubs objectForKey:station];
        for (NSDictionary *pub in pubs) {
            [venueRetrievalHandler addVenue:pub forStationCode:station];
        }
    }

    self.linesArray = temporaryLinesArray;

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor clearColor];
    pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
    pageControl.backgroundColor = [UIColor clearColor];

    return YES;
}

- (UIColor *)colorForLine:(NSString *)lineCode {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *line = [appDelegate.lines valueForKey:lineCode];
    
    UIColor *cellColor = [UIColor colorWithHexString:[line valueForKey:@"background-color"]];
    return cellColor;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Static methods
+ (NSDictionary *)dictionaryWithContentsOfJSONString:(NSString*)fileLocation{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileLocation stringByDeletingPathExtension] ofType:[fileLocation pathExtension]];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    // Be careful here. You add this as a category to NSDictionary
    // but you get an id back, which means that result
    // might be an NSArray as well!
    if (error != nil) return nil;
    return result;
}

+ (LPCStation *)stationWithNestoriaCode:(NSString *)nestoriaCode atPosition:(LPCLinePosition *)position {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *stationDictionary = [appDelegate.stations objectForKey:nestoriaCode];
    LPCStation *station = [[LPCStation alloc] initWithStation:stationDictionary];
    station.linePosition = position;
    return station;
}

@end
