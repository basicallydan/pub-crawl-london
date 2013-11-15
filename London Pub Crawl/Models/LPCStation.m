#import "LPCStation.h"

@implementation LPCStation

- (id)initWithStation:(NSDictionary *)station {
    self.nestoriaCode = [station valueForKey:@"nestoria_code"];
    self.name = [station valueForKey:@"name"];
    
    return self;
}

@end
