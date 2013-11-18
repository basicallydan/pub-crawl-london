#import "LPCStation.h"

#import "NSArray+AsCLLocationCoordinate2D.h"

@implementation LPCStation

- (id)initWithStation:(NSDictionary *)station {
    self.nestoriaCode = [station valueForKey:@"nestoria_code"];
    self.name = [station valueForKey:@"name"];
    self.code = [station valueForKey:@"code"];
    
    NSNumber *lat = [NSNumber numberWithDouble:[[station valueForKey:@"lat"] doubleValue]];
    NSNumber *lng = [NSNumber numberWithDouble:[[station valueForKey:@"lng"] doubleValue]];
    self.coordinate = [NSArray arrayWithObjects:lat, lng, nil];
    
    return self;
}

@end
