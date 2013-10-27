#import "NSArray+AsCLLocationCoordinate2D.h"

@implementation NSArray (AsCLLocationCoordinate2D)

- (CLLocationCoordinate2D)asCLLocationCoordinate2D {
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([(NSNumber *)self[0] doubleValue], [(NSNumber *)self[1] doubleValue]);
    return location;
}

@end
