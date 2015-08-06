#import "LPCAppDelegate.h"

#import "Analytics/Analytics.h"
#import "LPCSettingsHelper.h"
#import "LPCVenueRetrievalHandler.h"
#import <IAPHelper/IAPShare.h>
#import <PonyDebugger/PonyDebugger.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import "NSDictionary+FromJSONFile.h"
#import "Bugsnag.h"

@implementation LPCAppDelegate

NSDictionary *allProducts;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Bugsnag startBugsnagWithApiKey:@"750a2fe89ad883346f20f9e56703dd6e"];
    NSDictionary *allTheData = [NSDictionary dictionaryWithContentsOfJSONFile:@"tfl-tube-data.json"];
    self.stations = [allTheData valueForKey:@"stations"];
    self.lines = [allTheData valueForKey:@"lines"];
    self.pubs = [NSDictionary dictionaryWithContentsOfJSONFile:@"station-pubs.json"];
    NSMutableArray *temporaryLinesArray = [[NSMutableArray alloc] init];

    for (NSString *line in self.lines) {
        [temporaryLinesArray addObject:line];
    }
    
    // If you want to see debug logs from inside the SDK.
    [SEGAnalytics debug:YES];
    
    // Initialize the Analytics instance with the
    [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:[[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"segment-io-key"]]];
     
    

    self.linesArray = temporaryLinesArray;

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor clearColor];
    pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
    pageControl.backgroundColor = [UIColor clearColor];
    
    // Set up IAPHelper
    
    if(![IAPShare sharedHelper].iap) {
        
        NSSet* dataSet = [[NSSet alloc] initWithObjects:
                          @"com.happily.pubcrawl.northernline",
                          @"com.happily.pubcrawl.centralline",
                          @"com.happily.pubcrawl.piccadillyline",
                          @"com.happily.pubcrawl.victorialine",
                          @"com.happily.pubcrawl.jubileeline",
                          @"com.happily.pubcrawl.districtline",
                          @"com.happily.pubcrawl.circleline",
                          @"com.happily.pubcrawl.bakerlooline",
                          @"com.happily.pubcrawl.handcline",
                          @"com.happily.pubcrawl.metline",
                          allTheLinesKey, nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    
    // TODO: Set to YES before shipping
    [IAPShare sharedHelper].iap.production = NO;
    
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response) {
         if(response > 0 ) {
             NSMutableDictionary *products = [[NSMutableDictionary alloc] initWithCapacity:[response.products count]];
             NSLog(@"Got a bunch of products. %i to be precise", (int)[response.products count]);
             for (SKProduct *product in [IAPShare sharedHelper].iap.products) {
                 [products setValue:product forKey:product.productIdentifier];
                 NSLog(@"Found product: %@ with price: %@", product.productIdentifier, product.priceLocale);
             }
             allProducts = [[NSDictionary alloc] initWithDictionary:products];
         } else {
             NSLog(@"No products");
         }
     }];
    
    if ([[LPCSettingsHelper sharedInstance] booleanForSettingWithKey:@"enable-all-lines"]) {
        [[IAPShare sharedHelper].iap provideContent:allTheLinesKey];
    }
    
    if ([[LPCSettingsHelper sharedInstance] booleanForSettingWithKey:@"clear-purchases"]) {
        [[IAPShare sharedHelper].iap clearSavedPurchasedProducts];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"HasBeenRun"]) {
        // If it's the first run, clear all the saved purchases
        [[IAPShare sharedHelper].iap clearSavedPurchasedProducts];
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"HasBeenRun"];
    }
    
    return YES;
}

- (UIColor *)colorForLine:(NSString *)lineCode {
//    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *line = [self.lines valueForKey:lineCode];
    
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
+ (LPCStation *)stationWithNestoriaCode:(NSString *)nestoriaCode atPosition:(LPCLinePosition *)position {
    LPCAppDelegate *appDelegate = (LPCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *stationDictionary = [appDelegate.stations objectForKey:nestoriaCode];
    LPCStation *station = [[LPCStation alloc] initWithStation:stationDictionary];
    station.linePosition = position;
    return station;
}

+ (SKProduct *)productWithIdentifier:(NSString *)identifier {
    if ([allProducts valueForKey:identifier]) {
        return [allProducts valueForKey:identifier];
    } else {
        return nil;
    }
}

+ (NSString *)priceStringForAllTheLines {
    SKProduct *product = [self productWithIdentifier:@"com.happily.pubcrawl.allthelines"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:product.priceLocale];
    return [formatter stringFromNumber:product.price];
}

@end
