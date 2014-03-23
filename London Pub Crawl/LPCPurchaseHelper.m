#import "LPCPurchaseHelper.h"

@implementation LPCPurchaseHelper

+ (LPCPurchaseHelper *)sharedInstance {
    static dispatch_once_t once;
    static LPCPurchaseHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.happily.pubcrawl.northernline",
                                      @"com.happily.pubcrawl.allthelines",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
